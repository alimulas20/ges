// user_create_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../global/constant/app_constants.dart';
import '../model/user_model.dart';
import '../viewmodel/user_viewmodel.dart';

class UserCreateView extends StatefulWidget {
  const UserCreateView({super.key});

  @override
  State<UserCreateView> createState() => _UserCreateViewState();
}

class _UserCreateViewState extends State<UserCreateView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  final List<int> _selectedPlantIds = [];
  bool _receivePush = true;
  bool _receiveMail = true;
  bool _receiveSMS = false;
  bool _loadingPlants = false;
  late RoleDto _selectedRole;

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<UserViewModel>(context, listen: false);
    _selectedRole = viewModel.displayRoles.isNotEmpty ? viewModel.displayRoles.first : RoleDto(key: 'Viewer', value: 'Görüntüleme');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlants();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadPlants() async {
    if (!mounted) return;

    setState(() => _loadingPlants = true);

    try {
      final viewModel = Provider.of<UserViewModel>(context, listen: false);
      await viewModel.loadPlantsDropdown();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load plants: $e')));
    } finally {
      if (mounted) {
        setState(() => _loadingPlants = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create New User')),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingExtraLarge),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username'), validator: (value) => value?.isEmpty ?? true ? 'Required' : null),
              const SizedBox(height: AppConstants.paddingExtraLarge),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (!value!.contains('@')) return 'Invalid email format';
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppConstants.paddingExtraLarge),
              TextFormField(controller: _firstNameController, decoration: const InputDecoration(labelText: 'First Name'), validator: (value) => value?.isEmpty ?? true ? 'Required' : null),
              const SizedBox(height: AppConstants.paddingExtraLarge),
              TextFormField(controller: _lastNameController, decoration: const InputDecoration(labelText: 'Last Name'), validator: (value) => value?.isEmpty ?? true ? 'Required' : null),
              const SizedBox(height: AppConstants.paddingExtraLarge),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (value!.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.paddingExtraLarge),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (value != _passwordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.paddingExtraLarge),
              TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
              const SizedBox(height: AppConstants.paddingExtraLarge),
              const Text('Notification Preferences:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppConstants.fontSizeLarge)),
              CheckboxListTile(title: const Text('Receive Push Notifications'), value: _receivePush, onChanged: (value) => setState(() => _receivePush = value ?? true)),
              CheckboxListTile(title: const Text('Receive Email Notifications'), value: _receiveMail, onChanged: (value) => setState(() => _receiveMail = value ?? true)),
              CheckboxListTile(title: const Text('Receive SMS Notifications'), value: _receiveSMS, onChanged: (value) => setState(() => _receiveSMS = value ?? false)),
              const SizedBox(height: AppConstants.paddingExtraLarge),
              const Text('Role:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppConstants.fontSizeLarge)),
              DropdownButtonFormField<RoleDto>(
                value: _selectedRole,
                items:
                    viewModel.displayRoles.map((RoleDto role) {
                      return DropdownMenuItem<RoleDto>(value: role, child: Text(role.value));
                    }).toList(),
                onChanged: (RoleDto? selectedRole) {
                  if (selectedRole != null) {
                    setState(() {
                      _selectedRole = selectedRole;
                    });
                  }
                },
                decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: AppConstants.paddingMedium)),
              ),
              const SizedBox(height: AppConstants.paddingExtraLarge),
              const Text('Plants:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppConstants.fontSizeLarge)),
              if (_loadingPlants)
                const Padding(padding: EdgeInsets.symmetric(vertical: AppConstants.paddingExtraLarge), child: Center(child: CircularProgressIndicator()))
              else if (viewModel.plantsDropdown.isEmpty)
                const Text('No plants available', style: TextStyle(color: Colors.grey))
              else
                Column(
                  children: [
                    ElevatedButton(onPressed: _selectPlants, style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, AppConstants.buttonHeight)), child: const Text('Select Plants')),
                    if (_selectedPlantIds.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.paddingMedium),
                      Text('Selected Plants: ${_selectedPlantIds.length}', style: const TextStyle(fontSize: AppConstants.fontSizeMedium)),
                      const SizedBox(height: AppConstants.paddingMedium),
                      ..._selectedPlantIds.map((plantId) {
                        final plantName = viewModel.getPlantNameById(plantId);
                        return ListTile(
                          leading: Icon(Icons.eco, color: colorScheme.tertiary),
                          title: Text(plantName),
                          trailing: IconButton(icon: Icon(Icons.close, color: colorScheme.error), onPressed: () => _removePlant(plantId)),
                        );
                      }),
                    ],
                  ],
                ),
              const SizedBox(height: AppConstants.paddingUltraLarge),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, AppConstants.buttonHeight), backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary),
                child: const Text('Create User'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectPlants() async {
    final viewModel = Provider.of<UserViewModel>(context, listen: false);
    final availablePlants = viewModel.plantsDropdown.where((plant) => !_selectedPlantIds.contains(plant.id)).toList();

    if (availablePlants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All available plants are already selected')));
      return;
    }

    final selected = await showDialog<List<int>>(
      context: context,
      builder: (context) {
        final tempSelected = <int>[];
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Plants'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        availablePlants.map((plant) {
                          return CheckboxListTile(
                            title: Text(plant.name),
                            value: tempSelected.contains(plant.id),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  tempSelected.add(plant.id);
                                } else {
                                  tempSelected.remove(plant.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(context, tempSelected), child: const Text('Select')),
              ],
            );
          },
        );
      },
    );

    if (selected != null && selected.isNotEmpty) {
      setState(() {
        _selectedPlantIds.addAll(selected);
      });
    }
  }

  void _removePlant(int plantId) {
    setState(() {
      _selectedPlantIds.remove(plantId);
    });
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final dto = UserCreateDto(
        username: _usernameController.text,
        email: _emailController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        password: _passwordController.text,
        role: _selectedRole.key,
        plantIds: _selectedPlantIds,
        phone: _phoneController.text,
        receivePush: _receivePush,
        receiveMail: _receiveMail,
        receiveSMS: _receiveSMS,
      );

      final viewModel = Provider.of<UserViewModel>(context, listen: false);
      viewModel
          .createUser(dto)
          .then((_) {
            if (!mounted) return;
            Navigator.pop(context, true); // Yeni kullanıcı oluşturulduğunu belirt
          })
          .catchError((error) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating user: $error')));
          });
    }
  }
}
