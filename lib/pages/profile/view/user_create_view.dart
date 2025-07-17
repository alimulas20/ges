// user_create_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  final List<int> _selectedPlantIds = [];
  late RoleDto _selectedRole;
  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<UserViewModel>(context, listen: false);
    // Roller yüklenmişse ilk rolü seç, yoksa default bir değer ata
    _selectedRole = viewModel.displayRoles.isNotEmpty ? viewModel.displayRoles.first : RoleDto(key: 'Viewer', value: 'Görüntüleme');
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserViewModel>(context);
    // Roller henüz yüklenmediyse loading göster
    if (viewModel.roles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Roller yüklendikten sonra ilk rolü seç (eğer daha önce seçili rol yoksa)
    if (_selectedRole.key == 'Viewer' && viewModel.displayRoles.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedRole = viewModel.displayRoles.first;
        });
      });
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Create New User')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username'), validator: (value) => value?.isEmpty ?? true ? 'Required' : null),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(controller: _firstNameController, decoration: const InputDecoration(labelText: 'First Name'), validator: (value) => value?.isEmpty ?? true ? 'Required' : null),
              TextFormField(controller: _lastNameController, decoration: const InputDecoration(labelText: 'Last Name'), validator: (value) => value?.isEmpty ?? true ? 'Required' : null),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
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
              const SizedBox(height: 16),
              const Text('Role:', style: TextStyle(fontWeight: FontWeight.bold)),
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
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _submitForm, child: const Text('Create User')),
            ],
          ),
        ),
      ),
    );
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
      );

      final viewModel = Provider.of<UserViewModel>(context, listen: false);
      viewModel.createUser(dto).then((_) {
        Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
