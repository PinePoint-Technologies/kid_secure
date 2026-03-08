import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatter.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/providers/firebase_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  File? _pickedImage;
  bool _loading = false;
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user != null) {
      _nameCtrl.text = user.displayName;
      _phoneCtrl.text = user.phoneNumber ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _pickedImage = File(result.files.single.path!));
    }
  }

  Future<String?> _uploadPhoto(String uid) async {
    if (_pickedImage == null) return null;
    setState(() => _uploadingPhoto = true);
    try {
      final ref = FirebaseStorage.instanceFor(bucket: 'gs://heavy-6c072').ref('profile_photos/$uid.jpg');
      await ref.putFile(_pickedImage!);
      return await ref.getDownloadURL();
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _loading = true);
    try {
      final newPhotoUrl = await _uploadPhoto(user.uid);
      final name = _nameCtrl.text.trim();
      final phone = _phoneCtrl.text.trim();

      await ref.read(firestoreServiceProvider).updateUser(user.uid, {
        'displayName': name,
        'phoneNumber': phone.isEmpty ? null : phone,
        if (newPhotoUrl != null) 'photoUrl': newPhotoUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: (_loading || _uploadingPhoto) ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ─── Avatar ─────────────────────────────────────────────────
              _AvatarPicker(
                user: user,
                pickedImage: _pickedImage,
                uploading: _uploadingPhoto,
                onTap: _pickPhoto,
              ).animate().scale(duration: 400.ms, curve: Curves.easeOut),

              const SizedBox(height: 8),
              if (user != null) ...[
                Text(_roleLabel(user.role),
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.primary)),
              ],

              const SizedBox(height: 32),

              // ─── Display name ────────────────────────────────────────────
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ).animate(delay: 80.ms).fadeIn().slideY(begin: 0.15),

              const SizedBox(height: 16),

              // ─── Email (read-only) ───────────────────────────────────────
              TextFormField(
                initialValue: user?.email ?? '',
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                  suffixIcon: const Tooltip(
                    message: 'Email cannot be changed here',
                    child: Icon(Icons.lock_outline_rounded,
                        color: AppColors.textHint),
                  ),
                ),
              ).animate(delay: 140.ms).fadeIn().slideY(begin: 0.15),

              const SizedBox(height: 16),

              // ─── Phone ───────────────────────────────────────────────────
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.15),

              const SizedBox(height: 16),

              // ─── Role (read-only) ────────────────────────────────────────
              TextFormField(
                initialValue: user != null ? _roleLabel(user.role) : '',
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Role',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                  suffixIcon: const Tooltip(
                    message: 'Role is assigned by your administrator',
                    child: Icon(Icons.lock_outline_rounded,
                        color: AppColors.textHint),
                  ),
                ),
              ).animate(delay: 260.ms).fadeIn().slideY(begin: 0.15),

              const SizedBox(height: 32),

              FilledButton(
                onPressed: (_loading || _uploadingPhoto) ? null : _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text('Save Changes'),
              ).animate(delay: 320.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }

  String _roleLabel(UserRole role) => switch (role) {
        UserRole.superAdmin => 'Super Administrator',
        UserRole.teacher => 'Teacher',
        UserRole.parent => 'Parent',
      };
}

// ─── Avatar picker widget ─────────────────────────────────────────────────────

class _AvatarPicker extends StatelessWidget {
  final UserModel? user;
  final File? pickedImage;
  final bool uploading;
  final VoidCallback onTap;

  const _AvatarPicker({
    required this.user,
    required this.pickedImage,
    required this.uploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: AppColors.primary.withAlpha(26),
            child: uploading
                ? const CircularProgressIndicator()
                : pickedImage != null
                    ? ClipOval(
                        child: Image.file(pickedImage!,
                            width: 104, height: 104, fit: BoxFit.cover),
                      )
                    : (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: user!.photoUrl!,
                              width: 104,
                              height: 104,
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (_, __, ___) => _Initials(user!),
                            ),
                          )
                        : (user != null ? _Initials(user!) : const Icon(Icons.person_rounded, size: 52)),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt_rounded,
                color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  final UserModel user;
  const _Initials(this.user);

  @override
  Widget build(BuildContext context) => Text(
        Formatter.initials(user.displayName),
        style: AppTextStyles.headline2.copyWith(color: AppColors.primary),
      );
}
