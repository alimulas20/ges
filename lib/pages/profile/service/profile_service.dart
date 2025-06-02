import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../global/managers/dio_service.dart';
import '../../../global/managers/token_manager.dart';
import '../model/profile_model.dart';

class ProfileService {
  static const String _usersPath = '/users';

  Future<List<ProfileModel>> getUsers(BuildContext context) async {
    try {
      final response = await DioService.keyCloak.get(_usersPath);
      final List<dynamic> usersJson = response.data;
      return usersJson.map((json) => ProfileModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Yetkiniz yok: Kullanıcı listesini görüntüleme izniniz bulunmamaktadır');
      }
      throw Exception('Kullanıcılar alınırken hata oluştu: ${e.message}');
    }
  }

  Future<Map<String, List<ProfileModel>>> getUsersGroupedByGroupName(BuildContext context) async {
    try {
      final userId = await TokenManager.getUserId();

      final groupResponse = await DioService.keyCloak.get('/users/$userId/groups');
      final List<dynamic> groupsJson = groupResponse.data;

      Map<String, List<ProfileModel>> groupedUsers = {};

      for (var group in groupsJson) {
        final String groupId = group['id'];
        final String groupName = group['name'];

        final response = await DioService.keyCloak.get('/groups/$groupId/members');
        final List<dynamic> membersJson = response.data;
        final members = membersJson.map((json) => ProfileModel.fromJson(json)).toList();

        groupedUsers[groupName] = members;
      }

      return groupedUsers;
    } on DioException catch (e) {
      throw Exception('Gruplar alınırken hata oluştu: ${e.message}');
    }
  }

  Future<ProfileModel> getCurrentProfile(BuildContext context) async {
    final userId = await TokenManager.getUserId();
    if (userId == null) {
      throw Exception('Kullanıcı oturumu bulunamadı');
    }
    return getProfile(userId, context);
  }

  Future<ProfileModel> getProfile(String userId, BuildContext context) async {
    try {
      final response = await DioService.keyCloak.get('$_usersPath/$userId');
      return ProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Profil bilgileri alınırken hata oluştu: ${e.message}');
    }
  }

  Future<void> updateProfile(ProfileModel profile, BuildContext context) async {
    try {
      await DioService.keyCloak.put('$_usersPath/${profile.id}', data: profile.toJson());
    } on DioException catch (e) {
      throw Exception('Profil güncellenirken hata oluştu: ${e.message}');
    }
  }

  // Ekstra profil işlemleri buraya eklenebilir
  Future<void> changePassword(String userId, String currentPassword, String newPassword, BuildContext context) async {
    try {
      await DioService.keyCloak.put('$_usersPath/$userId/reset-password', data: {'type': 'password', 'value': newPassword, 'temporary': false});
    } on DioException catch (e) {
      throw Exception('Şifre değiştirilirken hata oluştu: ${e.message}');
    }
  }
}
