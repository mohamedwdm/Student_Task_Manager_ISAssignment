import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../../core/theme/colors.dart';
import 'signup_form.dart';

class SignupViewBody extends StatelessWidget {
  const SignupViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isLg = size.width > 992;

    return Stack(
      children: [
        Positioned(
          top: -size.height * 0.1,
          left: -size.width * 0.05,
          child: Container(
            width: size.width * 0.4,
            height: size.height * 0.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerHigh.withOpacity(0.6),
              boxShadow: [
                BoxShadow(
                  color: AppColors.surfaceContainerHigh.withOpacity(0.6),
                  blurRadius: 120,
                  spreadRadius: 120,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: size.height * 0.05,
          right: -size.width * 0.05,
          child: Container(
            width: size.width * 0.35,
            height: size.height * 0.35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondaryContainer.withOpacity(0.4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondaryContainer.withOpacity(0.4),
                  blurRadius: 100,
                  spreadRadius: 100,
                ),
              ],
            ),
          ),
        ),

        Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isLg ? 24.0 : 16.0,
              vertical: 48.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.onSurface.withOpacity(0.05),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: isLg ? _buildDesktopLayout() : _buildMobileLayout(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildSidePanel()),
          Expanded(
            child: const Padding(
              padding: EdgeInsets.all(32.0),
              child: SignupForm(),
            ),
          ), // Uses isolated component
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return const Padding(padding: EdgeInsets.all(32.0), child: SignupForm());
  }

  Widget _buildSidePanel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 80,
                    spreadRadius: 80,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.auto_stories,
                          color: AppColors.onPrimary,
                          size: 32,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Academic Curator',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onPrimary,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Your scholarly\njourney begins here.',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 36,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onPrimary,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Experience a refined way to manage research, coursework, and campus deadlines in a digital curator designed for excellence.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        height: 1.6,
                        fontWeight: FontWeight.w300,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.tertiaryFixed,
                            ),
                            child: const Icon(
                              Icons.verified,
                              color: AppColors.onTertiaryFixed,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Official University Sync',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Access your curriculum and grades instantly with your Student ID.',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
