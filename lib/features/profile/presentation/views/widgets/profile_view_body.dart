import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../auth/presentation/manager/auth_cubit.dart';
import '../../../../auth/presentation/manager/auth_state.dart';
import '../../../../auth/data/models/user_model.dart';
import '../../../../../core/widgets/app_avatar.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/theme/spacing.dart';
import '../../../../../core/theme/text_styles.dart';

class ProfileViewBody extends StatefulWidget {
  const ProfileViewBody({super.key});

  @override
  State<ProfileViewBody> createState() => _ProfileViewBodyState();
}

class _ProfileViewBodyState extends State<ProfileViewBody> {
  final ImagePicker _picker = ImagePicker();

  // State variables for editing
  bool _isEditingName = false;
  late TextEditingController _nameController;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _getAcademicLevelText(int? level) {
    if (level == null) return 'Unknown Level';
    switch (level) {
      case 1:
        return 'Freshman Undergraduate';
      case 2:
        return 'Sophomore Undergraduate';
      case 3:
        return 'Junior Undergraduate';
      case 4:
        return 'Senior Undergraduate';
      default:
        return 'Level $level Undergraduate';
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null && _currentUser != null) {
        final updatedUser = UserModel(
          id: _currentUser!.id,
          fullName: _currentUser!.fullName,
          email: _currentUser!.email,
          studentId: _currentUser!.studentId,
          password: _currentUser!.password,
          academicLevel: _currentUser!.academicLevel,
          gender: _currentUser!.gender,
          profilePhoto: pickedFile.path, // Save local path
        );
        if (mounted) {
          context.read<AuthCubit>().updateProfile(updatedUser);
        }
      }
    } catch (e) {
      // Handle error gracefully
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Update Profile Photo',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text(
                  'Take a Photo',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.primary,
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _saveName() {
    if (_currentUser != null && _nameController.text.trim().isNotEmpty) {
      final updatedUser = UserModel(
        id: _currentUser!.id,
        fullName: _nameController.text.trim(),
        email: _currentUser!.email,
        studentId: _currentUser!.studentId,
        password: _currentUser!.password,
        academicLevel: _currentUser!.academicLevel,
        gender: _currentUser!.gender,
        profilePhoto: _currentUser!.profilePhoto,
      );
      context.read<AuthCubit>().updateProfile(updatedUser);
      setState(() {
        _isEditingName = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name updated successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          _currentUser = state.user;
          if (!_isEditingName) {
            _nameController.text = state.user.fullName;
          }
        }
      },
      builder: (context, state) {
        String fullName = 'Unknown User';
        String email = '';
        String studentId = '';
        String levelText = 'Academic Level';
        String? profilePhoto;

        if (state is AuthSuccess) {
          _currentUser = state.user;
          fullName = state.user.fullName;
          email = state.user.email;
          studentId = state.user.studentId;
          levelText = _getAcademicLevelText(state.user.academicLevel);
          profilePhoto = state.user.profilePhoto;
        }

        ImageProvider defaultImage = const NetworkImage(
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAiHPrOKwVpkZwogzB3lAsD-B6J2N56xxPJGh1JfOozSucJS2c9JwmDkkAeY0HlBlAzoVoxFw3U7GSjXQroVfWG2hRettceBluvmJXi1PXNmk4OZBPu7FTr24ogYALID2F72ZCpFgmmjSbUxXW4HmUv0JgorDrkS5LiQrzNHQgAvXhBTUc85VHVFPeHRYPFl_GJdIFziSR1w7qyeW5Fx2M4yq8n_7FVXTGghCYs2x_gfg4NNIRDmFEz5rxcjUjOUTpAhCQtBXEZOZQ',
        );
        ImageProvider avatarImage =
            profilePhoto != null && profilePhoto.isNotEmpty
                ? (profilePhoto.startsWith('http')
                    ? NetworkImage(profilePhoto)
                    : FileImage(File(profilePhoto)) as ImageProvider)
                : defaultImage;

        return SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          AppAvatar(radius: 20),
                          const SizedBox(width: 12),
                          const Text(
                            'Academic Curator',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: AppColors.primary,
                        ),
                        onPressed: () {
                          context.read<AuthCubit>().logout();
                          context.go('/login');
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Profile Overview
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 24.0,
                    right: 24.0,
                    bottom: 24.0,
                    top: 8.0,
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          AppAvatar(
                            radius: 65,
                            borderWidth: 4,
                            borderColor: AppColors.surfaceContainerLowest,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showImageSourceDialog,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.photo_camera,
                                  color: AppColors.onPrimary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        fullName,
                        style: AppTextStyles.heading2,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'GRADUATE RESEARCHER',
                        style: AppTextStyles.labelMedium,
                      ),
                    ],
                  ),
                ),
              ),

              // Information Bento Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Academic Level
                      _buildInfoCard(
                        label: 'ACADEMIC LEVEL',
                        value: levelText,
                        iconWidget: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer.withOpacity(
                              0.2,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.school,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email and ID Grid
                      _buildInfoCard(
                        label: 'UNIVERSITY EMAIL',
                        value: email,
                        icon: Icons.mail,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        label: 'STUDENT ID',
                        value: studentId,
                        icon: Icons.badge,
                      ),
                      const SizedBox(height: 16),

                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'PREFERRED FULL NAME',
                                    style: AppTextStyles.labelSmall,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  if (_isEditingName)
                                    TextField(
                                      controller: _nameController,
                                      autofocus: true,
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.onSurface,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    )
                                  else
                                    Text(
                                      fullName,
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.onSurface,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            if (_isEditingName)
                              IconButton(
                                icon: const Icon(
                                  Icons.check,
                                  color: AppColors.primary,
                                ),
                                onPressed: _saveName,
                              )
                            else
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: AppColors.outline,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isEditingName = true;
                                  });
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      AppButton(
                        label: 'Logout',
                        icon: Icons.logout,
                        isDestructive: true,
                        onPressed: () {
                          context.read<AuthCubit>().logout();
                          context.go('/login');
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    IconData? icon,
    Widget? iconWidget,
    bool isSmall = false,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child:
          isSmall
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.labelSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Row(
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          value,
                          style: AppTextStyles.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: AppTextStyles.labelSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          value,
                          style: AppTextStyles.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (iconWidget != null) iconWidget,
                ],
              ),
    );
  }
}
