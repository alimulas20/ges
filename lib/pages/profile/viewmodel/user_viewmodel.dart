// user_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../global/dtos/dropdown_dto.dart';
import '../../../global/managers/token_manager.dart';
import '../../../global/utils/alert_utils.dart';
import '../../plant/services/plant_service.dart';
import '../model/user_model.dart';
import '../service/user_service.dart';

class UserViewModel with ChangeNotifier {
  final UserService _service;
  final PlantService _plantService;

  UserViewModel(this._service, this._plantService);

  bool _isLoading = false;
  bool _isAdmin = false;
  bool _isSuperAdmin = false;
  String? _error;
  UserDto? _currentUser;
  List<PlantUsersDto> _plantUsers = [];
  List<RoleDto> _roles = [];
  bool get isLoading => _isLoading;
  bool get isAdmin => _isAdmin;
  bool get isSuperAdmin => _isSuperAdmin;
  String? get error => _error;
  UserDto? get currentUser => _currentUser;
  List<PlantUsersDto> get plantUsers => _plantUsers;
  List<RoleDto> get roles => _roles;
  List<DropdownDto> _plantsDropdown = [];
  List<DropdownDto> get plantsDropdown => _plantsDropdown;
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _service.getCurrentUser();
      final roles = await TokenManager.getRoles();
      _isAdmin = roles.contains('Manager');
      _isSuperAdmin = roles.contains('Admin');

      if (_isAdmin || _isSuperAdmin) {
        _plantUsers = await _service.getUsers();
        _roles = await _service.getRoles();
        await loadPlantsDropdown();
      }
    } catch (e) {
      _error = AlertUtils.formatErrorMessage(e);
      debugPrint('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await initialize();
  }

  Future<void> createUser(UserCreateDto dto) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.createUser(dto);
      await refresh();
    } catch (e) {
      _error = 'Kullanıcı oluşturulamadı: ${AlertUtils.formatErrorMessage(e)}';
      debugPrint('Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // In UserViewModel
  Future<void> updateUser(UserDto dto) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updateDto = UserUpdateDto.fromUser(dto);
      await _service.updateUser(dto.id, updateDto);
      await refresh();
    } catch (e) {
      _error = 'Kullanıcı güncellenemedi: ${AlertUtils.formatErrorMessage(e)}';
      debugPrint('Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.deleteUser(userId);
      await refresh();
    } catch (e) {
      _error = 'Kullanıcı silinemedi: ${AlertUtils.formatErrorMessage(e)}';
      debugPrint('Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserDto> getUserById(String userId) async {
    try {
      final user = await _service.getUserById(userId);
      return user;
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  List<RoleDto> get displayRoles {
    return _roles.where((role) => isSuperAdmin || role.key != 'SuperAdmin').toList();
  }

  // Key'e göre RoleDto bulma
  RoleDto getRoleByKey(String key) {
    return _roles.firstWhere((role) => role.key == key, orElse: () => RoleDto(key: key, value: key));
  }

  RoleDto getDefaultRole() {
    return _roles.first;
  }

  Future<String?> setProfilePicture(XFile file) async {
    _isLoading = true;
    notifyListeners();

    try {
      var url = await _service.setProfilePicture(file);
      _currentUser = await _service.getCurrentUser();
      return url ?? "";
    } catch (e) {
      _error = 'Profil resmi yüklenemedi: ${AlertUtils.formatErrorMessage(e)}';
      debugPrint('Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPlantsDropdown() async {
    if (_plantsDropdown.isNotEmpty) return; // Zaten yüklüyse tekrar yükleme

    _isLoading = true;
    notifyListeners();

    try {
      _plantsDropdown = await _plantService.getPlantsDropdown();
    } catch (e) {
      _error = 'Tesisler yüklenemedi: ${AlertUtils.formatErrorMessage(e)}';
      debugPrint('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to get plant name by ID
  String getPlantNameById(int id) {
    return _plantsDropdown.firstWhere((plant) => plant.id == id, orElse: () => DropdownDto(id: id, name: 'Unknown Plant')).name;
  }
}
