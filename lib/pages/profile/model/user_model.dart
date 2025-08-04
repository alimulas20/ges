// user_model.dart
class UserDto {
  final String id;
  final int localId;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final bool enabled;
  final String? role;
  final List<UserPlantDto> plants;
  final String? phone;
  final bool receivePush;
  final bool receiveMail;
  final bool receiveSMS;
  final String profilePictureUrl;

  UserDto({
    required this.id,
    required this.localId,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.enabled,
    required this.role,
    required this.plants,
    this.phone,
    this.receivePush = true,
    this.receiveMail = true,
    this.receiveSMS = false,
    this.profilePictureUrl = '',
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'],
      localId: json['localId'] ?? 0,
      username: json['username'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      enabled: json['enabled'],
      role: json['role'],
      plants: (json['plants'] as List).map((e) => UserPlantDto.fromJson(e)).toList(),
      phone: json['phone'],
      receivePush: json['receivePush'] ?? true,
      receiveMail: json['receiveMail'] ?? true,
      receiveSMS: json['receiveSMS'] ?? false,
      profilePictureUrl: json['profilePictureUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'localId': localId,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'enabled': enabled,
      'role': role,
      'plants': plants.map((e) => e.toJson()).toList(),
      'phone': phone,
      'receivePush': receivePush,
      'receiveMail': receiveMail,
      'receiveSMS': receiveSMS,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  UserDto copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? role,
    List<UserPlantDto>? plants,
    String? phone,
    bool? receivePush,
    bool? receiveMail,
    bool? receiveSMS,
    String? profilePictureUrl,
  }) {
    return UserDto(
      id: id,
      localId: localId,
      username: username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      enabled: enabled,
      role: role ?? this.role,
      plants: plants ?? this.plants,
      phone: phone ?? this.phone,
      receivePush: receivePush ?? this.receivePush,
      receiveMail: receiveMail ?? this.receiveMail,
      receiveSMS: receiveSMS ?? this.receiveSMS,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }
}

class UserCreateDto {
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String password;
  final String role;
  final List<int> plantIds;
  final String? phone;
  final bool receivePush;
  final bool receiveMail;
  final bool receiveSMS;

  UserCreateDto({
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.role,
    required this.plantIds,
    this.phone,
    this.receivePush = true,
    this.receiveMail = true,
    this.receiveSMS = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'password': password,
      'role': role,
      'plantIds': plantIds,
      'phone': phone,
      'receivePush': receivePush,
      'receiveMail': receiveMail,
      'receiveSMS': receiveSMS,
    };
  }
}

// Add to user_model.dart
class UserUpdateDto {
  final String firstName;
  final String lastName;
  final String email;
  final String? role;
  final List<int> plantIds;
  final String? phone;
  final bool receivePush;
  final bool receiveMail;
  final bool receiveSMS;

  UserUpdateDto({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.role,
    required this.plantIds,
    this.phone,
    required this.receivePush,
    required this.receiveMail,
    required this.receiveSMS,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      if (role != null) 'role': role,
      'plantIds': plantIds,
      if (phone != null) 'phone': phone,
      'receivePush': receivePush,
      'receiveMail': receiveMail,
      'receiveSMS': receiveSMS,
    };
  }

  factory UserUpdateDto.fromUser(UserDto user) {
    return UserUpdateDto(
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      role: user.role,
      plantIds: user.plants.map((e) => e.plantId).toList(),
      phone: user.phone,
      receivePush: user.receivePush,
      receiveMail: user.receiveMail,
      receiveSMS: user.receiveSMS,
    );
  }
}

// Add this new class for file upload
class FileUploadDto {
  final dynamic file; // This will be a MultipartFile in the service

  FileUploadDto({required this.file});
}

class UserPlantDto {
  final int plantId;
  final String? plantName;

  UserPlantDto({required this.plantId, this.plantName});

  factory UserPlantDto.fromJson(Map<String, dynamic> json) {
    return UserPlantDto(plantId: json['plantId'], plantName: json['plantName']);
  }

  Map<String, dynamic> toJson() {
    return {'plantId': plantId, 'plantName': plantName};
  }
}

class PlantUsersDto {
  final int plantId;
  final String plantName;
  final List<UserDto> users;

  PlantUsersDto({required this.plantId, required this.plantName, required this.users});

  factory PlantUsersDto.fromJson(Map<String, dynamic> json) {
    return PlantUsersDto(plantId: json['plantId'], plantName: json['plantName'], users: (json['users'] as List).map((e) => UserDto.fromJson(e)).toList());
  }
}

class RoleDto {
  final String key;
  final String value;
  @override
  String toString() => value; // Dropdown'da görüntülenecek değer

  @override
  bool operator ==(Object other) => identical(this, other) || other is RoleDto && runtimeType == other.runtimeType && key == other.key;

  @override
  int get hashCode => key.hashCode;
  RoleDto({required this.key, required this.value});

  factory RoleDto.fromJson(Map<String, dynamic> json) {
    return RoleDto(key: json['key'], value: json['value']);
  }

  Map<String, dynamic> toJson() {
    return {'key': key, 'value': value};
  }
}
