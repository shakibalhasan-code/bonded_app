import 'package:get/get.dart';

enum BondStatus { nearby, requested, bonded }

class BondUserModel {
  final String id;
  final String name;
  final String email;
  final String image;
  final String username;
  final String gender;
  final String birthDate;
  final String connectionType;
  final String city;
  final String country;
  final String bio;
  final String location;
  final bool isVerified;
  final Map<String, List<String>> interests;
  final Rx<BondStatus> bondStatus;

  BondUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
    required this.username,
    required this.gender,
    required this.birthDate,
    required this.connectionType,
    required this.city,
    required this.country,
    required this.bio,
    required this.location,
    required this.interests,
    this.isVerified = false,
    BondStatus status = BondStatus.nearby,
  }) : bondStatus = status.obs;
}
