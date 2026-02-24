class AuthUser {
  final int id;
  final String username;
  final String inviteCode;
  final int? linkedPartnerId;
  final DateTime createdAt;

  AuthUser({
    required this.id,
    required this.username,
    required this.inviteCode,
    this.linkedPartnerId,
    required this.createdAt,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'],
      username: json['username'],
      inviteCode: json['invite_code'],
      linkedPartnerId: json['linked_partner_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'invite_code': inviteCode,
      'linked_partner_id': linkedPartnerId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
