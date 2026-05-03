import 'dart:convert';
import 'dart:io';
import 'package:bonded_app/models/event_model.dart';
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
    return publicCircles
        .where(
          (c) =>
              c.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
              c.description.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ),
        )
        .toList();
  }

  List<CircleModel> get filteredPrivateCircles {
    if (searchQuery.value.isEmpty) return privateCircles;
    return privateCircles
        .where(
          (c) =>
              c.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
              c.description.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ),
        )
        .toList();
  }

  List<CircleModel> get filteredMyCreatedCircles {
    if (searchQuery.value.isEmpty) return createdCircles;
    return createdCircles
        .where(
          (c) =>
              c.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
              c.description.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ),
        )
        .toList();
  }

  List<CircleModel> get filteredMyJoinedCircles {
    if (searchQuery.value.isEmpty) return joinedCircles;
    return joinedCircles
        .where(
          (c) =>
              c.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
              c.description.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ),
        )
        .toList();
  }

  // Members related state
  var availableMembers = <MemberModel>[
    MemberModel(
      id: "1",
      name: "John Doe",
      image: "https://i.pravatar.cc/150?u=john",
      isOwner: false,
    ),
    MemberModel(
      id: "2",
      name: "Jane Smith",
      image: "https://i.pravatar.cc/150?u=jane",
      isOwner: false,
    ),
    MemberModel(
      id: "3",
      name: "Mike Johnson",
      image: "https://i.pravatar.cc/150?u=mike",
      isOwner: false,
    ),
    MemberModel(
      id: "4",
      name: "Sarah Williams",
      image: "https://i.pravatar.cc/150?u=sarah",
      isOwner: false,
    ),
    MemberModel(
      id: "5",
      name: "David Brown",
      image: "https://i.pravatar.cc/150?u=david",
      isOwner: false,
    ),
  ].obs;

  List<MemberModel> get filteredAvailableMembers {
    if (searchQuery.value.isEmpty) return availableMembers;
    return availableMembers
        .where(
          (m) => m.name.toLowerCase().contains(searchQuery.value.toLowerCase()),
        )
        .toList();
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
        final circles = circlesJson
            .map((c) => CircleModel.fromJson(c))
            .toList();

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
        files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            contentType: MediaType(mimeParts.first, mimeParts[1]),
          ),
        );
      }

      final response = await _apiService.multipartRequest(
        'POST',
        AppUrls.circles,
        headers: {'Authorization': 'Bearer $token'},
        fields: {'data': jsonEncode(circleData)},
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
      String errorMessage = e.toString();
      if (errorMessage.startsWith('ApiException: ')) {
        errorMessage = errorMessage.replaceFirst('ApiException: ', '');
      }
      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
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

  void _updateCircleList(
    String? visibility,
    String? scope,
    List<CircleModel> circles,
  ) {
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

  Future<void> fetchCircleFeed(CircleModel circle) async {
    try {
      final token = SharedPrefsService.getString('accessToken');
      final url = AppUrls.circleFeed(circle.id);

      final response = await _apiService.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> postsJson = data['data'];
        final posts = postsJson.map((p) => PostModel.fromJson(p)).toList();
        circle.posts.assignAll(posts);
      }
    } catch (e) {
      debugPrint("Error fetching circle feed: $e");
    }
  }

  Future<void> fetchCircleMembers(CircleModel circle) async {
    try {
      final token = SharedPrefsService.getString('accessToken');
      final url = AppUrls.circleMembers(circle.id);

      final response = await _apiService.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> membersJson = data['data'];
        final members = membersJson
            .map((m) => MemberModel.fromJson(m))
            .toList();
        circle.detailedMembers.assignAll(members);
      }
    } catch (e) {
      debugPrint("Error fetching circle members: $e");
    }
  }

  Future<void> fetchCircleEvents(CircleModel circle) async {
    try {
      final token = SharedPrefsService.getString('accessToken');
      final url = AppUrls.circleEvents(circle.id);

      final response = await _apiService.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> eventsJson = data['data'];
        final events = eventsJson.map((e) => EventModel.fromJson(e)).toList();
        circle.events.assignAll(events);
      }
    } catch (e) {
      debugPrint("Error fetching circle events: $e");
    }
  }

  Future<void> _reactToId(
    String id,
    RxString reactionTypeObs,
    RxBool isLikedObs,
    RxInt likesCountObs, {
    String? specificType,
  }) async {
    final originalType = reactionTypeObs.value;
    final originalIsLiked = isLikedObs.value;
    final originalCount = likesCountObs.value;

    try {
      final token = SharedPrefsService.getString('accessToken');
      final url = AppUrls.reactPost(id);

      // Determine new state
      final bool wasLiked = originalIsLiked;
      final String nextType = specificType ?? (wasLiked ? "none" : "like");

      http.Response response;
      if (nextType == "none") {
        response = await _apiService.delete(
          url,
          headers: {'Authorization': 'Bearer $token'},
        );
      } else {
        response = await _apiService.post(
          url,
          headers: {'Authorization': 'Bearer $token'},
          body: {'reactionType': nextType},
        );
      }

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        reactionTypeObs.value = nextType;
        if (nextType == "none") {
          isLikedObs.value = false;
          if (likesCountObs.value > 0) likesCountObs.value--;
        } else {
          if (!isLikedObs.value) {
            likesCountObs.value++;
          }
          isLikedObs.value = true;
        }
      }
    } catch (e) {
      debugPrint("Error reacting: $e");
      // Rollback
      reactionTypeObs.value = originalType;
      isLikedObs.value = originalIsLiked;
      likesCountObs.value = originalCount;
    }
  }

  Future<void> updatePostReaction(PostModel post, String type) async {
    try {
      final token = SharedPrefsService.getString('accessToken');
      final url = AppUrls.reactPost(post.id);

      http.Response response;
      if (type == "none") {
        response = await _apiService.delete(
          url,
          headers: {'Authorization': 'Bearer $token'},
        );
      } else {
        response = await _apiService.post(
          url,
          headers: {'Authorization': 'Bearer $token'},
          body: {'reactionType': type},
        );
      }

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        post.reactionType.value = type;
        if (type == "none") {
          post.isLiked.value = false;
          if (post.likesCount.value > 0) post.likesCount.value--;
        } else {
          if (!post.isLiked.value) post.likesCount.value++;
          post.isLiked.value = true;
        }
      }
    } catch (e) {
      debugPrint("Error updating reaction: $e");
    }
  }

  Future<void> sharePost(CircleModel circle, PostModel post) async {
    try {
      setLoading(true);
      final token = SharedPrefsService.getString('accessToken');
      final url = AppUrls.sharePost(post.id);

      final response = await _apiService.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        // Refresh feed auto
        fetchCircleFeed(circle);
        Get.snackbar("Success", "Post shared successfully");
      }
    } catch (e) {
      debugPrint("Error sharing post: $e");
      Get.snackbar("Error", "Failed to share post");
    } finally {
      setLoading(false);
    }
  }

  Future<void> addCommentToPost({
    required CircleModel circle,
    required PostModel post,
    required String content,
    String? parentPostId,
    File? imageFile,
    File? videoFile,
  }) async {
    try {
      setLoading(true);
      final token = SharedPrefsService.getString('accessToken');
      final url = AppUrls.commentPost(circle.id, parentPostId ?? post.id);

      final List<http.MultipartFile> files = [];
      if (imageFile != null) {
        final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
        final mimeParts = mimeType.split('/');
        files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            contentType: MediaType(mimeParts.first, mimeParts[1]),
          ),
        );
      }
      if (videoFile != null) {
        final mimeType = lookupMimeType(videoFile.path) ?? 'video/mp4';
        final mimeParts = mimeType.split('/');
        files.add(
          await http.MultipartFile.fromPath(
            'video',
            videoFile.path,
            contentType: MediaType(mimeParts.first, mimeParts[1]),
          ),
        );
      }

      final Map<String, dynamic> bodyData = {'content': content};

      final response = await _apiService.multipartRequest(
        'POST',
        url,
        headers: {'Authorization': 'Bearer $token'},
        fields: {'data': jsonEncode(bodyData)},
        files: files,
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        fetchCircleFeed(circle);
        post.isCommenting.value = false;
        Get.snackbar("Success", "Comment added successfully");
      }
    } catch (e) {
      debugPrint("Error adding comment: $e");
      Get.snackbar("Error", "Failed to add comment");
    } finally {
      setLoading(false);
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

  Future<void> createCirclePost({
    required CircleModel circle,
    required String content,
    List<File>? images,
    File? video,
  }) async {
    try {
      setLoading(true);
      final token = SharedPrefsService.getString('accessToken');
      final url = '${AppUrls.circles}/${circle.id}/posts';

      final List<http.MultipartFile> files = [];
      if (images != null) {
        for (var image in images) {
          final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
          final mimeParts = mimeType.split('/');
          files.add(
            await http.MultipartFile.fromPath(
              'images',
              image.path,
              contentType: MediaType(mimeParts.first, mimeParts[1]),
            ),
          );
        }
      }
      if (video != null) {
        final mimeType = lookupMimeType(video.path) ?? 'video/mp4';
        final mimeParts = mimeType.split('/');
        files.add(
          await http.MultipartFile.fromPath(
            'video',
            video.path,
            contentType: MediaType(mimeParts.first, mimeParts[1]),
          ),
        );
      }

      final response = await _apiService.multipartRequest(
        'POST',
        url,
        headers: {'Authorization': 'Bearer $token'},
        fields: {
          'data': jsonEncode({'content': content}),
        },
        files: files,
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        fetchCircleFeed(circle);
        Get.back(); // Close sheet
        Get.snackbar("Success", "Post created successfully");
      }
    } catch (e) {
      debugPrint("Error creating post: $e");
      Get.snackbar("Error", "Failed to create post");
    } finally {
      setLoading(false);
    }
  }

  void toggleLikePost(PostModel post) {
    _reactToId(post.id, post.reactionType, post.isLiked, post.likesCount);
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

  // This is handled by updatePostReaction now

  void toggleLikeComment(CommentModel comment) {
    _reactToId(
      comment.id,
      comment.reactionType,
      comment.isLiked,
      comment.likesCount,
    );
  }

  void updateCommentReaction(CommentModel comment, String type) {
    _reactToId(
      comment.id,
      comment.reactionType,
      comment.isLiked,
      comment.likesCount,
      specificType: type,
    );
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
