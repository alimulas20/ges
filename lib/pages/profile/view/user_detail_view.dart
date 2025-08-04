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

    return Scaffold(
      // ... existing code ...
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // ... existing fields ...
            const SizedBox(height: 16),
            const Text('Plants:', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._editedUser.plants.map(
              (plant) => ListTile(
                title: Text(viewModel.getPlantNameById(plant.plantId)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _editedUser = _editedUser.copyWith(plants: _editedUser.plants.where((p) => p.plantId != plant.plantId).toList());
                    });
                  },
                ),
              ),
            ),
            // Add button to add more plants
            ElevatedButton(onPressed: () => _addPlants(context), child: const Text('Add Plants')),
          ],
        ),
      ),
    );
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
      Navigator.pop(context);
    });
  }
}
