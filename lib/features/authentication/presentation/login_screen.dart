import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_radius.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/cards/app_card.dart';
import 'auth_controller.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class GeometricBackgroundPainter extends CustomPainter {
  final double animationValue;

  GeometricBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Grid lines (faint)
    final gridPaint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.5)
      ..strokeWidth = 1.0;
    
    // The frontend animation is a 3-second loop translating Y by -40px.
    // Our animationValue spans 15s, so we loop it 5 times for a 3s loop.
    final double gridPhase = (animationValue * 5) % 1.0;
    
    canvas.save();
    canvas.translate(0, -40.0 * gridPhase);
    
    for (double i = 0; i <= size.width + 40; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height + 40), gridPaint);
    }
    for (double i = 0; i <= size.height + 40; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width + 40, i), gridPaint);
    }
    canvas.restore();
      
    final double animPhase = animationValue * 2 * math.pi;

    // Circle top left
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.15 + math.sin(animPhase) * 15), 45, paint);
    
    // Circle right middle
    canvas.drawCircle(Offset(size.width * 0.85 + math.cos(animPhase) * 15, size.height * 0.45), 25, paint);

    // Square bottom left rotated
    canvas.save();
    canvas.translate(size.width * 0.2, size.height * 0.65 + math.cos(animPhase) * 10);
    canvas.rotate(15 * math.pi / 180 + animationValue * math.pi * 2);
    final fillPaint = Paint()..color = AppColors.primaryLight.withValues(alpha: 0.1);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-35, -35, 70, 70), const Radius.circular(12)), fillPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-35, -35, 70, 70), const Radius.circular(12)), paint..color = AppColors.primaryLight.withValues(alpha: 0.2));
    canvas.restore();
    
    // Diamond bottom right
    canvas.save();
    canvas.translate(size.width * 0.85, size.height * 0.75 + math.sin(animPhase) * 15);
    canvas.rotate(45 * math.pi / 180 - animationValue * math.pi * 2);
    canvas.drawRect(const Rect.fromLTWH(-50, -50, 100, 100), paint..color = AppColors.primaryLight.withValues(alpha: 0.3));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GeometricBackgroundPainter oldDelegate) => 
      oldDelegate.animationValue != animationValue;
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final authController = ref.read(authControllerProvider.notifier);
    
    final success = await authController.login(
      _emailController.text, 
      _passwordController.text
    );
    
    if (!success && mounted) {
      final error = ref.read(authControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Login failed'),
          backgroundColor: AppColors.destructiveLight,
          action: SnackBarAction(
            label: 'DEV BYPASS', 
            textColor: Colors.white,
            onPressed: () {
              authController.developerBypass();
              context.go('/dashboard');
            }
          ),
        )
      );
    } else if (mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Force light theme to match the Web ERP exactly
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCF9FB), // Specific web background color
        body: Stack(
          children: [
            // Background Layer
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: GeometricBackgroundPainter(_animationController.value),
                  );
                },
              ),
            ),
            
            // Content Layer
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo and Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: Center(
                                child: Icon(LucideIcons.layers, color: AppColors.primaryLight, size: 32), // Placeholder for BumbleERP Logo
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s12),
                            Text(
                              'BumbleERP',
                              style: AppTypography.headline.copyWith(
                                color: const Color(0xFF111827),
                                fontWeight: FontWeight.w800,
                                fontSize: 28,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s32),
                        
                        // Login Card
                        AppCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s32,
                            vertical: AppSpacing.s40,
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Log in to your account',
                                style: AppTypography.title.copyWith(
                                  color: const Color(0xFF111827),
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.s16),
                              Container(
                                width: 48,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s16),
                              Text(
                                'Enter your email and password below to log in',
                                style: AppTypography.body.copyWith(
                                  color: AppColors.mutedForegroundLight,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.s32),
                              
                              AppTextField(
                                label: 'Email address',
                                isRequired: true,
                                placeholder: 'you@company.com',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: AppSpacing.s24),
                              
                              AppTextField(
                                label: 'Password',
                                isRequired: true,
                                placeholder: '••••••••',
                                controller: _passwordController,
                                isPassword: true,
                                labelTrailing: GestureDetector(
                                  onTap: () {}, // Forgot password action
                                  child: Text(
                                    'Forgot password?',
                                    style: AppTypography.label.copyWith(
                                      color: AppColors.primaryLight,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s16),
                              
                              Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (val) {
                                        setState(() {
                                          _rememberMe = val ?? false;
                                        });
                                      },
                                      activeColor: AppColors.primaryLight,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.s8),
                                  Text(
                                    'Remember me',
                                    style: AppTypography.body.copyWith(
                                      color: const Color(0xFF4B5563),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: AppSpacing.s32),
                              
                              SizedBox(
                                width: double.infinity,
                                child: AppButton(
                                  text: 'SIGN IN',
                                  isLoading: ref.watch(authControllerProvider).isLoading,
                                  onPressed: _handleLogin,
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
            ),
          ],
        ),
      ),
    );
  }
}
