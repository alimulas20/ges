import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/profile_model.dart';
import '../service/profile_service.dart';
import '../viewmodel/profile_viewmodel.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => ProfileViewModel(ProfileService())..initialize(context), child: const _ProfileBody());
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

    if (viewModel.isLoading && viewModel.currentProfile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (viewModel.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil Yönetimi')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(viewModel.error!), const SizedBox(height: 20), ElevatedButton(onPressed: () => viewModel.initialize(context), child: const Text('Tekrar Dene'))],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Yönetimi'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => viewModel.initialize(context))]),
      body: _buildProfileContent(viewModel, context),
    );
  }

  Widget _buildProfileContent(ProfileViewModel viewModel, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Profil Bilgileri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildProfileInfo(viewModel.currentProfile!),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(onPressed: () => _showEditProfileDialog(context, viewModel.currentProfile!), child: const Text('Profili Düzenle')),
                      const SizedBox(width: 8),
                      TextButton(onPressed: () => _showChangePasswordDialog(context), child: const Text('Şifre Değiştir')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (viewModel.isAdmin) ...[
            const SizedBox(height: 24),
            const Text('Kullanıcı Yönetimi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...viewModel.profiles.map((profile) => _buildUserListTile(profile, context)),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileInfo(ProfileModel profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ad: ${profile.firstName}'),
        Text('Soyad: ${profile.lastName}'),
        Text('Email: ${profile.email}'),
        Text('Kullanıcı Adı: ${profile.username}'),
        Text('Durum: ${profile.enabled ? "Aktif" : "Pasif"}'),
        if (profile.groups.isNotEmpty) Text('Gruplar: ${profile.groups.join(", ")}'),
      ],
    );
  }

  Widget _buildUserListTile(ProfileModel profile, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text('${profile.firstName} ${profile.lastName}'),
        subtitle: Text(profile.email),
        trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => _showEditProfileDialog(context, profile)),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, ProfileModel profile) {
    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController(text: profile.firstName);
    final lastNameController = TextEditingController(text: profile.lastName);
    final emailController = TextEditingController(text: profile.email);
    bool isEnabled = profile.enabled;
    final viewModel = context.read<ProfileViewModel>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Profili Düzenle'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(controller: firstNameController, decoration: const InputDecoration(labelText: 'Ad')),
                  TextFormField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Soyad')),
                  TextFormField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
                  if (viewModel.isAdmin)
                    SwitchListTile(
                      title: const Text('Hesap Aktif'),
                      value: isEnabled,
                      onChanged: (value) {
                        isEnabled = value;
                      },
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(context);
                  final updated = profile.copyWith(firstName: firstNameController.text, lastName: lastNameController.text, email: emailController.text, enabled: isEnabled);
                  await viewModel.updateProfile(updated, context);
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final viewModel = context.read<ProfileViewModel>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Şifre Değiştir'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: currentPasswordController, decoration: const InputDecoration(labelText: 'Mevcut Şifre'), obscureText: true),
                TextFormField(controller: newPasswordController, decoration: const InputDecoration(labelText: 'Yeni Şifre'), obscureText: true),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(labelText: 'Yeni Şifre (Tekrar)'),
                  obscureText: true,
                  validator: (value) {
                    if (value != newPasswordController.text) return 'Şifreler uyuşmuyor';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(context);
                  await viewModel.changePassword(currentPasswordController.text, newPasswordController.text, context);
                }
              },
              child: const Text('Değiştir'),
            ),
          ],
        );
      },
    );
  }
}
