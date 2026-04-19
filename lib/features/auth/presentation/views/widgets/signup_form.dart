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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String _selectedGender = 'Male';
  int? _selectedLevel;

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
    // 8. SUBMISSION LOGIC
    if (!_formKey.currentState!.validate()) {
      // IF form is NOT valid -> Show SnackBar "Signup Failed"
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signup Failed'),
          backgroundColor: Colors.red,
        ),
      );
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Create your account', style: AppTextStyles.heading3),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Please enter your academic credentials',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // 1. FULL NAME
              _buildLabel('Full Name *'),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(fontFamily: 'Inter'),
                decoration: _buildInputDecoration(
                  hintText: 'John Doe',
                  icon: Icons.person_outline,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Full name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 2. GENDER
              _buildLabel('Gender'),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Male', style: TextStyle(fontSize: 14)),
                      value: 'Male',
                      groupValue: _selectedGender,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => _selectedGender = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Female', style: TextStyle(fontSize: 14)),
                      value: 'Female',
                      groupValue: _selectedGender,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => _selectedGender = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 3. UNIVERSITY EMAIL
              _buildLabel('University Email *'),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontFamily: 'Inter'),
                decoration: _buildInputDecoration(
                  hintText: '20210000@stud.fci-cu.edu.eg',
                  icon: Icons.alternate_email,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  final regex = RegExp(r'^\d+@stud\.fci-cu\.edu\.eg$');
                  if (!regex.hasMatch(value)) {
                    return 'Enter a valid FCI email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 4. STUDENT ID
              _buildLabel('Student ID *'),
              TextFormField(
                controller: _studentIdController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontFamily: 'Inter'),
                decoration: _buildInputDecoration(
                  hintText: '20210000',
                  icon: Icons.badge_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Student ID is required';
                  }
                  if (!RegExp(r'^\d+$').hasMatch(value)) {
                    return 'Student ID must be numbers only';
                  }
                  // 5. EMAIL + STUDENT ID MATCHING
                  final emailValue = _emailController.text;
                  if (emailValue.isNotEmpty) {
                    final emailPrefix = emailValue.split('@').first;
                    if (value != emailPrefix) {
                      return 'Student ID must match the ID in email';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 6. ACADEMIC LEVEL
              _buildLabel('Academic Level'),
              DropdownButtonFormField<int>(
                value: _selectedLevel,
                onChanged: (val) => setState(() => _selectedLevel = val),
                style: const TextStyle(fontFamily: 'Inter', color: AppColors.onSurface),
                decoration: _buildInputDecoration(
                  hintText: 'Select Level',
                  icon: Icons.school_outlined,
                ),
                items: [1, 2, 3, 4].map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text('Level $level'),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // 7. PASSWORD
              _buildLabel('Password *'),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(fontFamily: 'Inter'),
                decoration: _buildInputDecoration(
                  hintText: '••••••••',
                  icon: Icons.lock_outline,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  final regex = RegExp(r'^(?=.*\d).{8,}$');
                  if (!regex.hasMatch(value)) {
                    return 'Password must be at least 8 characters and contain a number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 8. CONFIRM PASSWORD
              _buildLabel('Confirm Password *'),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                style: const TextStyle(fontFamily: 'Inter'),
                decoration: _buildInputDecoration(
                  hintText: '••••••••',
                  icon: Icons.lock_clock_outlined,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Passwords do not match';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
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
                child: state is AuthLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: AppColors.onPrimary),
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
                          const Icon(Icons.arrow_forward),
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
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    // 🎯 GLOBAL UI REQUIREMENTS: Mandatory fields show red asterisk
    final bool isMandatory = text.contains('*');
    if (!isMandatory) {
      return Padding(
        padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.s),
        child: Text(text, style: AppTextStyles.labelSmall),
      );
    }

    final String cleanText = text.replaceFirst('*', '').trim();
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.s),
      child: RichText(
        text: TextSpan(
          text: cleanText,
          style: AppTextStyles.labelSmall,
          children: const [
            TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: AppColors.outline.withOpacity(0.6)),
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      prefixIcon: Icon(icon, color: AppColors.outline),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      errorStyle: const TextStyle(color: Colors.red),
      // Validation Error UI requirements
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}
