// user_service.dart
import 'package:smart_ges_360/global/managers/dio_service.dart';

import '../model/user_model.dart';

class UserService {
  Future<UserDto> getCurrentUser() async {
    try {
      final response = await DioService.dio.get('/users/me');
      print(response);
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

  Future<void> updateUser(String userId, UserDto dto) async {
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

  Future<void> getRoles() async {
    try {
      await DioService.dio.delete('/users/roles');
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}
