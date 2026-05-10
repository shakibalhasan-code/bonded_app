import 'package:get/get.dart';
import 'user_model.dart';
import 'home_models.dart';
import 'event_model.dart';
import '../services/shared_prefs_service.dart';
import '../core/constants/app_endpoints.dart';

class MemberModel {
  final String id;
  final String userId;
  final String name;
  final String image;
  final String role;
  final bool isOwner;
  final bool isBonded;
  final String bondStatus; // none, accepted, pending_sent, pending_received

  MemberModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.image,
    this.role = 'Member',
    required this.isOwner,
    this.isBonded = false,
    this.bondStatus = 'none',
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    String name = "Unknown";
    String image = "https://i.pravatar.cc/150";
    String id = json['_id'] ?? '';
    String userId = "";

    if (user is Map) {
      name = user['fullName'] ?? "Unknown";
      image = AppUrls.imageUrl(user['avatar']);
      userId = user['_id'] ?? "";
    } else if (user is String) {
      userId = user;
    }

    return MemberModel(
      id: id,
      userId: userId,
      name: name,
      image: image,
      role: json['role'] ?? 'Member',
      isOwner: json['isCreator'] ?? false,
      isBonded: json['isBonded'] ?? false,
      bondStatus: json['bondStatus'] ?? 'none',
    );
  }
}

class CircleModel {
  final String id;
  final String slug;
  final String name;
  final String description;
  final String category;
  final List<String> hashtags;
  final List<Interest> interests;
  final String creator;
  final int densityThreshold;
  final bool isActive;
  final bool isDeleted;
  final bool isPaid;
  final int maxFreeMembers;
  final RxInt memberCount;
  final RxInt postCount;
  final int shareCount;
  final double price;
  final String tier;
  final String visibility;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;

  // UI Support Fields (Computed or from API)
  final String image;
  final RxBool isJoined;
  final bool isLocked;
  final List<String> memberAvatars;
  final RxList<MemberModel> detailedMembers;
  final RxList<PostModel> posts;
  final RxList<EventModel> events;

  CircleModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.category,
    required this.hashtags,
    required this.interests,
    required this.creator,
    required this.densityThreshold,
    required this.isActive,
    required this.isDeleted,
    required this.isPaid,
    required this.maxFreeMembers,
    int memberCountValue = 0,
    int postCountValue = 0,
    required this.shareCount,
    required this.price,
    required this.tier,
    required this.visibility,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
    this.image = 'https://images.unsplash.com/photo-1543269865-cbf427effbad?w=800&q=80',
    bool isJoinedValue = false,
    this.isLocked = false,
    this.memberAvatars = const [],
    List<MemberModel>? members,
    List<PostModel>? postsList,
    List<EventModel>? eventsList,
  }) : memberCount = memberCountValue.obs,
       postCount = postCountValue.obs,
       isJoined = isJoinedValue.obs,
       detailedMembers = (members ?? <MemberModel>[]).obs,
       posts = (postsList ?? <PostModel>[]).obs,
       events = (eventsList ?? <EventModel>[]).obs;

  bool get isOwner {
    final currentUserId = SharedPrefsService.getString('userId');
    return creator == currentUserId;
  }

  List<String> get tags => hashtags.map((h) => h.replaceAll('#', '')).toList();

  factory CircleModel.fromJson(Map<String, dynamic> json) {
    return CircleModel(
      id: json['_id'] ?? '',
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      hashtags: List<String>.from(json['hashtags'] ?? []),
      interests: (json['interests'] as List?)
              ?.map((i) => Interest.fromJson(i))
              .toList() ??
          [],
      creator: json['creator'] ?? '',
      densityThreshold: json['densityThreshold'] ?? 0,
      isActive: json['isActive'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      isPaid: json['isPaid'] ?? false,
      maxFreeMembers: json['maxFreeMembers'] ?? 0,
      memberCountValue: json['memberCount'] ?? 0,
      postCountValue: json['postCount'] ?? 0,
      shareCount: json['shareCount'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      tier: json['tier'] ?? '',
      visibility: json['visibility'] ?? '',
      address: json['address'] ?? 'Not Specified',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()).toLocal(),
      image: AppUrls.imageUrl(json['image'] ?? 'https://images.unsplash.com/photo-1543269865-cbf427effbad?w=800&q=80'),
      isJoinedValue: json['isJoined'] ?? false,
      isLocked: json['isLocked'] ?? false,
      memberAvatars: List<String>.from(json['memberAvatars'] ?? []),
      members: (json['members'] as List?)
              ?.map((m) => MemberModel.fromJson(m))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'slug': slug,
      'name': name,
      'description': description,
      'category': category,
      'hashtags': hashtags,
      'interests': interests.map((i) => i.toJson()).toList(),
      'creator': creator,
      'densityThreshold': densityThreshold,
      'isActive': isActive,
      'isDeleted': isDeleted,
      'isPaid': isPaid,
      'maxFreeMembers': maxFreeMembers,
      'memberCount': memberCount.value,
      'postCount': postCount.value,
      'shareCount': shareCount,
      'price': price,
      'tier': tier,
      'visibility': visibility,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'image': image,
      'isJoined': isJoined.value,
      'isLocked': isLocked,
      'memberAvatars': memberAvatars,
    };
  }
}
