import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/spacing.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../manager/auth_cubit.dart';
import '../../manager/auth_state.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isNotEmpty && password.isNotEmpty) {
      context.read<AuthCubit>().login(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login Success'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/tasks');
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login Failed: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome back',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Access your academic workspace',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xxl),

            if (state is AuthFailure)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: AppColors.error, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.message,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),

            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: AppSpacing.s),
              child: Text('EMAIL ADDRESS', style: AppTextStyles.labelSmall),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _emailController,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'student@university.edu',
                  hintStyle: TextStyle(
                    color: AppColors.onSurfaceVariant.withOpacity(0.4),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  suffixIcon: Icon(
                    Icons.mail_outline,
                    color: AppColors.onSurfaceVariant.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8, right: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PASSWORD', style: AppTextStyles.labelSmall),
                  Text('Forgot password?', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: TextStyle(
                    color: AppColors.onSurfaceVariant.withOpacity(0.4),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.onSurfaceVariant.withOpacity(0.3),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: state is AuthLoading ? null : _login,
                child:
                    state is AuthLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          'Login',
                          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.onPrimary),
                        ),
              ),
            ),
            const SizedBox(height: 32),
            const Divider(color: Colors.black12, height: 1),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account?",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/signup'),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.secondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
