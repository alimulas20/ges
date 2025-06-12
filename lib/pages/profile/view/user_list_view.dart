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
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Management'),
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: () => _viewModel.refresh()),
            if (_viewModel.isAdmin) IconButton(icon: const Icon(Icons.add), onPressed: () => _navigateToCreateUser(context)),
          ],
        ),
        body: Consumer<UserViewModel>(
          builder: (context, viewModel, child) {
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

            if (!viewModel.isAdmin) {
              return _buildCurrentUserCard(viewModel.currentUser!);
            }

            return _buildAdminView(viewModel);
          },
        ),
      ),
    );
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
              const SizedBox(height: 16),
              if (user.plants.isNotEmpty) ...[const Text('Plants:', style: TextStyle(fontWeight: FontWeight.bold)), ...user.plants.map((plant) => Text('${plant.plantName} (${plant.role})'))],
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
      subtitle: Text(user.email),
      trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => _navigateToUserDetail(context, user)),
      onTap: () => _navigateToUserDetail(context, user),
    );
  }

  void _navigateToUserDetail(BuildContext context, UserDto user) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => UserDetailView(user: user)));
  }

  void _navigateToCreateUser(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const UserCreateView())).then((_) => _viewModel.refresh());
  }
}
