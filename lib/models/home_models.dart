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
  final String postText;
  final RxInt likesCount;
  final RxInt commentsCount;
  final RxBool isLiked;
  final RxBool isCommenting;
  final RxList<CommentModel> comments;

  PostModel({
    required this.id,
    required this.userName,
    required this.userImage,
    required this.postText,
    int likesCount = 0,
    int commentsCount = 0,
    bool isLiked = false,
    bool isCommenting = false,
    List<CommentModel>? comments,
  })  : likesCount = likesCount.obs,
        commentsCount = commentsCount.obs,
        isLiked = isLiked.obs,
        isCommenting = isCommenting.obs,
        comments = (comments ?? <CommentModel>[]).obs;
}
