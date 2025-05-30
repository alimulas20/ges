class ProfileModel {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final bool enabled;
  final List<String> groups;
  final Map<String, List<String>> attributes;

  ProfileModel({required this.id, required this.username, required this.email, required this.firstName, required this.lastName, required this.enabled, required this.groups, required this.attributes});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      enabled: json['enabled'] ?? false,
      groups: List<String>.from(json['groups'] ?? []),
      attributes: (json['attributes'] as Map<String, dynamic>? ?? {}).map((key, value) => MapEntry(key, List<String>.from(value))),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'email': email, 'firstName': firstName, 'lastName': lastName, 'enabled': enabled, 'groups': groups, 'attributes': attributes};
  }

  ProfileModel copyWith({String? username, String? email, String? firstName, String? lastName, bool? enabled, List<String>? groups, Map<String, List<String>>? attributes}) {
    return ProfileModel(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      enabled: enabled ?? this.enabled,
      groups: groups ?? this.groups,
      attributes: attributes ?? this.attributes,
    );
  }
}
