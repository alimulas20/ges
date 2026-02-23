// user_detail_view.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../global/constant/app_constants.dart';
import '../../../global/utils/alert_utils.dart';
import '../../../global/utils/snack_bar_utils.dart';
import '../../../global/widgets/compact_switch.dart';
import '../model/user_model.dart';
import '../viewmodel/user_viewmodel.dart';
import '../widgets/plant_selection_dialog.dart';

class UserDetailView extends StatefulWidget {
  final UserDto user;

  const UserDetailView({super.key, required this.user});

  @override
  State<UserDetailView> createState() => _UserDetailViewState();
}

class _UserDetailViewState extends State<UserDetailView> {
  late UserDto _editedUser;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;
  bool _isPasswordLoading = false;

  @override
  void initState() {
    super.initState();
    _editedUser = widget.user;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<UserViewModel>(context, listen: false);
      if (viewModel.plantsDropdown.isEmpty) {
        viewModel.loadPlantsDropdown();
      }
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (!mounted) {
        return;
      }
      final viewModel = Provider.of<UserViewModel>(context, listen: false);
      try {
        var url = await viewModel.setProfilePicture(pickedFile);
        setState(() {
          _editedUser = _editedUser.copyWith(profilePictureUrl: url);
        });
      } catch (e) {
        if (mounted) {
          SnackBarUtils.showError(context, 'Resim yüklenemedi: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewModel = Provider.of<UserViewModel>(context);
    final isCurrentUser = viewModel.currentUser?.id == _editedUser.id;
    final canEdit = isCurrentUser || viewModel.isAdmin || viewModel.isSuperAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_editedUser.firstName} ${_editedUser.lastName}', style: TextStyle(fontSize: AppConstants.fontSizeExtraLarge)),
        actions: [
          if (canEdit && _hasChanges())
            IconButton(
              icon:
                  _isSaving
                      ? SizedBox(
                        width: AppConstants.iconSizeMedium,
                        height: AppConstants.iconSizeMedium,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary)),
                      )
                      : const Icon(Icons.save),
              onPressed: _isSaving ? null : () => _saveChanges(context),
            ),
        ],
        toolbarHeight: AppConstants.appBarHeight,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingExtraLarge),
        child: ListView(
          children: [
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: AppConstants.imageMediumSize / 2,
                        backgroundImage: _editedUser.profilePictureUrl.isNotEmpty ? NetworkImage(_editedUser.profilePictureUrl) : null,
                        child:
                            _editedUser.profilePictureUrl.isEmpty
                                ? Text('${_editedUser.firstName.substring(0, 1)}${_editedUser.lastName.substring(0, 1)}', style: TextStyle(fontSize: AppConstants.fontSizeHeadline))
                                : null,
                      ),
                      if (canEdit)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Tooltip(
                            message: 'Profil fotoğrafını değiştir',
                            child: Container(
                              height: AppConstants.paddingHuge,
                              width: AppConstants.paddingHuge,
                              decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(AppConstants.borderRadiusCircle)),
                              child: IconButton(icon: Icon(Icons.camera_alt, color: colorScheme.onPrimary, size: AppConstants.paddingExtraLarge), onPressed: _pickImage),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (canEdit) ...[
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text('Profil fotoğrafı', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppConstants.paddingExtraLarge),
            if (canEdit) ...[
              Text('Kişisel bilgiler', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppConstants.paddingMedium),
              TextFormField(
                initialValue: _editedUser.firstName,
                decoration: const InputDecoration(labelText: 'Ad'),
                onChanged:
                    (value) => setState(() {
                      _editedUser = _editedUser.copyWith(firstName: value);
                    }),
              ),
              TextFormField(
                initialValue: _editedUser.lastName,
                decoration: const InputDecoration(labelText: 'Soyad'),
                onChanged:
                    (value) => setState(() {
                      _editedUser = _editedUser.copyWith(lastName: value);
                    }),
              ),
              TextFormField(
                initialValue: _editedUser.email,
                decoration: const InputDecoration(labelText: 'E-posta'),
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
                  decoration: const InputDecoration(labelText: 'Rol'),
                ),
              ],
              TextFormField(
                initialValue: _editedUser.phone,
                decoration: const InputDecoration(labelText: 'Telefon'),
                onChanged:
                    (value) => setState(() {
                      _editedUser = _editedUser.copyWith(phone: value);
                    }),
              ),
              CompactSwitch(
                title: 'Anlık Bildirimler',
                value: _editedUser.receivePush,
                onChanged:
                    (value) => setState(() {
                      _editedUser = _editedUser.copyWith(receivePush: value);
                    }),
              ),
              CompactSwitch(
                title: 'E-posta Bildirimleri',
                value: _editedUser.receiveMail,
                onChanged:
                    (value) => setState(() {
                      _editedUser = _editedUser.copyWith(receiveMail: value);
                    }),
              ),
              CompactSwitch(
                title: 'SMS Bildirimleri',
                value: _editedUser.receiveSMS,
                onChanged:
                    (value) => setState(() {
                      _editedUser = _editedUser.copyWith(receiveSMS: value);
                    }),
              ),
              if (_hasChanges()) ...[
                const SizedBox(height: AppConstants.paddingMedium),
                SizedBox(
                  width: double.infinity,
                  height: AppConstants.buttonHeight,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : () => _saveChanges(context),
                    icon: _isSaving
                        ? SizedBox(
                            width: AppConstants.iconSizeSmall,
                            height: AppConstants.iconSizeSmall,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary)),
                          )
                        : const Icon(Icons.save_outlined, size: AppConstants.iconSizeMedium),
                    label: Text(_isSaving ? 'Kaydediliyor...' : 'Bilgileri kaydet'),
                  ),
                ),
              ],
              if (isCurrentUser || (viewModel.isAdmin || viewModel.isSuperAdmin) && !isCurrentUser) ...[
                const SizedBox(height: AppConstants.paddingExtraLarge),
                Text('Şifre', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppConstants.paddingMedium),
                if (isCurrentUser)
                  OutlinedButton.icon(
                    onPressed: _isPasswordLoading ? null : () => _showPasswordUpdateDialog(context),
                    icon: const Icon(Icons.lock_outline, size: AppConstants.iconSizeSmall),
                    label: const Text('Şifre değiştir'),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: _isPasswordLoading ? null : () => _showPasswordResetDialog(context),
                    icon: const Icon(Icons.lock_reset, size: AppConstants.iconSizeSmall),
                    label: const Text('Şifre sıfırla'),
                    style: OutlinedButton.styleFrom(foregroundColor: colorScheme.error),
                  ),
                const SizedBox(height: AppConstants.paddingExtraLarge),
              ],
            ] else ...[
              ListTile(title: const Text('Ad'), subtitle: Text(_editedUser.firstName)),
              ListTile(title: const Text('Soyad'), subtitle: Text(_editedUser.lastName)),
              ListTile(title: const Text('E-posta'), subtitle: Text(_editedUser.email)),
              if (_editedUser.phone != null && _editedUser.phone!.isNotEmpty) ListTile(title: const Text('Telefon'), subtitle: Text(_editedUser.phone!)),
            ],
            const SizedBox(height: AppConstants.paddingExtraLarge),
            Text('Tesisler', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ..._editedUser.plants.map(
              (plant) => ListTile(
                title: Text(viewModel.getPlantNameById(plant.plantId)),
                trailing:
                    canEdit
                        ? IconButton(
                          icon: Icon(Icons.delete, color: colorScheme.error),
                          onPressed: () {
                            setState(() {
                              _editedUser = _editedUser.copyWith(plants: _editedUser.plants.where((p) => p.plantId != plant.plantId).toList());
                            });
                          },
                        )
                        : null,
              ),
            ),
            if (canEdit) ElevatedButton(onPressed: () => _addPlants(context), child: const Text('Tesis Ekle')),
          ],
        ),
      ),
    );
  }

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

    final availablePlants = viewModel.plantsDropdown.where((plant) => !_editedUser.plants.any((p) => p.plantId == plant.id)).toList();

    if (availablePlants.isEmpty) {
      SnackBarUtils.showInfo(context, 'Eklenebilecek başka tesis bulunamadı');
      return;
    }

    final selectedPlants = await PlantSelectionDialog.show(context, availablePlants: availablePlants, title: 'Tesis Ekle');

    if (selectedPlants != null && selectedPlants.isNotEmpty) {
      setState(() {
        _editedUser = _editedUser.copyWith(plants: [..._editedUser.plants, ...selectedPlants.map((id) => UserPlantDto(plantId: id, plantName: viewModel.getPlantNameById(id)))]);
      });
    }
  }

  void _saveChanges(BuildContext context) async {
    if (_isSaving) return; // Prevent multiple saves

    setState(() {
      _isSaving = true;
    });

    try {
      final viewModel = Provider.of<UserViewModel>(context, listen: false);
      await viewModel.updateUser(_editedUser);

      if (mounted) {
        // Başarılı kayıt mesajı göster
        SnackBarUtils.showSuccess(context, 'Kullanıcı bilgileri başarıyla güncellendi');

        // Kısa bir gecikme sonra sayfayı kapat
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        // Hata mesajı göster ama sayfayı kapatma
        AlertUtils.showError(
          context,
          title: 'Kaydetme Hatası',
          error: e,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _showPasswordUpdateDialog(BuildContext context) async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Şifre değiştir'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: currentController,
                    decoration: const InputDecoration(labelText: 'Mevcut şifre'),
                    obscureText: true,
                    validator: (v) => (v?.isEmpty ?? true) ? 'Zorunlu alan' : null,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  TextFormField(
                    controller: newController,
                    decoration: const InputDecoration(labelText: 'Yeni şifre'),
                    obscureText: true,
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Zorunlu alan';
                      if (v!.length < 6) return 'En az 6 karakter olmalı';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  TextFormField(
                    controller: confirmController,
                    decoration: const InputDecoration(labelText: 'Yeni şifre (tekrar)'),
                    obscureText: true,
                    validator: (v) {
                      if (v != newController.text) return 'Şifreler eşleşmiyor';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    Navigator.pop(ctx, true);
                  }
                },
                child: const Text('Değiştir'),
              ),
            ],
          );
      },
    );

    if (ok != true || !mounted) return;

    setState(() => _isPasswordLoading = true);
    try {
      final viewModel = Provider.of<UserViewModel>(context, listen: false);
      await viewModel.updateUserPassword(_editedUser.id, currentController.text, newController.text);
      if (mounted) {
        SnackBarUtils.showSuccess(context, 'Şifre başarıyla güncellendi');
      }
    } catch (e) {
      if (mounted) {
        AlertUtils.showError(context, title: 'Şifre değiştirilemedi', error: e);
      }
    } finally {
      if (mounted) setState(() => _isPasswordLoading = false);
    }
  }

  Future<void> _showPasswordResetDialog(BuildContext context) async {
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Şifre sıfırla'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('${_editedUser.firstName} ${_editedUser.lastName} kullanıcısı için yeni şifre belirleyin.', style: Theme.of(ctx).textTheme.bodyMedium),
                  const SizedBox(height: AppConstants.paddingMedium),
                  TextFormField(
                    controller: newController,
                    decoration: const InputDecoration(labelText: 'Yeni şifre'),
                    obscureText: true,
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Zorunlu alan';
                      if (v!.length < 6) return 'En az 6 karakter olmalı';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  TextFormField(
                    controller: confirmController,
                    decoration: const InputDecoration(labelText: 'Yeni şifre (tekrar)'),
                    obscureText: true,
                    validator: (v) {
                      if (v != newController.text) return 'Şifreler eşleşmiyor';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx, true);
                }
              },
              child: const Text('Sıfırla'),
            ),
          ],
        );
      },
    );

    if (ok != true || !mounted) return;

    setState(() => _isPasswordLoading = true);
    try {
      final viewModel = Provider.of<UserViewModel>(context, listen: false);
      await viewModel.resetUserPassword(_editedUser.id, newController.text);
      if (mounted) {
        SnackBarUtils.showSuccess(context, 'Şifre başarıyla sıfırlandı');
      }
    } catch (e) {
      if (mounted) {
        AlertUtils.showError(context, title: 'Şifre sıfırlanamadı', error: e);
      }
    } finally {
      if (mounted) setState(() => _isPasswordLoading = false);
    }
  }
}
