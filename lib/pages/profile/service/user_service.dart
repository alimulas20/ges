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

  Future<String?> setProfilePicture(dynamic file) async {
    try {
      FormData formData = FormData.fromMap({'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last)});
      var response = await DioService.dio.post<String>('/users/setProfileImage', data: formData);
      return response.data;
    } catch (e) {
      throw Exception('Failed to set profile picture: $e');
    }
  }

  static String _messageFromDio(DioException e, String fallback) {
    final data = e.response?.data;
    if (data == null) return fallback;
    if (data is String && data.isNotEmpty) return data.trim();
    if (data is Map) {
      if (data['error_description'] != null) return data['error_description'].toString();
      if (data['errorDescription'] != null) return data['errorDescription'].toString();
      if (data['message'] != null) return data['message'].toString();
      if (data['errorMessage'] != null) return data['errorMessage'].toString();
      if (data['error'] != null) return data['error'].toString();
    }
    return fallback;
  }

  /// Kullanıcının kendi şifresini değiştirmesi (mevcut + yeni şifre).
  /// [userId] Keycloak user id (UserDto.id) olmalıdır.
  Future<void> updateUserPassword(String userId, UserPasswordUpdateDto dto) async {
    try {
      await DioService.dio.put('/users/$userId/password', data: dto.toJson());
    } on DioException catch (e) {
      throw Exception(_messageFromDio(e, 'Şifre güncellenemedi. Lütfen şifre kurallarını kontrol edin.'));
    } catch (e) {
      throw Exception('Şifre güncellenemedi: $e');
    }
  }

  /// Admin/Manager: kullanıcı şifresini sıfırlama (sadece yeni şifre).
  /// [userId] Keycloak user id (UserDto.id) olmalıdır.
  Future<void> resetUserPassword(String userId, UserPasswordResetDto dto) async {
    try {
      await DioService.dio.put('/users/$userId/reset-password', data: dto.toJson());
    } on DioException catch (e) {
      throw Exception(_messageFromDio(e, 'Şifre sıfırlanamadı. Lütfen şifre kurallarını kontrol edin.'));
    } catch (e) {
      throw Exception('Şifre sıfırlanamadı: $e');
    }
  }
}
