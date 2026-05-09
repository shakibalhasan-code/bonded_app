import 'dart:convert';
import 'package:bonded_app/core/constants/app_endpoints.dart';
import 'package:bonded_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/home_models.dart';
import '../models/event_model.dart';
import '../models/circle_model.dart';
import '../services/socket_service.dart';
import '../controllers/circle_controller.dart';
import '../controllers/bond_controller.dart';
import '../models/bond_user_model.dart';

class HomeController extends GetxController {
  final ApiService _apiService = ApiService();
  final RxBool isLoading = false.obs;

  // Real data using models
  final RxList<PostModel> circleHighlights = <PostModel>[].obs;
  final RxList<EventModel> upcomingEvents = <EventModel>[].obs;
  final RxList<CircleModel> discoveryCircles = <CircleModel>[].obs;
  final RxList<BondConnectionModel> peopleRecommendations = <BondConnectionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    Get.put(BondController()); // Ensure BondController is available
    fetchHomeData();
    // Initialize Socket Connection
    Get.find<SocketService>().initSocket();
  }

  Future<void> fetchHomeData() async {
    try {
      isLoading.value = true;
      
      // Default coordinates for now or get from LocationController
      final url = '${AppUrls.home}?lat=23.8103&lng=90.4125&maxDistance=15000';
      debugPrint("Fetching home data from: $url");
      
      final response = await _apiService.get(url);
      debugPrint("Home API Response Status: ${response.statusCode}");
      debugPrint("Home API Response Body: ${response.body}");
      
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final homeData = data['data'];
        
        try {
          // 1. Posts (Circle Highlights)
          if (homeData['circles'] != null && homeData['circles']['posts'] != null) {
            final List postsJson = homeData['circles']['posts'];
            circleHighlights.assignAll(postsJson.map((p) => PostModel.fromJson(p)).toList());
          }

          // 2. Events
          if (homeData['events'] != null && homeData['events']['events'] != null) {
            final List eventsJson = homeData['events']['events'];
            upcomingEvents.assignAll(eventsJson.map((e) => EventModel.fromJson(e)).toList());
          }

          // 3. Discovery Circles
          if (homeData['circles'] != null && homeData['circles']['circles'] != null) {
            final List circlesJson = homeData['circles']['circles'];
            discoveryCircles.assignAll(circlesJson.map((c) => CircleModel.fromJson(c)).toList());
          }

          // 4. Bond Suggestions (People You May Know)
          if (homeData['bondSuggestions'] != null) {
            final List suggestions = homeData['bondSuggestions'];
            peopleRecommendations.assignAll(suggestions.map((s) => BondConnectionModel.fromJson(s)).toList());
          }
        } catch (e, stack) {
          debugPrint("Error parsing home data models: $e");
          debugPrint(stack.toString());
        }
      } else {
        debugPrint("Home API Success: False, Message: ${data['message']}");
      }
    } catch (e) {
      debugPrint("Error fetching home data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Interactivity Methods (Delegated to CircleController or handled locally)
  void toggleLikePost(PostModel post) {
    Get.find<CircleController>().toggleLikePost(post);
  }

  void updatePostReaction(PostModel post, String type) {
    Get.find<CircleController>().updatePostReaction(post, type);
  }

  void toggleCommentInput(PostModel post) {
    Get.find<CircleController>().toggleCommentInput(post);
  }

  void addComment(PostModel post, String text) {
    Get.find<CircleController>().addCommentToPost(
      post: post,
      content: text,
    );
  }

  void toggleLikeComment(CommentModel comment) {
    Get.find<CircleController>().toggleLikeComment(comment);
  }

  void toggleReplyInput(CommentModel comment) {
    Get.find<CircleController>().toggleReplyInput(comment);
  }

  void addReply(CommentModel comment, String text) {
    // Note: This assumes we have the parent post context. 
    // In CircleHighlightCard, we don't easily have the PostModel here without passing it.
    // However, since CircleHighlightCard is deprecated, we just want to avoid errors.
    Get.snackbar("Notice", "Please use the updated post interaction features.");
  }
}

