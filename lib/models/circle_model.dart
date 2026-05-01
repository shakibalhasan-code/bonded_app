import 'package:get/get.dart';
import 'user_model.dart';
import 'home_models.dart';
import '../services/shared_prefs_service.dart';

class MemberModel {
  final String name;
  final String image;
  final String role;
  final bool isOwner;

  MemberModel({
    required this.name,
    required this.image,
    this.role = 'Member',
    required this.isOwner,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      name: json['name'] ?? '',
      image: json['image'] ?? 'https://i.pravatar.cc/150?u=${json['name']}',
      role: json['role'] ?? 'Member',
      isOwner: json['isOwner'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'role': role,
      'isOwner': isOwner,
    };
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
    this.image = 'https://images.unsplash.com/photo-1529156069898-49953e39b30f?w=800&q=80',
    bool isJoinedValue = false,
    this.isLocked = false,
    this.memberAvatars = const [],
    List<MemberModel>? members,
    List<PostModel>? postsList,
  }) : memberCount = memberCountValue.obs,
       postCount = postCountValue.obs,
       isJoined = isJoinedValue.obs,
       detailedMembers = (members ?? <MemberModel>[]).obs,
       posts = (postsList ?? <PostModel>[]).obs;

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
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      image: json['image'] ?? 'https://images.unsplash.com/photo-1529156069898-49953e39b30f?w=800&q=80',
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
