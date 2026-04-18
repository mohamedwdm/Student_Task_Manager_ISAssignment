import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import 'widgets/login_view_body.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: LoginViewBody(),
    );
  }
}
