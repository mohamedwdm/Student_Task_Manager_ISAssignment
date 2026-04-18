import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import 'widgets/signup_view_body.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SignupViewBody(),
    );
  }
}
