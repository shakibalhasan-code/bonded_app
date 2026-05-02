import 'package:get/get.dart';
import '../models/home_models.dart';
import '../services/socket_service.dart';

class HomeController extends GetxController {
  // Mock data for Circle Highlights using models
  final RxList<PostModel> circleHighlights = <PostModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
    // Initialize Socket Connection
    Get.find<SocketService>().initSocket();
  }

  void _loadMockData() {
    circleHighlights.addAll([
      PostModel(
        id: '1',
        userName: 'Weekend Hangouts Circle',
        userImage: 'https://i.pravatar.cc/150?u=aniyw',
        postText: 'Hey everyone, please give a warm welcome to our new members. Who will be working as office manager.',
        likesCount: 15,
        commentsCount: 3,
        comments: [
          CommentModel(
            id: 'c1',
            userName: 'Aniy Wilson',
            userImage: 'https://i.pravatar.cc/150?u=aniyw',
            text: 'Welcome! Really nice to meet you.',
            timestamp: '3 d',
            likesCount: 2,
          ),
        ],
      ),
      PostModel(
        id: '2',
        userName: 'Weekend Hangouts Circle',
        userImage: 'https://i.pravatar.cc/150?u=aniyw',
        postText: 'Another update from the weekend hangouts! Looking forward to seeing everyone there.',
        likesCount: 10,
        commentsCount: 1,
        comments: [
          CommentModel(
            id: 'c2',
            userName: 'John Doe',
            userImage: 'https://i.pravatar.cc/150?u=john',
            text: 'Can\'t wait!',
            timestamp: '1 d',
          ),
        ],
      ),
    ]);
  }

  // Interactivity Methods
  void toggleLikePost(PostModel post) {
    if (post.reactionType == null || post.reactionType.value != "none") {
      updatePostReaction(post, "none");
    } else {
      updatePostReaction(post, "like");
    }
  }

  void updatePostReaction(PostModel post, String type) {
    // If transitioning from none to a reaction
    if ((post.reactionType == null || post.reactionType.value == "none") && type != "none") {
      post.likesCount.value++;
      post.isLiked.value = true;
    }
    // If transitioning from a reaction to none
    else if (post.reactionType != null && post.reactionType.value != "none" && type == "none") {
      post.likesCount.value--;
      post.isLiked.value = false;
    }
    
    post.reactionType.value = type;
  }

  void toggleCommentInput(PostModel post) {
    post.isCommenting.toggle();
  }

  void addComment(PostModel post, String text) {
    if (text.isEmpty) return;
    
    final newComment = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: 'Me', // Placeholder for current user
      userImage: 'https://i.pravatar.cc/150?u=me',
      text: text,
      timestamp: 'Just now',
    );
    
    post.comments.add(newComment);
    post.commentsCount.value++;
    post.isCommenting.value = false;
  }

  void toggleLikeComment(CommentModel comment) {
    if (comment.isLiked.value) {
      comment.isLiked.value = false;
      comment.likesCount.value--;
    } else {
      comment.isLiked.value = true;
      comment.likesCount.value++;
    }
  }

  void toggleReplyInput(CommentModel comment) {
    comment.showReplyInput.toggle();
  }

  void addReply(CommentModel comment, String text) {
    if (text.isEmpty) return;
    
    final newReply = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: 'Me',
      userImage: 'https://i.pravatar.cc/150?u=me',
      text: text,
      timestamp: 'Just now',
    );
    
    comment.replies.add(newReply);
    comment.showReplyInput.value = false;
  }

  // Mock data for Upcoming Events
  final upcomingEvents = [
    {
      'title': 'National Music Festival',
      'date': 'Mon, Dec 25',
      'time': '18.00 - 23.00 PM',
      'location': '2464 Royal Ln. Mesa, New Jersey 45463',
      'image': 'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=500&q=80',
    },
    {
      'title': 'Jazz Music Fest',
      'date': 'Mon, Dec 26',
      'time': '18.00 - 23.00 PM',
      'location': '8502 Preston Rd. Inglewood, Maine 9809',
      'image': 'https://images.unsplash.com/photo-1511192336575-5a79af67a629?w=500&q=80',
    },
  ].obs;

  // Mock data for People You May Know
  final peopleRecommendations = [
    {
      'name': 'Matthias Huckestein',
      'bio': 'Brunch lover, Wine Nights, Gama Nights',
      'image': 'https://i.pravatar.cc/150?u=matthias',
    },
    {
      'name': 'Maike Rother',
      'bio': 'Brunch lover, Wine Nights, Gama Nights',
      'image': 'https://i.pravatar.cc/150?u=maike',
    },
  ].obs;
}
