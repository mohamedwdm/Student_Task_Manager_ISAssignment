import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../../core/theme/colors.dart';
import 'login_form.dart';

class LoginViewBody extends StatelessWidget {
  const LoginViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isXl = size.width > 1200;

    return Stack(
      children: [
        // Background Blobs
        Positioned(
          top: -size.height * 0.1, left: -size.width * 0.1,
          child: Container(
            width: size.width * 0.4, height: size.height * 0.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondaryContainer.withOpacity(0.2),
              boxShadow: [BoxShadow(color: AppColors.secondaryContainer.withOpacity(0.2), blurRadius: 120, spreadRadius: 120)],
            ),
          ),
        ),
        Positioned(
          bottom: -size.height * 0.1, right: -size.width * 0.1,
          child: Container(
            width: size.width * 0.4, height: size.height * 0.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryContainer.withOpacity(0.2),
              boxShadow: [BoxShadow(color: AppColors.primaryContainer.withOpacity(0.2), blurRadius: 120, spreadRadius: 120)],
            ),
          ),
        ),
        
        // XL Side Images
        if (isXl) ...[
          Positioned(
            top: 48, left: 48, width: 256, height: 384,
            child: Transform.rotate(
              angle: -0.1, 
              child: ClipRRect(
                borderRadius: BorderRadius.circular(48),
                child: Opacity(
                  opacity: 0.4,
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0,      0,      0,      1, 0,
                    ]),
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCvhn7bs1dGF-81OwkVCdPP9Hmu0H8fmiLuMIEw20vg5AB9wFnNMFBMnUnTTlabr0zlAT0mBvogtWw7-bpwfRUpAHmUkP6JCqqjOb31Qf8MfygQ1ERJw8k6S8bnmWwOpxtBabHyGPCqchZ-5q3Nya9sV2ybtLzEZordQWhl7Pmq5L8xPG32h-PuwJKw-Q30dTH0NeTurP2udB4eXHakRSgUP9cWvQMMc4nvuLdmJoRAYfumXpveLX9_UTY7ulbPWyg-h-P6BHyS5y0',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 48, right: 48, width: 320, height: 192,
            child: Transform.rotate(
              angle: 0.05,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(48),
                child: Opacity(
                  opacity: 0.2,
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBkoMVIiKp4UJtR1ei9ZBVDXPHWK7E5kLEkfn1eW7ZDgG5smVzfUuXbtJFVWwUmHluGDDsUw37GDDsUw37GGDq-8ctCWqQV9PAlD1ESz365_L4FzpZaYwzr4oT2_wgzqezVnKFibVH8j7X-MkzNfBuJDYLMyh7EdHdA1j85sliHtf_l35HKLLqo_bsLAu9jnzPoZu6izfeBvNAwwgeI1NmZnD4fL9y_dBPGGafX7f_paqAQ-PVlXATZh45LyxkuLxMzaxuPI1S-678O_VVcwTI',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],

        // Main Content
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Column(
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryContainer]),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 8))],
                    ),
                    child: const Icon(Icons.auto_stories, color: AppColors.onPrimary, size: 32),
                  ),
                  const SizedBox(height: 16),
                  const Text('UniTask', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.onSurface, letterSpacing: -1)),
                  const SizedBox(height: 4),
                  Text('SCHOLARLY CURATOR', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant.withOpacity(0.7), letterSpacing: 2)),
                  const SizedBox(height: 40),

                  // Login Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest.withOpacity(0.8),
                          border: Border.all(color: AppColors.outline.withOpacity(0.1)),
                        ),
                        child: const LoginForm(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),
                  Opacity(
                    opacity: 0.4,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.verified_user_outlined, size: 24, color: AppColors.onSurface), SizedBox(width: 32),
                            Icon(Icons.school_outlined, size: 24, color: AppColors.onSurface), SizedBox(width: 32),
                            Icon(Icons.terminal_outlined, size: 24, color: AppColors.onSurface),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text('© 2024 ACADEMIC CURATOR PLATFORM', style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant, letterSpacing: 2)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
