import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/colors.dart';
import '../../features/auth/presentation/manager/auth_cubit.dart';
import '../../features/auth/presentation/manager/auth_state.dart';

class AppAvatar extends StatelessWidget {
  final double radius;
  final double borderWidth;
  final Color borderColor;

  const AppAvatar({
    super.key,
    this.radius = 20,
    this.borderWidth = 2,
    this.borderColor = AppColors.primaryContainer,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String? profilePhoto;
        
        if (state is AuthSuccess) {
          profilePhoto = state.user.profilePhoto;
        }

        ImageProvider defaultImage = const NetworkImage(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAiHPrOKwVpkZwogzB3lAsD-B6J2N56xxPJGh1JfOozSucJS2c9JwmDkkAeY0HlBlAzoVoxFw3U7GSjXQroVfWG2hRettceBluvmJXi1PXNmk4OZBPu7FTr24ogYALID2F72ZCpFgmmjSbUxXW4HmUv0JgorDrkS5LiQrzNHQgAvXhBTUc85VHVFPeHRYPFl_GJdIFziSR1w7qyeW5Fx2M4yq8n_7FVXTGghCYs2x_gfg4NNIRDmFEz5rxcjUjOUTpAhCQtBXEZOZQ');
            
        ImageProvider avatarImage = defaultImage;
        if (profilePhoto != null && profilePhoto.isNotEmpty) {
          if (profilePhoto.startsWith('http')) {
            avatarImage = NetworkImage(profilePhoto);
          } else {
            avatarImage = FileImage(File(profilePhoto));
          }
        }

        return Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceContainerHigh,
            border: Border.all(color: borderColor, width: borderWidth),
            image: DecorationImage(
              image: avatarImage,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
