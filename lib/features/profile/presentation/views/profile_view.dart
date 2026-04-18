import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import 'widgets/profile_view_body.dart';
import '../../../tasks/presentation/views/widgets/bottom_nav_bar.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: ProfileViewBody()),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 2),
    );
  }
}
