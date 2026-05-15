import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../core/constants/app_endpoints.dart';
import '../core/utils/app_messenger.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';

class ReviewController extends GetxController {
  final ApiService _apiService = ApiService();

  final Rxn<ReviewSummary> summary = Rxn<ReviewSummary>();
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool hasMore = false.obs;

  int _page = 1;
  int _totalPage = 1;
  final int _limit = 20;

  String? _currentEventId;

  Future<void> loadReviews(String eventId, {bool refresh = true}) async {
    if (refresh) {
      _currentEventId = eventId;
      _page = 1;
      reviews.clear();
      summary.value = null;
    }
    isLoading.value = refresh;
    try {
      final response = await _apiService.get(
        AppUrls.eventReviews(eventId, page: _page, limit: _limit),
      );
      final json = jsonDecode(response.body);
      if (json['success'] != true) return;

      final data = json['data'] ?? {};

      final summaryJson = data['summary'];
      if (summaryJson is Map) {
        summary.value = ReviewSummary.fromJson(
          Map<String, dynamic>.from(summaryJson),
        );
      } else {
        summary.value ??= ReviewSummary.empty();
      }

      final list = data['reviews'];
      if (list is List) {
        final parsed = list
            .whereType<Map>()
            .map((m) => ReviewModel.fromJson(Map<String, dynamic>.from(m)))
            .toList();
        if (refresh) {
          reviews.assignAll(parsed);
        } else {
          reviews.addAll(parsed);
        }
      }

      final meta = data['meta'] ?? json['meta'];
      if (meta is Map) {
        _page = (meta['page'] as num?)?.toInt() ?? _page;
        _totalPage = (meta['totalPage'] as num?)?.toInt() ?? _page;
      }
      hasMore.value = _page < _totalPage;
    } catch (e) {
      debugPrint('ReviewController.loadReviews error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value || _currentEventId == null) {
      return;
    }
    isLoadingMore.value = true;
    _page += 1;
    try {
      final response = await _apiService.get(
        AppUrls.eventReviews(_currentEventId!, page: _page, limit: _limit),
      );
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        final list = (json['data']?['reviews']) as List?;
        if (list != null) {
          reviews.addAll(
            list.whereType<Map>().map(
                  (m) => ReviewModel.fromJson(Map<String, dynamic>.from(m)),
                ),
          );
        }
        final meta = json['data']?['meta'] ?? json['meta'];
        if (meta is Map) {
          _totalPage = (meta['totalPage'] as num?)?.toInt() ?? _page;
        }
        hasMore.value = _page < _totalPage;
      } else {
        _page -= 1;
      }
    } catch (e) {
      _page -= 1;
      debugPrint('ReviewController.loadMore error: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Returns true on a successful submission.
  Future<bool> submitReview({
    required String eventId,
    required int rating,
    required String comment,
  }) async {
    if (isSubmitting.value) return false;
    isSubmitting.value = true;
    try {
      final response = await _apiService.post(
        AppUrls.createReview(eventId),
        {},
        body: {'rating': rating, 'comment': comment},
      );
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        AppMessenger.success('Review submitted');
        await loadReviews(eventId, refresh: true);
        return true;
      }
      AppMessenger.error(json['message'] ?? 'Failed to submit review');
      return false;
    } on ApiException catch (e) {
      // Spec: 403 = not a ticket holder, 409 = already reviewed, 400 = validation.
      AppMessenger.error(e.message);
      return false;
    } catch (e) {
      debugPrint('ReviewController.submitReview error: $e');
      AppMessenger.error('Failed to submit review');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
