import 'dart:convert';
import 'package:bonded_app/core/constants/app_endpoints.dart';
import 'package:bonded_app/models/highlight_model.dart';
import 'package:bonded_app/services/api_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:image_picker/image_picker.dart';
import 'base_controller.dart';

class HighlightController extends BaseController {
  final ApiService _apiService = ApiService();

  final RxList<HighlightModel> publicHighlights = <HighlightModel>[].obs;
  final RxList<HighlightModel> circleHighlights = <HighlightModel>[].obs;
  final RxList<HighlightModel> eventHighlights = <HighlightModel>[].obs;
  
  final RxBool isCreating = false.obs;

  // Fetch Public Highlights
  Future<void> fetchPublicHighlights({int page = 1, int limit = 20}) async {
    try {
      setLoading(true);
      final response = await _apiService.get('${AppUrls.publicHighlights}?page=$page&limit=$limit');
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List list = data['data'];
        publicHighlights.value = list.map((e) => HighlightModel.fromJson(e)).toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch public highlights: $e');
    } finally {
      setLoading(false);
    }
  }

  // Fetch Circle Highlights
  Future<void> fetchCircleHighlights(String circleId, {int page = 1, int limit = 20}) async {
    try {
      setLoading(true);
      final response = await _apiService.get('${AppUrls.circleHighlights(circleId)}?page=$page&limit=$limit');
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List list = data['data'];
        circleHighlights.value = list.map((e) => HighlightModel.fromJson(e)).toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch circle highlights: $e');
    } finally {
      setLoading(false);
    }
  }

  // Fetch Event-specific Highlights
  Future<void> fetchEventHighlights(String eventId) async {
    try {
      setLoading(true);
      final response = await _apiService.get(AppUrls.eventHighlights(eventId));
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List list = data['data'];
        eventHighlights.value = list.map((e) => HighlightModel.fromJson(e)).toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch event highlights: $e');
    } finally {
      setLoading(false);
    }
  }

  // Create Highlight
  Future<bool> createHighlight({
    required String eventId,
    required String caption,
    List<String>? taggedAttendees,
    List<String>? taggedCircles,
    List<XFile>? images,
    List<XFile>? videos,
    List<int>? videoDurations,
  }) async {
    try {
      isCreating.value = true;
      
      final Map<String, String> fields = {
        'caption': caption,
      };

      if (taggedAttendees != null && taggedAttendees.isNotEmpty) {
        fields['taggedAttendees'] = jsonEncode(taggedAttendees);
      }
      if (taggedCircles != null && taggedCircles.isNotEmpty) {
        fields['taggedCircles'] = jsonEncode(taggedCircles);
      }
      if (videoDurations != null && videoDurations.isNotEmpty) {
        fields['videoDurationsSeconds'] = jsonEncode(videoDurations);
      }

      final List<http.MultipartFile> multipartFiles = [];

      if (images != null) {
        for (var file in images) {
          final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
          final mimeParts = mimeType.split('/');
          multipartFiles.add(await http.MultipartFile.fromPath(
            'image',
            file.path,
            contentType: MediaType(mimeParts.first, mimeParts[1]),
          ));
        }
      }

      if (videos != null) {
        for (var file in videos) {
          final mimeType = lookupMimeType(file.path) ?? 'video/mp4';
          final mimeParts = mimeType.split('/');
          multipartFiles.add(await http.MultipartFile.fromPath(
            'video',
            file.path,
            contentType: MediaType(mimeParts.first, mimeParts[1]),
          ));
        }
      }

      final response = await _apiService.multipartRequest(
        'POST',
        AppUrls.eventHighlights(eventId),
        fields: fields,
        files: multipartFiles,
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        Get.snackbar('Success', 'Highlight created successfully');
        fetchEventHighlights(eventId); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create highlight: $e');
      return false;
    } finally {
      isCreating.value = false;
    }
  }
}
