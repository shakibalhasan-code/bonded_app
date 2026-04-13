class MemberModel {
  final String id;
  final String name;
  final String image;
  final String role; // e.g., "Brunch lover, Wine Nights, Game Nights"

  MemberModel({
    required this.id,
    required this.name,
    required this.image,
    required this.role,
  });
}

class CircleModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final List<String> memberAvatars;
  final List<String> tags;
  final bool isLocked;
  final String? price;
  final bool isOwner;
  final bool isJoined;
  final String? address;
  final List<MemberModel>? detailedMembers;

  CircleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.memberAvatars,
    required this.tags,
    this.isLocked = false,
    this.price,
    this.isOwner = false,
    this.isJoined = false,
    this.address,
    this.detailedMembers,
  });
}
