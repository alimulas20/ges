class UserDto {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final bool enabled;
  final List<UserPlantDto> plants;

  UserDto({required this.id, required this.username, required this.email, required this.firstName, required this.lastName, required this.enabled, required this.plants});

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      enabled: json['enabled'],
      plants: (json['plants'] as List).map((e) => UserPlantDto.fromJson(e)).toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'email': email, 'firstName': firstName, 'lastName': lastName, 'enabled': enabled, 'plants': plants.map((e) => e.toJson()).toList()};
  }
}

class UserPlantDto {
  final int plantId;
  final String? plantName;
  final String role;

  UserPlantDto({required this.plantId, this.plantName, required this.role});

  factory UserPlantDto.fromJson(Map<String, dynamic> json) {
    return UserPlantDto(plantId: json['plantId'], plantName: json['plantName'], role: json['role']);
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

class UserCreateDto {
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String password;
  final List<UserPlantDto> plants;

  UserCreateDto({required this.username, required this.email, required this.firstName, required this.lastName, required this.password, required this.plants});

  Map<String, dynamic> toJson() {
    return {'username': username, 'email': email, 'firstName': firstName, 'lastName': lastName, 'password': password, 'plants': plants.map((e) => e.toJson()).toList()};
  }
}

extension UserPlantDtoExtension on UserPlantDto {
  Map<String, dynamic> toJson() {
    return {'plantId': plantId, 'role': role};
  }
}
