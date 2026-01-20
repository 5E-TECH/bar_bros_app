import 'package:bar_bros_user/core/widgets/buttom_navigation_widget.dart';
import 'package:bar_bros_user/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bar_bros_user/signin_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_colors.dart';

class SplashPageSlideUp extends StatefulWidget {
  const SplashPageSlideUp({super.key});

  @override
  State<SplashPageSlideUp> createState() => _SplashPageSlideUpState();
}

class _SplashPageSlideUpState extends State<SplashPageSlideUp>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _logoController;
  late AnimationController _textController;

  late Animation<double> _orangeSlideAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _largeTextScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Background animation controller
    _backgroundController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    // Logo animation controller
    _logoController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    // Orange gradient slide animation
    _orangeSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOutCubic,
    ));

    // Logo animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Interval(0.3, 1.0, curve: Curves.elasticOut),
    ));

    _logoRotateAnimation = Tween<double>(
      begin: -0.5,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Interval(0.3, 1.0, curve: Curves.easeOutBack),
    ));

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    // Text animations
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    _largeTextScaleAnimation = Tween<double>(
      begin: 1.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutBack,
    ));

    // Start animations in sequence
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(Duration(milliseconds: 300));
    _backgroundController.forward();

    await Future.delayed(Duration(milliseconds: 300));
    _logoController.forward();

    await Future.delayed(Duration(milliseconds: 300));
    _textController.forward();

    await Future.delayed(Duration(milliseconds: 300));
    context.read<AuthBloc>().add(CheckAuthStatusEvent());
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppColors.primaryDark : AppColors.primaryLight;
    final backgroundGradientEnd = isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final logoContainerColor = isDarkMode
        ? AppColors.primaryDark.withValues(alpha: 0.8)
        : Colors.white.withValues(alpha: 0.9);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AdvancedCurvedBottomNav(),
              ),
            );
          } else if (state is AuthUnauthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SignInPage()),
            );
          }
        },
        child: Stack(
          children: [
            // Animated background
            AnimatedBuilder(
              animation: _orangeSlideAnimation,
              builder: (context, child) {
                return ClipPath(
                  clipper: DiagonalClipper(_orangeSlideAnimation.value),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.gradient1,
                          AppColors.gradient2,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    backgroundColor,
                    backgroundGradientEnd,
                  ],
                ),
              ),
            ),

            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoFadeAnimation.value,
                        child: Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: Transform.rotate(
                            angle: _logoRotateAnimation.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: logoContainerColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.yellow.withValues(alpha: 0.3),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.content_cut_rounded,
                                  size: 60,
                                  color: AppColors.yellow,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 40),

                  // Animated Text
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _textFadeAnimation,
                        child: SlideTransition(
                          position: _textSlideAnimation,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Large "S"
                              Transform.scale(
                                scale: _largeTextScaleAnimation.value,
                                child: ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [
                                      textColor,
                                      textColor
                                    ],
                                  ).createShader(bounds),
                                  child: Text(
                                    "splash_s".tr(),
                                    style: TextStyle(
                                      fontFamily: "Comic",
                                      fontSize: 70,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),

                              // Rest of "TYLE"
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Text(
                                  "splash_tyle".tr(),
                                  style: TextStyle(
                                    fontFamily: "Comic",
                                    fontSize: 45,
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),

                              SizedBox(width: 8),

                              // "UP" in red circle
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Container(
                                  width: 65,
                                  height: 65,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.yellow,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withValues(alpha: 0.4),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      "splash_up".tr(),
                                      style: TextStyle(
                                        fontFamily: "Comic",
                                        fontSize: 30,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom clipper for diagonal slide effect
class DiagonalClipper extends CustomClipper<Path> {
  final double progress;

  DiagonalClipper(this.progress);

  @override
  Path getClip(Size size) {
    final path = Path();

    // Calculate the diagonal sweep
    final sweepWidth = size.width * 1.5 * progress;

    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(sweepWidth - size.height, size.height);
    path.lineTo(sweepWidth, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(DiagonalClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}
