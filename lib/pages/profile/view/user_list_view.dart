// user_list_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_ges_360/pages/plant/services/plant_service.dart';

import '../model/user_model.dart';
import '../service/user_service.dart';
import '../viewmodel/user_viewmodel.dart';
import 'user_create_view.dart';
import 'user_detail_view.dart';

class UserListView extends StatefulWidget {
  const UserListView({super.key});

  @override
  State<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  late final UserViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = UserViewModel(UserService(), PlantService());
    _viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<UserViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Profil'),
              actions: [
                IconButton(icon: const Icon(Icons.refresh), onPressed: () => viewModel.refresh()),
                if (viewModel.isAdmin || viewModel.isSuperAdmin) IconButton(icon: const Icon(Icons.add), onPressed: () => _navigateToCreateUser(context)),
              ],
            ),
            body: _buildBody(viewModel),
          );
        },
      ),
    );
  }

  Widget _buildBody(UserViewModel viewModel) {
    if (viewModel.isLoading && viewModel.currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(viewModel.error!), const SizedBox(height: 16), ElevatedButton(onPressed: () => viewModel.refresh(), child: const Text('Retry'))],
        ),
      );
    }

    if (viewModel.currentUser == null) {
      return const Center(child: Text('No user information available'));
    }

    // Her durumda mevcut kullanıcı kartını göster
    if (!viewModel.isAdmin && !viewModel.isSuperAdmin) {
      return _buildCurrentUserCard(viewModel.currentUser!);
    }

    // Admin/SuperAdmin ise hem kart hem de liste
    return Column(children: [_buildCurrentUserCard(viewModel.currentUser!), const SizedBox(height: 16), Expanded(child: _buildAdminView(viewModel))]);
  }

  Widget _buildCurrentUserCard(UserDto user) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: user.profilePictureUrl.isNotEmpty ? NetworkImage(user.profilePictureUrl) : null,
                      child: user.profilePictureUrl.isEmpty ? Text('${user.firstName.substring(0, 1)}${user.lastName.substring(0, 1)}', style: const TextStyle(fontSize: 30)) : null,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
                      child: IconButton(icon: const Icon(Icons.edit, color: Colors.white, size: 20), onPressed: () => _navigateToUserDetail(context, user)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(child: Text('${user.firstName} ${user.lastName}', style: Theme.of(context).textTheme.titleLarge)),
              const SizedBox(height: 8),
              Center(child: Text(user.email, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]))),
              const Divider(height: 24, thickness: 1),

              // User Details Section
              _buildDetailRow(Icons.person_outline, 'Username', user.username),
              if (user.phone != null && user.phone!.isNotEmpty) _buildDetailRow(Icons.phone, 'Phone', user.phone!),
              _buildDetailRow(Icons.verified_user_outlined, 'Status', user.enabled ? 'Active' : 'Disabled', statusColor: user.enabled ? Colors.green : Colors.red),
              if (user.role != null) _buildDetailRow(Icons.assignment_ind_outlined, 'Role', user.role!),

              const SizedBox(height: 8),
              const Divider(height: 24, thickness: 1),

              // Notification Preferences
              const Text('Notification Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              _buildNotificationPreference('Push Notifications', user.receivePush),
              _buildNotificationPreference('Email Notifications', user.receiveMail),
              _buildNotificationPreference('SMS Notifications', user.receiveSMS),

              // Associated Plants
              if (user.plants.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Divider(height: 24, thickness: 1),
                const Text('Associated Plants', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      user.plants.map((plant) {
                        return Chip(label: Text(plant.plantName ?? 'Plant ${plant.plantId}'), backgroundColor: Colors.blue[50]);
                      }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for detail rows
  Widget _buildDetailRow(IconData icon, String label, String value, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
          const Spacer(),
          Text(value, style: TextStyle(color: statusColor ?? Colors.grey[600], fontWeight: statusColor != null ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  // Helper widget for notification preferences
  Widget _buildNotificationPreference(String label, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(isActive ? Icons.notifications_active : Icons.notifications_off, size: 20, color: isActive ? Colors.green : Colors.grey),
          const SizedBox(width: 12),
          Text(label),
          const Spacer(),
          Icon(isActive ? Icons.check_circle : Icons.remove_circle_outline, color: isActive ? Colors.green : Colors.grey),
        ],
      ),
    );
  }

  Widget _buildAdminView(UserViewModel viewModel) {
    if (viewModel.plantUsers.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    return ListView.builder(
      itemCount: viewModel.plantUsers.length,
      itemBuilder: (context, index) {
        final plantUsers = viewModel.plantUsers[index];
        return ExpansionTile(title: Text(plantUsers.plantName), subtitle: Text('${plantUsers.users.length} users'), children: plantUsers.users.map((user) => _buildUserTile(user)).toList());
      },
    );
  }

  Widget _buildUserTile(UserDto user) {
    return ListTile(
      leading:
          user.profilePictureUrl.isNotEmpty
              ? CircleAvatar(backgroundImage: NetworkImage(user.profilePictureUrl))
              : CircleAvatar(child: Text(user.firstName.substring(0, 1) + user.lastName.substring(0, 1))),
      title: Text('${user.firstName} ${user.lastName}'),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(user.email) /*Text('Role: ${user.role}')*/]),
      trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => _navigateToUserDetail(context, user)),
      onTap: () => _navigateToUserDetail(context, user),
    );
  }

  void _navigateToUserDetail(BuildContext context, UserDto user) async {
    try {
      // Detayları yeniden çek
      final updatedUser = await _viewModel.getUserById(user.id);

      // Yeni bilgilerle sayfayı aç
      Navigator.push(context, MaterialPageRoute(builder: (_) => ChangeNotifierProvider.value(value: _viewModel, child: UserDetailView(user: updatedUser))));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch user details: $e')));
    }
  }

  void _navigateToCreateUser(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ChangeNotifierProvider.value(value: _viewModel, child: const UserCreateView()))).then((_) => _viewModel.refresh());
  }
}
