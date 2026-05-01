import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../services/api_service.dart';
import '../services/shared_prefs_service.dart';
import '../core/constants/app_endpoints.dart';
import '../models/circle_model.dart';
import '../models/home_models.dart';
import 'base_controller.dart';

class CircleController extends BaseController {
  final ApiService _apiService = ApiService();

  // Observable lists for different circle views
  var publicCircles = <CircleModel>[].obs;
  var privateCircles = <CircleModel>[].obs;
  var createdCircles = <CircleModel>[].obs;
  var joinedCircles = <CircleModel>[].obs;

  // Loading states
  var isLoadingPublic = false.obs;
  var isLoadingPrivate = false.obs;
  var isLoadingCreated = false.obs;
  var isLoadingJoined = false.obs;

  // UI State
  var selectedTab = 0.obs;
  var myCircleSubTab = 0.obs;
  var isSearchVisible = false.obs;
  var searchQuery = ''.obs;
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Initial fetch
    fetchCircles(visibility: 'public');
    fetchCircles(visibility: 'private');
    fetchCircles(scope: 'created');
    fetchCircles(scope: 'joined');
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void changeTab(int index) {
    selectedTab.value = index;
    isSearchVisible.value = false;
    searchQuery.value = '';
    searchController.clear();
  }

  void changeMyCircleSubTab(int index) {
    myCircleSubTab.value = index;
    isSearchVisible.value = false;
    searchQuery.value = '';
    searchController.clear();
  }

  void toggleSearch() {
    isSearchVisible.value = !isSearchVisible.value;
    if (!isSearchVisible.value) {
      searchQuery.value = '';
      searchController.clear();
    }
  }

  // Filtering Logic
  List<CircleModel> get filteredPublicCircles {
    if (searchQuery.value.isEmpty) return publicCircles;
    return publicCircles.where((c) => 
      c.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
      c.description.toLowerCase().contains(searchQuery.value.toLowerCase())
    ).toList();
  }

  List<CircleModel> get filteredPrivateCircles {
    if (searchQuery.value.isEmpty) return privateCircles;
    return privateCircles.where((c) => 
      c.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
      c.description.toLowerCase().contains(searchQuery.value.toLowerCase())
    ).toList();
  }

  List<CircleModel> get filteredMyCreatedCircles {
    if (searchQuery.value.isEmpty) return createdCircles;
    return createdCircles.where((c) => 
      c.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
      c.description.toLowerCase().contains(searchQuery.value.toLowerCase())
    ).toList();
  }

  List<CircleModel> get filteredMyJoinedCircles {
    if (searchQuery.value.isEmpty) return joinedCircles;
    return joinedCircles.where((c) => 
      c.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
      c.description.toLowerCase().contains(searchQuery.value.toLowerCase())
    ).toList();
  }

  // Members related state
  var availableMembers = <MemberModel>[
    MemberModel(name: "John Doe", image: "https://i.pravatar.cc/150?u=john", isOwner: false),
    MemberModel(name: "Jane Smith", image: "https://i.pravatar.cc/150?u=jane", isOwner: false),
    MemberModel(name: "Mike Johnson", image: "https://i.pravatar.cc/150?u=mike", isOwner: false),
    MemberModel(name: "Sarah Williams", image: "https://i.pravatar.cc/150?u=sarah", isOwner: false),
    MemberModel(name: "David Brown", image: "https://i.pravatar.cc/150?u=david", isOwner: false),
  ].obs;

  List<MemberModel> get filteredAvailableMembers {
    if (searchQuery.value.isEmpty) return availableMembers;
    return availableMembers.where((m) => 
      m.name.toLowerCase().contains(searchQuery.value.toLowerCase())
    ).toList();
  }

  Future<void> fetchCircles({String? visibility, String? scope}) async {
    try {
      _setLoadingState(visibility, scope, true);
      
      final token = SharedPrefsService.getString('accessToken');
      
      // Build query params
      final Map<String, String> params = {};
      if (visibility != null) params['visibility'] = visibility;
      if (scope != null) params['scope'] = scope;
      
      final queryString = params.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      
      final url = '${AppUrls.circles}?$queryString';
      
      final response = await _apiService.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> circlesJson = data['data'];
        final circles = circlesJson.map((c) => CircleModel.fromJson(c)).toList();
        
        _updateCircleList(visibility, scope, circles);
      }
    } catch (e) {
      debugPrint("Error fetching circles ($visibility, $scope): $e");
    } finally {
      _setLoadingState(visibility, scope, false);
    }
  }

  Future<void> createCircle({
    required Map<String, dynamic> circleData,
    File? imageFile,
  }) async {
    try {
      setLoading(true);
      final token = SharedPrefsService.getString('accessToken');

      final List<http.MultipartFile> files = [];
      if (imageFile != null) {
        final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
        final mimeParts = mimeType.split('/');
        files.add(await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType(mimeParts.first, mimeParts[1]),
        ));
      }

      final response = await _apiService.multipartRequest(
        'POST',
        AppUrls.circles,
        headers: {'Authorization': 'Bearer $token'},
        fields: {
          'data': jsonEncode(circleData),
        },
        files: files,
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        // Refresh lists
        fetchCircles(visibility: 'public');
        fetchCircles(visibility: 'private');
        fetchCircles(scope: 'created');
        
        Get.back(); // Go back to previous screen
        
        // Use a small delay to ensure the screen transition is stable before showing snackbar
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.snackbar(
            'Success',
            'Circle created successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green.withOpacity(0.9),
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            margin: const EdgeInsets.all(15),
            borderRadius: 12,
            duration: const Duration(seconds: 3),
            snackStyle: SnackStyle.FLOATING,
          );
        });
      } else {
        Get.snackbar(
          'Error', 
          data['message'] ?? 'Failed to create circle',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Error creating circle: $e");
      Get.snackbar('Error', 'An unexpected error occurred');
    } finally {
      setLoading(false);
    }
  }

  void _setLoadingState(String? visibility, String? scope, bool value) {
    if (scope == 'created') {
      isLoadingCreated.value = value;
    } else if (scope == 'joined') {
      isLoadingJoined.value = value;
    } else if (visibility == 'public') {
      isLoadingPublic.value = value;
    } else if (visibility == 'private') {
      isLoadingPrivate.value = value;
    }
  }

  void _updateCircleList(String? visibility, String? scope, List<CircleModel> circles) {
    if (scope == 'created') {
      createdCircles.value = circles;
    } else if (scope == 'joined') {
      joinedCircles.value = circles;
    } else if (visibility == 'public') {
      publicCircles.value = circles;
    } else if (visibility == 'private') {
      privateCircles.value = circles;
    }
  }

  // Placeholder methods for UI interaction
  void editCircle(CircleModel circle) {
    debugPrint("Edit circle: ${circle.name}");
    // TODO: Implement edit logic
  }

  void deleteCircle(CircleModel circle) {
    debugPrint("Delete circle: ${circle.name}");
    // TODO: Implement delete logic
  }

  void lockCircle(CircleModel circle) {
    debugPrint("Lock circle: ${circle.name}");
    // TODO: Implement lock logic
  }

  void createPost(CircleModel circle, String text) {
    if (text.isEmpty) return;
    
    final newPost = PostModel(
      id: DateTime.now().toString(),
      userName: "Current User",
      userImage: "https://i.pravatar.cc/150?u=me",
      postText: text,
      likesCount: 0,
      commentsCount: 0,
    );
    
    circle.posts.insert(0, newPost);
    circle.postCount.value++;
    Get.back(); // Close sheet
    Get.snackbar("Success", "Post created successfully");
  }

  void toggleLikePost(PostModel post) {
    post.isLiked.value = !post.isLiked.value;
    if (post.isLiked.value) {
      post.likesCount.value++;
    } else {
      post.likesCount.value--;
    }
  }

  void toggleCommentInput(PostModel post) {
    post.isCommenting.value = !post.isCommenting.value;
  }

  void addComment(PostModel post, String text) {
    if (text.isEmpty) return;
    // Dummy comment
    final newComment = CommentModel(
      id: DateTime.now().toString(),
      userName: "Current User",
      userImage: "https://i.pravatar.cc/150?u=me",
      text: text,
      timestamp: "Just now",
    );
    post.comments.insert(0, newComment);
    post.commentsCount.value++;
    post.isCommenting.value = false;
  }

  void updatePostReaction(PostModel post, String type) {
    post.reactionType.value = type;
  }

  void toggleLikeComment(CommentModel comment) {
    comment.isLiked.value = !comment.isLiked.value;
    if (comment.isLiked.value) {
      comment.likesCount.value++;
    } else {
      comment.likesCount.value--;
    }
  }

  void toggleReplyInput(CommentModel comment) {
    comment.showReplyInput.value = !comment.showReplyInput.value;
  }

  void addReply(CommentModel comment, String text) {
    if (text.isEmpty) return;
    final newReply = CommentModel(
      id: DateTime.now().toString(),
      userName: "Current User",
      userImage: "https://i.pravatar.cc/150?u=me",
      text: text,
      timestamp: "Just now",
    );
    comment.replies.add(newReply);
    comment.showReplyInput.value = false;
  }

  void addMemberToCircle(CircleModel circle, MemberModel member) {
    debugPrint("Adding ${member.name} to ${circle.name}");
    // Simulate adding to circle
    circle.detailedMembers.add(member);
    circle.memberCount.value++;
    Get.snackbar("Success", "${member.name} added to circle");
    Get.back();
  }
}
