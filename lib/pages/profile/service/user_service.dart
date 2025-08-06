// user_service.dart
import 'package:dio/dio.dart';

import '../../../global/managers/dio_service.dart';
import '../model/user_model.dart';

class UserService {
  Future<UserDto> getCurrentUser() async {
    try {
      final response = await DioService.dio.get('/users/me');
      return UserDto.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  Future<List<PlantUsersDto>> getUsers() async {
    try {
      final response = await DioService.dio.get('/users');
      return (response.data as List).map((e) => PlantUsersDto.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  Future<UserDto> createUser(UserCreateDto dto) async {
    try {
      final response = await DioService.dio.post('/users', data: dto.toJson());
      return UserDto.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // In UserService
  Future<void> updateUser(String userId, UserUpdateDto dto) async {
    try {
      await DioService.dio.put('/users/$userId', data: dto.toJson());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await DioService.dio.delete('/users/$userId');
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<void> setFirebaseToken(String token) async {
    try {
      await DioService.dio.get('/users/setFirebaseToken/$token');
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<List<RoleDto>> getRoles() async {
    try {
      final response = await DioService.dio.get('/users/roles');
      return (response.data as List).map((roleJson) => RoleDto.fromJson(roleJson)).toList();
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  Future<UserDto> getUserById(String userId) async {
    try {
      final response = await DioService.dio.get('/users/$userId');
      return UserDto.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  Future<void> setProfilePicture(dynamic file) async {
    try {
      FormData formData = FormData.fromMap({'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last)});
      await DioService.dio.post('/users/setProfileImage', data: formData);
    } catch (e) {
      throw Exception('Failed to set profile picture: $e');
    }
  }
}
