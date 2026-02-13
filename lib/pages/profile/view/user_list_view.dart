// user_list_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solar/global/managers/token_manager.dart';

import '../../../global/constant/app_constants.dart';
import '../../../global/utils/snack_bar_utils.dart';
import '../../../global/widgets/error_display_widget.dart';
import '../../plant/services/plant_service.dart';
import '../../plant/views/plant_update_view.dart';
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
  bool _isUserManagementExpanded = false;
  bool _isPlantManagementExpanded = false;

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
              title: const Text('Profil', style: TextStyle(fontSize: AppConstants.fontSizeExtraLarge)),
              toolbarHeight: AppConstants.appBarHeight,
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
      return ErrorDisplayWidget(
        errorMessage: viewModel.error!,
        onRetry: () => viewModel.refresh(),
        retryButtonText: 'Tekrar Dene',
      );
    }

    if (viewModel.currentUser == null) {
      return const Center(child: Text('Kullanıcı bilgisi bulunamadı'));
    }

    if (!viewModel.isAdmin && !viewModel.isSuperAdmin) {
      return SingleChildScrollView(
        child: Column(
          children: [
            _buildCurrentUserCard(viewModel.currentUser!, theme, colorScheme),
            const SizedBox(height: AppConstants.paddingExtraLarge),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
              child: ElevatedButton.icon(
                onPressed: () {
                  TokenManager.clearToken();
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                },
                icon: const Icon(Icons.logout),
                label: const Text("Çıkış Yap"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium)),
                  elevation: AppConstants.elevationSmall,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCurrentUserCard(viewModel.currentUser!, theme, colorScheme),
          const SizedBox(height: AppConstants.paddingExtraLarge),
          _buildAdminView(viewModel, theme, colorScheme),
          const SizedBox(height: AppConstants.paddingExtraLarge),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
            child: ElevatedButton.icon(
              onPressed: () {
                TokenManager.clearToken();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              icon: const Icon(Icons.logout),
              label: const Text("Çıkış Yap"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
                padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium)),
                elevation: AppConstants.elevationSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentUserCard(UserDto user, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      elevation: AppConstants.elevationSmall,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge)),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Section
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [colorScheme.primary.withOpacity(0.1), colorScheme.primary.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
              ),
              child: Stack(
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: AppConstants.imageMediumSize / 2,
                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                      backgroundImage: user.profilePictureUrl.isNotEmpty ? NetworkImage(user.profilePictureUrl) : null,
                      child:
                          user.profilePictureUrl.isEmpty
                              ? Text(
                                '${user.firstName.substring(0, 1)}${user.lastName.substring(0, 1)}',
                                style: TextStyle(fontSize: AppConstants.fontSizeHeadline, fontWeight: FontWeight.bold, color: colorScheme.primary),
                              )
                              : null,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(AppConstants.borderRadiusCircle), boxShadow: AppConstants.cardShadow),
                      child: IconButton(icon: Icon(Icons.edit, color: colorScheme.onPrimary, size: AppConstants.iconSizeSmall), onPressed: () => _navigateToUserDetail(context, user)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // User Info Section
            Center(
              child: Column(
                children: [
                  Text('${user.firstName} ${user.lastName}', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface), textAlign: TextAlign.center),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
                    decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium)),
                    child: Text(user.email, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // User Details Section
            _buildSectionCard('Kullanıcı Bilgileri', Icons.person_outline, [
              _buildDetailRow(Icons.person_outline, 'Kullanıcı Adı', user.username, theme, colorScheme),
              if (user.phone != null && user.phone!.isNotEmpty) _buildDetailRow(Icons.phone, 'Telefon', user.phone!, theme, colorScheme),
              if (user.role != null) _buildDetailRow(Icons.assignment_ind_outlined, 'Rol', user.role!, theme, colorScheme),
            ], colorScheme),

            const SizedBox(height: AppConstants.paddingMedium),

            // Notification Preferences Section
            _buildSectionCard('Bildirim Tercihleri', Icons.notifications_outlined, [
              _buildNotificationPreference('Anlık Bildirimler', user.receivePush, theme, colorScheme),
              _buildNotificationPreference('E-Posta Bildirimleri', user.receiveMail, theme, colorScheme),
              _buildNotificationPreference('SMS Bildirimleri', user.receiveSMS, theme, colorScheme),
            ], colorScheme),

            // Associated Plants Section
            if (user.plants.isNotEmpty) ...[
              const SizedBox(height: AppConstants.paddingMedium),
              _buildSectionCard('İlişkili Tesisler', Icons.business_outlined, [
                Wrap(
                  spacing: AppConstants.paddingSmall,
                  runSpacing: AppConstants.paddingSmall,
                  children:
                      user.plants
                          .map(
                            (plant) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                                border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
                              ),
                              child: Text(
                                plant.plantName ?? 'Tesis ${plant.plantId}',
                                style: TextStyle(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.w500, fontSize: AppConstants.fontSizeSmall),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ], colorScheme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium), border: Border.all(color: colorScheme.outline.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppConstants.iconSizeMedium, color: colorScheme.primary),
              const SizedBox(width: AppConstants.paddingSmall),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppConstants.fontSizeMedium, color: colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, ThemeData theme, ColorScheme colorScheme, {Color? statusColor}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.paddingExtraSmall),
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
      decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest.withOpacity(0.3), borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall)),
      child: Row(
        children: [
          Icon(icon, size: AppConstants.iconSizeSmall, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: colorScheme.onSurface, fontSize: AppConstants.fontSizeSmall))),
          Text(value, style: TextStyle(color: statusColor ?? colorScheme.onSurfaceVariant, fontWeight: statusColor != null ? FontWeight.bold : FontWeight.w500, fontSize: AppConstants.fontSizeSmall)),
        ],
      ),
    );
  }

  Widget _buildNotificationPreference(String label, bool isActive, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.paddingExtraSmall),
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
      decoration: BoxDecoration(
        color: isActive ? colorScheme.primaryContainer.withOpacity(0.3) : colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(color: isActive ? colorScheme.primary.withOpacity(0.3) : colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(isActive ? Icons.notifications_active : Icons.notifications_off, size: AppConstants.iconSizeSmall, color: isActive ? colorScheme.primary : colorScheme.outline),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: colorScheme.onSurface, fontSize: AppConstants.fontSizeSmall))),
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingExtraSmall),
            decoration: BoxDecoration(color: isActive ? colorScheme.primary : colorScheme.outline.withOpacity(0.3), borderRadius: BorderRadius.circular(AppConstants.borderRadiusCircle)),
            child: Icon(isActive ? Icons.check : Icons.close, size: AppConstants.iconSizeExtraSmall, color: isActive ? colorScheme.onPrimary : colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminView(UserViewModel viewModel, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kullanıcı Yönetimi - Expandable
          Card(
            elevation: AppConstants.elevationSmall,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium)),
            child: ExpansionTile(
              initiallyExpanded: _isUserManagementExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _isUserManagementExpanded = expanded;
                });
              },
              leading: Icon(Icons.people, color: colorScheme.primary),
              title: Text('Kullanıcı Yönetimi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppConstants.fontSizeLarge, color: colorScheme.onSurface)),
              subtitle: Text('${viewModel.plantUsers.fold<int>(0, (sum, plantUsers) => sum + plantUsers.users.length)} kullanıcı', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: AppConstants.fontSizeSmall)),
              children: [
                if (viewModel.plantUsers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    child: Center(child: Text('Kullanıcı bulunamadı', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: AppConstants.fontSizeMedium))),
                  )
                else
                  ...viewModel.plantUsers.map((plantUsers) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
                      elevation: AppConstants.elevationSmall,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium)),
                      child: ExpansionTile(
                        leading: Icon(Icons.business, color: colorScheme.primary, size: AppConstants.iconSizeSmall),
                        title: Text(plantUsers.plantName, style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface, fontSize: AppConstants.fontSizeSmall)),
                        subtitle: Text('${plantUsers.users.length} kullanıcı', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: AppConstants.fontSizeExtraSmall)),
                        children: plantUsers.users.map((user) => _buildUserTile(user, theme, colorScheme)).toList(),
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          // Tesis Yönetimi - Expandable
          Card(
            elevation: AppConstants.elevationSmall,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium)),
            child: ExpansionTile(
              initiallyExpanded: _isPlantManagementExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _isPlantManagementExpanded = expanded;
                });
              },
              leading: Icon(Icons.business_outlined, color: colorScheme.primary),
              title: Text('Tesis Yönetimi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppConstants.fontSizeLarge, color: colorScheme.onSurface)),
              subtitle: Text('${viewModel.plantsDropdown.length} tesis', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: AppConstants.fontSizeSmall)),
              children: [
                if (viewModel.plantsDropdown.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    child: Center(child: Text('Tesis bulunamadı', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: AppConstants.fontSizeMedium))),
                  )
                else
                  ...viewModel.plantsDropdown.map((plant) {
                    return _buildPlantTile(plant, theme, colorScheme);
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(UserDto user, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingExtraSmall),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
        leading: CircleAvatar(
          radius: AppConstants.iconSizeMedium / 2,
          backgroundColor: colorScheme.primary.withOpacity(0.1),
          backgroundImage: user.profilePictureUrl.isNotEmpty ? NetworkImage(user.profilePictureUrl) : null,
          child:
              user.profilePictureUrl.isEmpty
                  ? Text(
                    user.firstName.substring(0, 1) + user.lastName.substring(0, 1),
                    style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: AppConstants.fontSizeSmall),
                  )
                  : null,
        ),
        title: Text('${user.firstName} ${user.lastName}', style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface, fontSize: AppConstants.fontSizeSmall)),
        subtitle: Text(user.email, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: AppConstants.fontSizeExtraSmall)),
        trailing: Container(
          decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall)),
          child: IconButton(icon: Icon(Icons.edit, color: colorScheme.primary, size: AppConstants.iconSizeSmall), onPressed: () => _navigateToUserDetail(context, user)),
        ),
        onTap: () => _navigateToUserDetail(context, user),
      ),
    );
  }

  void _navigateToUserDetail(BuildContext context, UserDto user) async {
    try {
      final updatedUser = await _viewModel.getUserById(user.id);
      if (!mounted) return;
      final needsRefresh = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => ChangeNotifierProvider.value(value: _viewModel, child: UserDetailView(user: updatedUser))));

      if (needsRefresh == true) {
        await _viewModel.refresh();
      }
    } catch (e) {
      if (!mounted) return;
      SnackBarUtils.showError(context, 'Kullanıcı detayları alınamadı: $e');
    }
  }

  void _navigateToCreateUser(BuildContext context) {
    Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => ChangeNotifierProvider.value(value: _viewModel, child: const UserCreateView()))).then((needsRefresh) {
      if (needsRefresh == true) {
        _viewModel.refresh();
      }
    });
  }

  Widget _buildPlantTile(dynamic plant, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingExtraSmall),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
        leading: Container(
          width: AppConstants.iconSizeMedium,
          height: AppConstants.iconSizeMedium,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          ),
          child: Icon(Icons.business, color: colorScheme.primary, size: AppConstants.iconSizeSmall),
        ),
        title: Text(plant.name, style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface, fontSize: AppConstants.fontSizeSmall)),
        trailing: Container(
          decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall)),
          child: IconButton(
            icon: Icon(Icons.edit, color: colorScheme.primary, size: AppConstants.iconSizeSmall),
            onPressed: () => _navigateToPlantDetail(context, plant.id),
          ),
        ),
        onTap: () => _navigateToPlantDetail(context, plant.id),
      ),
    );
  }

  void _navigateToPlantDetail(BuildContext context, int plantId) async {
    try {
      final needsRefresh = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => PlantUpdateView(plantId: plantId),
        ),
      );

      if (needsRefresh == true) {
        await _viewModel.refresh();
      }
    } catch (e) {
      if (!mounted) return;
      SnackBarUtils.showError(context, 'Tesis detayları alınamadı: $e');
    }
  }
}
