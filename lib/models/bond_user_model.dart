import 'package:get/get.dart';
import 'user_model.dart';

enum BondStatus { nearby, requested, bonded, pending }

class BondConnectionModel {
  final String? bondId;
  final String? status;
  final DateTime? requestedAt;
  final DateTime? bondedAt;
  final UserModel user;

  BondConnectionModel({
    this.bondId,
    this.status,
    this.requestedAt,
    this.bondedAt,
    required this.user,
  });

  factory BondConnectionModel.fromJson(Map<String, dynamic> json) {
    return BondConnectionModel(
      bondId: json['bondId'],
      status: json['status'],
      requestedAt: json['requestedAt'] != null ? DateTime.parse(json['requestedAt']) : null,
      bondedAt: json['bondedAt'] != null ? DateTime.parse(json['bondedAt']) : null,
      user: UserModel.fromJson(json['user'] ?? json),
    );
  }
}
