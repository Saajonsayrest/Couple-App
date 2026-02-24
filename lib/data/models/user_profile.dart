import 'package:hive/hive.dart';

class UserProfile {
  String name;
  String nickname;
  String gender; // 'male' or 'female'
  DateTime birthday;
  String? avatarPath;
  DateTime? relationshipStartDate;
  bool isPartner; // true if this profile represents the partner
  int? serverId;

  UserProfile({
    required this.name,
    required this.nickname,
    required this.gender,
    required this.birthday,
    this.avatarPath,
    this.relationshipStartDate,
    this.isPartner = false,
    this.serverId,
  });

  String? get avatarUrl {
    if (avatarPath == null) return null;
    if (avatarPath!.startsWith('http') ||
        avatarPath!.startsWith('/Users') ||
        avatarPath!.startsWith('/data')) {
      return avatarPath;
    }
    // Relative path from server
    final cleanPath = avatarPath!.startsWith('/') ? avatarPath : '/$avatarPath';
    return 'https://couple-app-backend.vercel.app$cleanPath';
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nickname': nickname,
      'gender': gender,
      'birthday': birthday.toIso8601String(),
      'avatarPath': avatarPath,
      'relationshipStartDate': relationshipStartDate?.toIso8601String(),
      'isPartner': isPartner,
      'serverId': serverId,
    };
  }

  factory UserProfile.fromMap(Map<dynamic, dynamic> map) {
    return UserProfile(
      name: map['name'] as String,
      nickname: map['nickname'] as String,
      gender: map['gender'] as String,
      birthday: DateTime.parse(map['birthday'] as String),
      avatarPath: map['avatarPath'] as String?,
      relationshipStartDate: map['relationshipStartDate'] != null
          ? DateTime.parse(map['relationshipStartDate'] as String)
          : null,
      isPartner: map['isPartner'] as bool? ?? false,
      serverId: map['serverId'] as int?,
    );
  }
}

// Manual Hive Adapter to keep things working without code gen
class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 0;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      name: fields[0] as String,
      nickname: fields[1] as String,
      gender: fields[2] as String,
      birthday: fields[3] as DateTime,
      avatarPath: fields[4] as String?,
      relationshipStartDate: fields[5] as DateTime?,
      isPartner: fields[6] as bool,
      serverId: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.nickname)
      ..writeByte(2)
      ..write(obj.gender)
      ..writeByte(3)
      ..write(obj.birthday)
      ..writeByte(4)
      ..write(obj.avatarPath)
      ..writeByte(5)
      ..write(obj.relationshipStartDate)
      ..writeByte(6)
      ..write(obj.isPartner)
      ..writeByte(7)
      ..write(obj.serverId);
  }
}
