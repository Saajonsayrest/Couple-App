import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String nickname;

  @HiveField(2)
  String gender; // 'male' or 'female'

  @HiveField(3)
  DateTime birthday;

  @HiveField(4)
  String? avatarPath;

  @HiveField(5)
  DateTime? relationshipStartDate;

  @HiveField(6)
  bool isPartner; // true if this profile represents the partner

  UserProfile({
    required this.name,
    required this.nickname,
    required this.gender,
    required this.birthday,
    this.avatarPath,
    this.relationshipStartDate,
    this.isPartner = false,
  });
}
