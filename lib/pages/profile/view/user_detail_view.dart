import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../global/managers/token_manager.dart';
import '../model/user_model.dart';
import '../viewmodel/user_viewmodel.dart';

class UserDetailView extends StatefulWidget {
  final UserDto user;

  const UserDetailView({super.key, required this.user});

  @override
  State<UserDetailView> createState() => _UserDetailViewState();
}

class _UserDetailViewState extends State<UserDetailView> {
  late UserDto _editedUser;
  late List<DropdownMenuItem<String>> _userRoles = [];
  @override
  void initState() {
    super.initState();
    _editedUser = widget.user;
    _loadUserRoles();
  }

  Future<void> _loadUserRoles() async {
    final roles = await TokenManager.getRoles();
    setState(() {
      _userRoles = roles.map((role) => DropdownMenuItem<String>(value: role, child: Text(role))).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${_editedUser.firstName} ${_editedUser.lastName}'), actions: [IconButton(icon: const Icon(Icons.save), onPressed: () => _saveChanges(context))]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextFormField(
              initialValue: _editedUser.firstName,
              decoration: const InputDecoration(labelText: 'First Name'),
              onChanged: (value) => setState(() => _editedUser = _editedUser.copyWith(firstName: value)),
            ),
            TextFormField(
              initialValue: _editedUser.lastName,
              decoration: const InputDecoration(labelText: 'Last Name'),
              onChanged: (value) => setState(() => _editedUser = _editedUser.copyWith(lastName: value)),
            ),
            TextFormField(
              initialValue: _editedUser.email,
              decoration: const InputDecoration(labelText: 'Email'),
              onChanged: (value) => setState(() => _editedUser = _editedUser.copyWith(email: value)),
            ),
            const SizedBox(height: 16),
            const Text('Plants:', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._editedUser.plants.map(
              (plant) => ListTile(
                title: Text(plant.plantName ?? 'Unknown Plant'),
                subtitle: Text(plant.role),
                trailing: DropdownButton<String>(
                  value: plant.role,
                  items: _userRoles,
                  onChanged: (newRole) {
                    if (newRole != null) {
                      setState(() {
                        _editedUser = _editedUser.copyWith(plants: _editedUser.plants.map((p) => p.plantId == plant.plantId ? p.copyWith(role: newRole) : p).toList());
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges(BuildContext context) {
    final viewModel = Provider.of<UserViewModel>(context, listen: false);
    viewModel.updateUser(_editedUser).then((_) {
      Navigator.pop(context);
    });
  }
}

extension UserDtoExtension on UserDto {
  UserDto copyWith({String? firstName, String? lastName, String? email, List<UserPlantDto>? plants}) {
    return UserDto(
      id: id,
      username: username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      enabled: enabled,
      plants: plants ?? this.plants,
    );
  }
}

extension UserPlantDtoExtension on UserPlantDto {
  UserPlantDto copyWith({String? role}) {
    return UserPlantDto(plantId: plantId, plantName: plantName, role: role ?? this.role);
  }
}
