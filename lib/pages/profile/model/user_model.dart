// user_model.dart
class UserDto {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final bool enabled;
  final String? role;
  final List<UserPlantDto> plants;

  UserDto({required this.id, required this.username, required this.email, required this.firstName, required this.lastName, required this.enabled, required this.role, required this.plants});

  factory UserDto.fromJson(Map<String, dynamic> json) {
    print(json);
    return UserDto(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      enabled: json['enabled'],
      role: json['role'],
      plants: (json['plants'] as List).map((e) => UserPlantDto.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'email': email, 'firstName': firstName, 'lastName': lastName, 'enabled': enabled, 'role': role, 'plants': plants.map((e) => e.toJson()).toList()};
  }

  UserDto copyWith({String? firstName, String? lastName, String? email, String? role, List<UserPlantDto>? plants}) {
    return UserDto(
      id: id,
      username: username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      enabled: enabled,
      role: role ?? this.role,
      plants: plants ?? this.plants,
    );
  }
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
    print("deneme");
    return PlantUsersDto(plantId: json['plantId'], plantName: json['plantName'], users: (json['users'] as List).map((e) => UserDto.fromJson(e)).toList());
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

  UserCreateDto({required this.username, required this.email, required this.firstName, required this.lastName, required this.password, required this.role, required this.plantIds});

  Map<String, dynamic> toJson() {
    return {'username': username, 'email': email, 'firstName': firstName, 'lastName': lastName, 'password': password, 'role': role, 'plantIds': plantIds};
  }
}
