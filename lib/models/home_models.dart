import 'package:get/get.dart';

class CommentModel {
  final String id;
  final String userName;
  final String userImage;
  final String text;
  final String timestamp;
  final RxBool isLiked;
  final RxInt likesCount;
  final RxList<CommentModel> replies;
  final RxBool showReplyInput;

  CommentModel({
    required this.id,
    required this.userName,
    required this.userImage,
    required this.text,
    required this.timestamp,
    bool isLiked = false,
    int likesCount = 0,
    List<CommentModel>? replies,
    bool showReplyInput = false,
  })  : isLiked = isLiked.obs,
        likesCount = likesCount.obs,
        replies = (replies ?? <CommentModel>[]).obs,
        showReplyInput = showReplyInput.obs;
}

class PostModel {
  final String id;
  final String userName;
  final String userImage;
  final String? userBio;
  final String postText;
  final List<String> images;
  final RxInt likesCount;
  final RxInt commentsCount;
  final RxInt sharesCount;
  final RxBool isLiked;
  final RxString reactionType; // "none", "like", "love", "care", "haha", "wow", "sad", "angry"
  final RxBool isCountPrivate;
  final RxBool isCommenting;
  final RxList<CommentModel> comments;

  PostModel({
    required this.id,
    required this.userName,
    required this.userImage,
    this.userBio,
    required this.postText,
    this.images = const [],
    int likesCount = 0,
    int commentsCount = 0,
    int sharesCount = 0,
    bool isLiked = false,
    String reactionType = "none",
    bool isCountPrivate = true,
    bool isCommenting = false,
    List<CommentModel>? comments,
  })  : likesCount = likesCount.obs,
        commentsCount = commentsCount.obs,
        sharesCount = sharesCount.obs,
        isLiked = isLiked.obs,
        reactionType = reactionType.obs,
        isCountPrivate = isCountPrivate.obs,
        isCommenting = isCommenting.obs,
        comments = (comments ?? <CommentModel>[]).obs;
}

