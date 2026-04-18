import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/spacing.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../data/models/user_model.dart';
import '../../manager/auth_cubit.dart';
import '../../manager/auth_state.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedGender = 'Male';
  int _selectedLevel = 3;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signup() {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    final user = UserModel(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      studentId: _studentIdController.text.trim(),
      password: _passwordController.text,
      gender: _selectedGender,
      academicLevel: _selectedLevel,
    );
    context.read<AuthCubit>().signup(user);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signup successful. Please login.')),
          );
          context.go('/login');
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Create your account', style: AppTextStyles.heading3),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Please enter your academic credentials',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xxl),

            _buildLabel('FULL NAME'),
            _buildTextField(
              controller: _nameController,
              hintText: 'John Doe',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),

            _buildLabel('GENDER'),
            Row(
              children: [
                Expanded(child: _buildGenderRadio('Male', Icons.male)),
                const SizedBox(width: 16),
                Expanded(child: _buildGenderRadio('Female', Icons.female)),
              ],
            ),

            const SizedBox(height: 20),
            _buildLabel('UNIVERSITY EMAIL'),
            _buildTextField(
              controller: _emailController,
              hintText: '20210000@stud.fci-cu.edu.eg',
              icon: Icons.alternate_email,
            ),
            const SizedBox(height: 20),
            _buildLabel('STUDENT ID'),
            _buildTextField(
              controller: _studentIdController,
              hintText: '20210000',
              icon: Icons.badge_outlined,
            ),

            const SizedBox(height: 20),
            _buildLabel('ACADEMIC LEVEL'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<int>(
                value: _selectedLevel,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.school_outlined,
                    color: AppColors.outline,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text(
                      'Level 1',
                      style: TextStyle(fontFamily: 'Inter'),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text(
                      'Level 2',
                      style: TextStyle(fontFamily: 'Inter'),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Text(
                      'Level 3',
                      style: TextStyle(fontFamily: 'Inter'),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 4,
                    child: Text(
                      'Level 4',
                      style: TextStyle(fontFamily: 'Inter'),
                    ),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedLevel = val);
                },
              ),
            ),
            const SizedBox(height: 20),
            _buildLabel('PASSWORD'),
            _buildTextField(
              controller: _passwordController,
              hintText: '••••••••',
              icon: Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 20),
            _buildLabel('CONFIRM PASSWORD'),
            _buildTextField(
              controller: _confirmPasswordController,
              hintText: '••••••••',
              icon: Icons.lock_clock_outlined,
              isPassword: true,
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                elevation: 8,
                shadowColor: AppColors.primary.withOpacity(0.5),
              ),
              onPressed: state is AuthLoading ? null : _signup,
              child:
                  state is AuthLoading
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppColors.onPrimary,
                        ),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sign Up',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account?',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.s),
      child: Text(text, style: AppTextStyles.labelSmall),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(fontFamily: 'Inter', color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.outline.withOpacity(0.6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          prefixIcon: Icon(icon, color: AppColors.outline),
        ),
      ),
    );
  }

  Widget _buildGenderRadio(String title, IconData icon) {
    final isSelected = _selectedGender == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primaryFixed
                  : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.outline,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
