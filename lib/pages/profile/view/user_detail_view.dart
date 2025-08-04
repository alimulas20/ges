import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _editedUser = widget.user;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final viewModel = Provider.of<UserViewModel>(context, listen: false);
      try {
        await viewModel.setProfilePicture(pickedFile);
        setState(() {
          _editedUser = _editedUser.copyWith(profilePictureUrl: '${_editedUser.profilePictureUrl}?${DateTime.now().millisecondsSinceEpoch}');
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserViewModel>(context);
    final isCurrentUser = viewModel.currentUser?.id == _editedUser.id;
    final canEdit = isCurrentUser || viewModel.isAdmin || viewModel.isSuperAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_editedUser.firstName} ${_editedUser.lastName}'),
        actions: [if (canEdit && _hasChanges()) IconButton(icon: const Icon(Icons.save), onPressed: () => _saveChanges(context))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _editedUser.profilePictureUrl.isNotEmpty ? NetworkImage(_editedUser.profilePictureUrl) : null,
                    child: _editedUser.profilePictureUrl.isEmpty ? Text('${_editedUser.firstName.substring(0, 1)}${_editedUser.lastName.substring(0, 1)}', style: const TextStyle(fontSize: 40)) : null,
                  ),
                  if (canEdit)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
                        child: IconButton(icon: const Icon(Icons.edit, color: Colors.white), onPressed: _pickImage),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (canEdit) ...[
              TextFormField(
                initialValue: _editedUser.firstName,
                decoration: const InputDecoration(labelText: 'First Name'),
                onChanged:
                    (value) => setState(() {
                      _editedUser = _editedUser.copyWith(firstName: value);
                    }),
              ),
              TextFormField(
                initialValue: _editedUser.lastName,
                decoration: const InputDecoration(labelText: 'Last Name'),
                onChanged:
                    (value) => setState(() {
                      _editedUser = _editedUser.copyWith(lastName: value);
                    }),
              ),
              TextFormField(
                initialValue: _editedUser.email,
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged:
                    (value) => setState(() {
                      _editedUser = _editedUser.copyWith(email: value);
                    }),
              ),
              if (viewModel.isAdmin || viewModel.isSuperAdmin) ...[
                DropdownButtonFormField<String>(
                  value: _editedUser.role,
                  items: viewModel.displayRoles.map((role) => DropdownMenuItem(value: role.key, child: Text(role.value))).toList(),
                  onChanged:
                      (value) => setState(() {
                        _editedUser = _editedUser.copyWith(role: value);
                      }),
                  decoration: const InputDecoration(labelText: 'Role'),
                ),
              ],
              TextFormField(
                initialValue: _editedUser.phone,
                decoration: const InputDecoration(labelText: 'Phone'),
                onChanged:
                    (value) => setState(() {
                      _editedUser = _editedUser.copyWith(phone: value);
                    }),
              ),
              SwitchListTile(
                title: const Text('Receive Push Notifications'),
                value: _editedUser.receivePush,
                onChanged:
                    (value) => setState(() {
                      _editedUser = _editedUser.copyWith(receivePush: value);
                    }),
              ),
              SwitchListTile(
                title: const Text('Receive Email Notifications'),
                value: _editedUser.receiveMail,
                onChanged:
                    (value) => setState(() {
                      _editedUser = _editedUser.copyWith(receiveMail: value);
                    }),
              ),
              SwitchListTile(
                title: const Text('Receive SMS Notifications'),
                value: _editedUser.receiveSMS,
                onChanged:
                    (value) => setState(() {
                      _editedUser = _editedUser.copyWith(receiveSMS: value);
                    }),
              ),
            ] else ...[
              // Display mode for non-editable users
              ListTile(title: const Text('First Name'), subtitle: Text(_editedUser.firstName)),
              ListTile(title: const Text('Last Name'), subtitle: Text(_editedUser.lastName)),
              ListTile(title: const Text('Email'), subtitle: Text(_editedUser.email)),
              if (_editedUser.phone != null && _editedUser.phone!.isNotEmpty) ListTile(title: const Text('Phone'), subtitle: Text(_editedUser.phone!)),
            ],
            const SizedBox(height: 16),
            const Text('Plants:', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._editedUser.plants.map(
              (plant) => ListTile(
                title: Text(viewModel.getPlantNameById(plant.plantId)),
                trailing:
                    canEdit
                        ? IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _editedUser = _editedUser.copyWith(plants: _editedUser.plants.where((p) => p.plantId != plant.plantId).toList());
                            });
                          },
                        )
                        : null,
              ),
            ),
            if (canEdit) ElevatedButton(onPressed: () => _addPlants(context), child: const Text('Add Plants')),
          ],
        ),
      ),
    );
  }

  // Add this helper method to check for changes
  bool _hasChanges() {
    return _editedUser.firstName != widget.user.firstName ||
        _editedUser.lastName != widget.user.lastName ||
        _editedUser.email != widget.user.email ||
        _editedUser.role != widget.user.role ||
        _editedUser.phone != widget.user.phone ||
        _editedUser.receivePush != widget.user.receivePush ||
        _editedUser.receiveMail != widget.user.receiveMail ||
        _editedUser.receiveSMS != widget.user.receiveSMS ||
        !_arePlantsEqual(_editedUser.plants, widget.user.plants);
  }

  bool _arePlantsEqual(List<UserPlantDto> a, List<UserPlantDto> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].plantId != b[i].plantId) return false;
    }
    return true;
  }

  Future<void> _addPlants(BuildContext context) async {
    final viewModel = Provider.of<UserViewModel>(context, listen: false);
    await viewModel.loadPlantsDropdown();

    final availablePlants = viewModel.plantsDropdown.where((plant) => !_editedUser.plants.any((p) => p.plantId == plant.id)).toList();

    if (availablePlants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No more plants available to add')));
      return;
    }

    final selectedPlants = await showDialog<List<int>>(
      context: context,
      builder: (context) {
        final selected = <int>[];
        return AlertDialog(
          title: const Text('Add Plants'),
          content: SingleChildScrollView(
            child: Column(
              children:
                  availablePlants.map((plant) {
                    return CheckboxListTile(
                      title: Text(plant.name),
                      value: selected.contains(plant.id),
                      onChanged: (bool? value) {
                        if (value == true) {
                          selected.add(plant.id);
                        } else {
                          selected.remove(plant.id);
                        }
                      },
                    );
                  }).toList(),
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, selected), child: const Text('Add'))],
        );
      },
    );

    if (selectedPlants != null && selectedPlants.isNotEmpty) {
      setState(() {
        _editedUser = _editedUser.copyWith(plants: [..._editedUser.plants, ...selectedPlants.map((id) => UserPlantDto(plantId: id, plantName: viewModel.getPlantNameById(id)))]);
      });
    }
  }

  void _saveChanges(BuildContext context) {
    final viewModel = Provider.of<UserViewModel>(context, listen: false);
    viewModel.updateUser(_editedUser).then((_) {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }
}
