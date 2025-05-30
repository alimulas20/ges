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
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(ProfileModel updatedProfile, BuildContext context) async {
    try {
      await _service.updateProfile(updatedProfile, context);
      if (currentProfile?.id == updatedProfile.id) {
        currentProfile = updatedProfile;
      } else {
        final index = profiles.indexWhere((p) => p.id == updatedProfile.id);
        if (index != -1) profiles[index] = updatedProfile;
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
