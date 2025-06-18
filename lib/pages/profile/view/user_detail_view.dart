// user_detail_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    _editedUser = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserViewModel>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${_editedUser.firstName} ${_editedUser.lastName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveChanges(context),
          ),
        ],
      ),
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
            if (viewModel.isAdmin || viewModel.isSuperAdmin) ...[
              const SizedBox(height: 16),
              const Text('Role:', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: _editedUser.role,
                items: viewModel.userRoles
                    .where((role) => viewModel.isSuperAdmin || role != 'SuperAdmin')
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _editedUser = _editedUser.copyWith(role: value));
                  }
                },
              ),
            ],
            const SizedBox(height: 16),
            const Text('Plants:', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._editedUser.plants.map(
              (plant) => ListTile(
                title: Text(plant.plantName ?? 'Unknown Plant'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _editedUser = _editedUser.copyWith(
                        plants: _editedUser.plants.where((p) => p.plantId != plant.plantId).toList(),
                      );
                    });
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