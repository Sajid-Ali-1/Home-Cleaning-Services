import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/auth_controller.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOutCubic,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        Get.put(AuthController(), permanent: true);
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final accent = theme.accent1;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) =>
            Opacity(opacity: _fadeAnimation.value, child: child),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: theme.primaryBackground,
            // gradient: LinearGradient(
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            //   colors: [
            //     accent.withOpacity(0.1),
            //     theme.primaryBackground,
            //     theme.secondaryBackground,
            //   ],
            // ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // _DecorCircle(
                //   diameter: 240.r,
                //   color: accent.withOpacity(0.12),
                //   top: -80.h,
                //   right: -60.w,
                // ),
                // _DecorCircle(
                //   diameter: 180.r,
                //   color: accent.withOpacity(0.08),
                //   bottom: -40.h,
                //   left: -30.w,
                // ),
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 96.r,
                            height: 96.r,
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(32.r),
                              border: Border.all(color: accent),
                            ),
                            child: Icon(
                              Icons.cleaning_services_rounded,
                              color: Colors.white,
                              size: 48.r,
                            ),
                          ),
                          SizedBox(height: 32.h),
                          Text(
                            'Sparkle-ready homes,\nright on schedule.',
                            textAlign: TextAlign.center,
                            style: AppTheme.of(context).displayLarge,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'We love the details so you can love your downtime.',
                            textAlign: TextAlign.center,
                            style: theme.bodyMedium.copyWith(
                              color: theme.textGreyColor,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _LoadingBar(accent: accent, theme: theme),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar({required this.theme, required this.accent});

  final AppTheme theme;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          minHeight: 6.r,
          borderRadius: BorderRadius.circular(16.r),
          backgroundColor: accent.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(accent),
        ),
        SizedBox(height: 12.h),
        Text(
          'Loading...',
          style: theme.labelMedium.copyWith(
            color: theme.textGreyColor,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
