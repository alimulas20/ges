// user_list_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    _viewModel = UserViewModel(UserService());
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
              Text('${user.firstName} ${user.lastName}', style: Theme.of(context).textTheme.titleLarge),
              Text(user.email),
              Text('Username: ${user.username}'),
              Text('Role: ${user.role}'),
              const SizedBox(height: 16),
              if (user.plants.isNotEmpty) ...[const Text('Plants:', style: TextStyle(fontWeight: FontWeight.bold)), ...user.plants.map((plant) => Text(plant.plantName ?? 'Unknown Plant'))],
            ],
          ),
        ),
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
      leading: CircleAvatar(child: Text(user.firstName.substring(0, 1) + user.lastName.substring(0, 1))),
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
