import 'package:get/get.dart';
import '../core/constants/app_endpoints.dart';

class MediaModel {
  final String url;
  final String type;
  final String mimeType;
  final int size;
  final String? localFilePath;
  final bool isUploading;

  MediaModel({
    required this.url,
    required this.type,
    required this.mimeType,
    required this.size,
    this.localFilePath,
    this.isUploading = false,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      url: json['url'] ?? '',
      type: json['type'] ?? 'image',
      mimeType: json['mimeType'] ?? '',
      size: json['size'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'type': type,
      'mimeType': mimeType,
      'size': size,
      'localFilePath': localFilePath,
      'isUploading': isUploading,
    };
  }

  String get fullUrl {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return AppUrls.imageUrl(url);
  }
}

class CommentModel {
  final String id;
  final String userName;
  final String userImage;
  final String text;
  final String timestamp;
  final RxString reactionType;
  final RxBool isLiked;
  final RxInt likesCount;
  final RxList<CommentModel> replies;
  final RxBool showReplyInput;
  final String? parentPost;
  final int depth;
  final bool isAuthor;
  final List<MediaModel> media;
  final bool isUploading;

  CommentModel({
    required this.id,
    required this.userName,
    required this.userImage,
    required this.text,
    required this.timestamp,
    String reactionType = "none",
    bool isLiked = false,
    int likesCount = 0,
    List<CommentModel>? replies,
    bool showReplyInput = false,
    this.parentPost,
    this.depth = 0,
    this.isAuthor = false,
    this.media = const [],
    this.isUploading = false,
  })  : reactionType = reactionType.obs,
        isLiked = isLiked.obs,
        likesCount = likesCount.obs,
        replies = (replies ?? <CommentModel>[]).obs,
        showReplyInput = showReplyInput.obs;

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'];
    String userName = "Unknown";
    String userImage = "";
    
    if (author is Map) {
      userName = author['fullName'] ?? "Unknown";
      userImage = AppUrls.imageUrl(author['avatar']);
    } else if (author is String) {
      userName = "User $author";
    }

    return CommentModel(
      id: json['_id'] ?? '',
      userName: userName,
      userImage: userImage,
      text: json['content'] ?? '',
      timestamp: json['createdAt'] ?? '',
      likesCount: json['reactionCount'] ?? 0,
      isLiked: json['myReaction'] != null,
      reactionType: json['myReaction'] is String
          ? json['myReaction']
          : (json['myReaction'] is Map
              ? (json['myReaction']['reactionType'] ?? "none")
              : "none"),
      parentPost: json['parentPost'],
      depth: json['depth'] ?? 0,
      isAuthor: json['isAuthor'] ?? false,
      media: (json['media'] as List?)
              ?.map((m) => MediaModel.fromJson(m))
              .toList() ??
          [],
      replies: ((json['previewComments'] ?? json['replies']) as List?)
              ?.map((c) => CommentModel.fromJson(c))
              .toList() ??
          [],
    );
  }
}

class PostModel {
  final String id;
  final String userName;
  final String userImage;
  final String? userBio;
  final String postText;
  final List<String> images;
  final List<MediaModel> media;
  final RxInt likesCount;
  final RxInt commentsCount;
  final RxInt sharesCount;
  final RxBool isLiked;
  final RxString reactionType; // "none", "like", "love", "haha", "wow", "sad", "angry"
  final RxBool isCountPrivate;
  final RxBool isCommenting;
  final RxList<CommentModel> comments;
  final String? circleId;
  final DateTime? createdAt;
  final bool isUploading;

  PostModel({
    required this.id,
    required this.userName,
    required this.userImage,
    this.userBio,
    required this.postText,
    this.images = const [],
    this.media = const [],
    int likesCount = 0,
    int commentsCount = 0,
    int sharesCount = 0,
    bool isLiked = false,
    String reactionType = "none",
    bool isCountPrivate = false,
    bool isCommenting = false,
    List<CommentModel>? comments,
    this.circleId,
    this.createdAt,
    this.isUploading = false,
  })  : likesCount = likesCount.obs,
        commentsCount = commentsCount.obs,
        sharesCount = sharesCount.obs,
        isLiked = isLiked.obs,
        reactionType = reactionType.obs,
        isCountPrivate = isCountPrivate.obs,
        isCommenting = isCommenting.obs,
        comments = (comments ?? <CommentModel>[]).obs;

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'];
    String userName = "Unknown";
    String userImage = "";
    
    if (author is Map) {
      userName = author['fullName'] ?? "Unknown";
      userImage = AppUrls.imageUrl(author['avatar']);
    }

    final mediaList = (json['media'] as List?)
            ?.map((m) => MediaModel.fromJson(m))
            .toList() ??
        [];

    return PostModel(
      id: json['_id'] ?? '',
      userName: userName,
      userImage: userImage,
      postText: json['content'] ?? '',
      media: mediaList,
      images: mediaList
          .where((m) => m.type == 'image')
          .map((m) => m.fullUrl)
          .toList(),
      likesCount: json['reactionCount'] ?? 0,
      commentsCount: json['commentCount'] ?? 0,
      sharesCount: json['shareCount'] ?? 0,
      isLiked: json['myReaction'] != null,
      reactionType: json['myReaction'] is String
          ? json['myReaction']
          : (json['myReaction'] is Map
              ? (json['myReaction']['reactionType'] ?? "none")
              : "none"),
      circleId: json['circle'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      comments: (json['previewComments'] as List?)
              ?.map((c) => CommentModel.fromJson(c))
              .toList() ??
          [],
      isCountPrivate: false,
    );
  }
}
