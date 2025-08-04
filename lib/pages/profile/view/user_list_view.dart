// user_list_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_ges_360/pages/plant/services/plant_service.dart';

import '../../../global/constant/app_constants.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            body: _buildBody(viewModel, theme, colorScheme),
          );
        },
      ),
    );
  }

  Widget _buildBody(UserViewModel viewModel, ThemeData theme, ColorScheme colorScheme) {
    if (viewModel.isLoading && viewModel.currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(viewModel.error!), const SizedBox(height: AppConstants.paddingExtraLarge), ElevatedButton(onPressed: () => viewModel.refresh(), child: const Text('Retry'))],
        ),
      );
    }

    if (viewModel.currentUser == null) {
      return const Center(child: Text('No user information available'));
    }

    if (!viewModel.isAdmin && !viewModel.isSuperAdmin) {
      return SingleChildScrollView(child: _buildCurrentUserCard(viewModel.currentUser!, theme, colorScheme));
    }

    return SingleChildScrollView(
      child: Column(
        children: [_buildCurrentUserCard(viewModel.currentUser!, theme, colorScheme), const SizedBox(height: AppConstants.paddingExtraLarge), _buildAdminView(viewModel, theme, colorScheme)],
      ),
    );
  }

  Widget _buildCurrentUserCard(UserDto user, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.all(AppConstants.paddingExtraLarge),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingExtraLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: AppConstants.iconSizeExtraLarge,
                    backgroundImage: user.profilePictureUrl.isNotEmpty ? NetworkImage(user.profilePictureUrl) : null,
                    child: user.profilePictureUrl.isEmpty ? Text('${user.firstName.substring(0, 1)}${user.lastName.substring(0, 1)}', style: TextStyle(fontSize: AppConstants.fontSizeTitle)) : null,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(AppConstants.borderRadiusCircle)),
                    child: IconButton(icon: Icon(Icons.edit, color: colorScheme.onPrimary, size: AppConstants.iconSizeSmall), onPressed: () => _navigateToUserDetail(context, user)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingExtraLarge),
            Center(child: Text('${user.firstName} ${user.lastName}', style: theme.textTheme.titleLarge)),
            const SizedBox(height: AppConstants.paddingMedium),
            Center(child: Text(user.email, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant))),
            const Divider(height: AppConstants.paddingUltraLarge, thickness: 1),

            // User Details Section
            _buildDetailRow(Icons.person_outline, 'Username', user.username, theme, colorScheme),
            if (user.phone != null && user.phone!.isNotEmpty) _buildDetailRow(Icons.phone, 'Phone', user.phone!, theme, colorScheme),

            if (user.role != null) _buildDetailRow(Icons.assignment_ind_outlined, 'Role', user.role!, theme, colorScheme),

            const SizedBox(height: AppConstants.paddingMedium),
            const Divider(height: AppConstants.paddingUltraLarge, thickness: 1),

            // Notification Preferences
            Text('Notification Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppConstants.fontSizeLarge)),
            const SizedBox(height: AppConstants.paddingMedium),
            _buildNotificationPreference('Push Notifications', user.receivePush, theme, colorScheme),
            _buildNotificationPreference('Email Notifications', user.receiveMail, theme, colorScheme),
            _buildNotificationPreference('SMS Notifications', user.receiveSMS, theme, colorScheme),

            // Associated Plants
            if (user.plants.isNotEmpty) ...[
              const SizedBox(height: AppConstants.paddingMedium),
              const Divider(height: AppConstants.paddingUltraLarge, thickness: 1),
              Text('Associated Plants', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppConstants.fontSizeLarge)),
              const SizedBox(height: AppConstants.paddingMedium),
              Wrap(
                spacing: AppConstants.paddingMedium,
                runSpacing: AppConstants.paddingMedium,
                children: user.plants.map((plant) => Chip(label: Text(plant.plantName ?? 'Plant ${plant.plantId}'), backgroundColor: colorScheme.primaryContainer)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, ThemeData theme, ColorScheme colorScheme, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(
        children: [
          Icon(icon, size: AppConstants.iconSizeMedium, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: AppConstants.paddingLarge),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          const Spacer(),
          Text(value, style: TextStyle(color: statusColor ?? colorScheme.onSurfaceVariant, fontWeight: statusColor != null ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildNotificationPreference(String label, bool isActive, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(
        children: [
          Icon(isActive ? Icons.notifications_active : Icons.notifications_off, size: AppConstants.iconSizeMedium, color: isActive ? colorScheme.tertiary : colorScheme.outline),
          const SizedBox(width: AppConstants.paddingLarge),
          Text(label),
          const Spacer(),
          Icon(isActive ? Icons.check_circle : Icons.remove_circle_outline, color: isActive ? colorScheme.tertiary : colorScheme.outline),
        ],
      ),
    );
  }

  Widget _buildAdminView(UserViewModel viewModel, ThemeData theme, ColorScheme colorScheme) {
    if (viewModel.plantUsers.isEmpty) {
      return const Padding(padding: EdgeInsets.only(bottom: AppConstants.paddingExtraLarge), child: Center(child: Text('No users found')));
    }

    return Column(
      children: [
        ...viewModel.plantUsers.map((plantUsers) {
          return ExpansionTile(
            title: Text(plantUsers.plantName),
            subtitle: Text('${plantUsers.users.length} users'),
            children: plantUsers.users.map((user) => _buildUserTile(user, theme, colorScheme)).toList(),
          );
        }),
        SizedBox(height: AppConstants.paddingHuge),
      ],
    );
  }

  Widget _buildUserTile(UserDto user, ThemeData theme, ColorScheme colorScheme) {
    return ListTile(
      leading:
          user.profilePictureUrl.isNotEmpty
              ? CircleAvatar(backgroundImage: NetworkImage(user.profilePictureUrl))
              : CircleAvatar(child: Text(user.firstName.substring(0, 1) + user.lastName.substring(0, 1))),
      title: Text('${user.firstName} ${user.lastName}'),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(user.email)]),
      trailing: IconButton(icon: Icon(Icons.edit, color: colorScheme.primary), onPressed: () => _navigateToUserDetail(context, user)),
      onTap: () => _navigateToUserDetail(context, user),
    );
  }

  void _navigateToUserDetail(BuildContext context, UserDto user) async {
    try {
      final updatedUser = await _viewModel.getUserById(user.id);
      final needsRefresh = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => ChangeNotifierProvider.value(value: _viewModel, child: UserDetailView(user: updatedUser))));

      if (needsRefresh == true) {
        await _viewModel.refresh();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch user details: $e')));
    }
  }

  void _navigateToCreateUser(BuildContext context) {
    Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => ChangeNotifierProvider.value(value: _viewModel, child: const UserCreateView()))).then((needsRefresh) {
      if (needsRefresh == true) {
        _viewModel.refresh();
      }
    });
  }
}
