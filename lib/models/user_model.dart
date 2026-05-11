import 'dart:convert';

class UserModel {
  final String id;
  final String authId;
  final String email;
  final String? fullName;
  final String? username;
  final String? bio;
  final String? avatar;
  final String? gender;
  final String? dateOfBirth;
  final String? phone;
  final String? phoneCountryCode;
  final String? country;
  final String? city;
  final String? address;
  final List<Interest>? interests;
  final Location? location;
  final String subscriptionTier;
  final String selfieVerification;
  final String documentVerification;
  final bool profileCompleted;
  final bool isBlocked;
  final bool isDeleted;
  final double averageRating;
  final int reviewCount;
  final UserPreferences? preferences;
  final List<String>? connectionType;
  final String? visibility;
  final String? stripeConnectAccountId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? subscriptionStatus;

  bool get isPro => subscriptionTier.toLowerCase() == 'pro' || subscriptionStatus == 'active';

  UserModel({
    required this.id,
    required this.authId,
    required this.email,
    this.fullName,
    this.username,
    this.bio,
    this.avatar,
    this.gender,
    this.dateOfBirth,
    this.phone,
    this.phoneCountryCode,
    this.country,
    this.city,
    this.address,
    this.interests,
    this.location,
    required this.subscriptionTier,
    required this.selfieVerification,
    required this.documentVerification,
    required this.profileCompleted,
    required this.isBlocked,
    required this.isDeleted,
    required this.averageRating,
    required this.reviewCount,
    this.preferences,
    this.connectionType,
    this.visibility,
    this.stripeConnectAccountId,
    this.createdAt,
    this.updatedAt,
    this.subscriptionStatus,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      authId: json['auth'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'],
      username: json['username'],
      bio: json['bio'],
      avatar: json['avatar'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      phone: json['phone'],
      phoneCountryCode: json['phoneCountryCode'],
      country: json['country'],
      city: json['city'],
      address: json['address'],
      interests: json['interests'] != null
          ? (json['interests'] as List)
              .map((i) => Interest.fromJson(i))
              .toList()
          : null,
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
      subscriptionTier: json['subscriptionTier'] ?? 'free',
      selfieVerification: json['selfieVerification'] ?? 'unverified',
      documentVerification: json['documentVerification'] ?? 'unverified',
      profileCompleted: json['profileCompleted'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      preferences: json['preferences'] != null
          ? UserPreferences.fromJson(json['preferences'])
          : null,
      connectionType: json['connectionType'] != null
          ? List<String>.from(json['connectionType'])
          : null,
      visibility: json['visibility'],
      stripeConnectAccountId: json['stripeConnectAccountId'],
      subscriptionStatus: json['subscriptionStatus'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt']).toLocal()
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt']).toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'auth': authId,
      'email': email,
      'fullName': fullName,
      'username': username,
      'bio': bio,
      'avatar': avatar,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'phone': phone,
      'phoneCountryCode': phoneCountryCode,
      'country': country,
      'city': city,
      'address': address,
      'interests': interests?.map((i) => i.toJson()).toList(),
      'location': location?.toJson(),
      'subscriptionTier': subscriptionTier,
      'selfieVerification': selfieVerification,
      'documentVerification': documentVerification,
      'profileCompleted': profileCompleted,
      'isBlocked': isBlocked,
      'isDeleted': isDeleted,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'preferences': preferences?.toJson(),
      'connectionType': connectionType,
      'visibility': visibility,
      'stripeConnectAccountId': stripeConnectAccountId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class Interest {
  final String id;
  final String name;
  final String slug;
  final String category;
  final bool isActive;

  Interest({
    required this.id,
    required this.name,
    required this.slug,
    required this.category,
    required this.isActive,
  });

  factory Interest.fromJson(dynamic json) {
    if (json is String) {
      return Interest(
        id: json,
        name: '',
        slug: '',
        category: '',
        isActive: true,
      );
    }
    return Interest(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      category: json['category'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'slug': slug,
      'category': category,
      'isActive': isActive,
    };
  }
}

class Location {
  final String type;
  final List<double> coordinates;

  Location({
    required this.type,
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'] ?? 'Point',
      coordinates: json['coordinates'] != null
          ? List<double>.from(json['coordinates'].map((x) => x.toDouble()))
          : [0.0, 0.0],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}

class UserPreferences {
  final bool notifications;
  final bool emailUpdates;
  final bool locationSharing;

  UserPreferences({
    required this.notifications,
    required this.emailUpdates,
    required this.locationSharing,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      notifications: json['notifications'] ?? true,
      emailUpdates: json['emailUpdates'] ?? true,
      locationSharing: json['locationSharing'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications,
      'emailUpdates': emailUpdates,
      'locationSharing': locationSharing,
    };
  }
}
