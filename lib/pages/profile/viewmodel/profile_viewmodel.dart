import 'package:flutter/material.dart';
import 'package:smart_ges_360/global/managers/token_manager.dart';
import '../model/profile_model.dart';
import '../service/profile_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileService _service;

  ProfileViewModel(this._service);

  bool isLoading = false;
  String? error;
  ProfileModel? currentProfile;
  List<ProfileModel> profiles = [];
  Map<String, List<ProfileModel>> groupedUsers = {};
  bool isGroupsLoading = false;

  bool isAdmin = false;

  Future<void> initialize(BuildContext context) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      currentProfile = await _service.getCurrentProfile(context);
      isAdmin = await TokenManager.getIsAdmin();
      if (isAdmin) {
        profiles = await _service.getUsers(context);
        // Gruplar ayrı yükleniyor
        _loadGroups(context);
      }
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _loadGroups(BuildContext context) async {
    isGroupsLoading = true;
    notifyListeners();

    try {
      groupedUsers = await _service.getUsersGroupedByGroupName(context);
    } catch (e) {
      error = 'Grup verileri alınamadı: $e';
    }

    isGroupsLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile(ProfileModel updatedProfile, BuildContext context) async {
    try {
      await _service.updateProfile(updatedProfile, context);

      // groupedUsers içindeki kullanıcıyı güncelle
      groupedUsers.forEach((groupName, users) {
        final index = users.indexWhere((u) => u.id == updatedProfile.id);
        if (index != -1) {
          users[index] = updatedProfile;
        }
      });

      if (currentProfile?.id == updatedProfile.id) {
        currentProfile = updatedProfile;
      }

      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword, BuildContext context) async {
    if (currentProfile == null) return;
    try {
      await _service.changePassword(currentProfile!.id, currentPassword, newPassword, context);
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}
