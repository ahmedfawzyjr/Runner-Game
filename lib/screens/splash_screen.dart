// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio/audio_manager.dart';
import '../core/game_state.dart';
import 'home_screen.dart';

/// Premium animated splash screen with character logo
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _characterController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _characterBounce;

  double _loadingProgress = 0;
  String _loadingText = 'Initializing...';

  @override
  void initState() {
    super.initState();

    // Fade animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Scale animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Glow pulsing animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _glowAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowController.repeat(reverse: true);

    // Character bounce animation
    _characterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _characterBounce = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _characterController, curve: Curves.elasticOut),
    );

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _scaleController.forward();
      _characterController.forward();
    });

    // Load data and navigate
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Step 1: Initialize game state
    setState(() {
      _loadingProgress = 0.2;
      _loadingText = 'Loading game data...';
    });
    await GameState().loadData();
    await Future.delayed(const Duration(milliseconds: 400));

    // Step 2: Initialize audio
    setState(() {
      _loadingProgress = 0.5;
      _loadingText = 'Loading audio...';
    });
    await AudioManager().init();
    await Future.delayed(const Duration(milliseconds: 400));

    // Step 3: Preload assets
    setState(() {
      _loadingProgress = 0.8;
      _loadingText = 'Preparing game...';
    });
    await Future.delayed(const Duration(milliseconds: 500));

    // Step 4: Complete
    setState(() {
      _loadingProgress = 1.0;
      _loadingText = 'Ready!';
    });
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    _characterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final characterSize = (size.width * 0.45).clamp(140.0, 220.0);
    final titleFontSize = (size.width * 0.09).clamp(28.0, 52.0);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFF1A0A2E),
              Color(0xFF0D0D1A),
              Color(0xFF050510),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            ...List.generate(12, (i) => _buildParticle(i, size)),

            // Main content
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _fadeAnimation,
                  _scaleAnimation,
                  _glowAnimation,
                  _characterBounce,
                ]),
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Character with neon glow
                        Transform.translate(
                          offset: Offset(0, -20 * (1 - _characterBounce.value)),
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              width: characterSize,
                              height: characterSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.cyan.withOpacity(
                                        0.6 * _glowAnimation.value),
                                    blurRadius: 50,
                                    spreadRadius: 15,
                                  ),
                                  BoxShadow(
                                    color: Colors.purple.withOpacity(
                                        0.4 * _glowAnimation.value),
                                    blurRadius: 80,
                                    spreadRadius: 25,
                                  ),
                                  BoxShadow(
                                    color: Colors.pink.withOpacity(
                                        0.2 * _glowAnimation.value),
                                    blurRadius: 100,
                                    spreadRadius: 35,
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.cyan.withOpacity(0.5),
                                    width: 3,
                                  ),
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.cyan.withOpacity(0.1),
                                      Colors.purple.withOpacity(0.05),
                                    ],
                                  ),
                                ),
                                padding: const EdgeInsets.all(15),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/Run__001.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.directions_run,
                                        size: characterSize * 0.5,
                                        color: Colors.cyan.shade300,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 25 : 40),
                        // Title with gradient
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Colors.cyan.shade300,
                              Colors.purple.shade300,
                              Colors.pink.shade300,
                            ],
                          ).createShader(bounds),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'NEON RUNNER',
                              style: GoogleFonts.orbitron(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 6,
                                shadows: [
                                  Shadow(
                                    color: Colors.cyan.withOpacity(0.5),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 12),
                        // Tagline
                        Text(
                          'RUN • FIGHT • SURVIVE',
                          style: GoogleFonts.rajdhani(
                            color: Colors.grey.shade500,
                            fontSize: isSmallScreen ? 12 : 14,
                            letterSpacing: 6,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 40 : 60),
                        // Progress bar
                        SizedBox(
                          width: (size.width * 0.6).clamp(180.0, 280.0),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: _loadingProgress),
                                  duration: const Duration(milliseconds: 300),
                                  builder: (context, value, child) {
                                    return Stack(
                                      children: [
                                        Container(
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade900,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        FractionallySizedBox(
                                          widthFactor: value,
                                          child: Container(
                                            height: 6,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: const [
                                                  Colors.cyan,
                                                  Colors.purple,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.cyan
                                                      .withOpacity(0.5),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 12 : 16),
                              Text(
                                _loadingText,
                                style: GoogleFonts.rajdhani(
                                  color: Colors.grey.shade400,
                                  fontSize: isSmallScreen ? 13 : 15,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticle(int index, Size size) {
    final positions = [
      Offset(size.width * 0.1, size.height * 0.2),
      Offset(size.width * 0.85, size.height * 0.15),
      Offset(size.width * 0.15, size.height * 0.7),
      Offset(size.width * 0.9, size.height * 0.65),
      Offset(size.width * 0.5, size.height * 0.1),
      Offset(size.width * 0.3, size.height * 0.85),
      Offset(size.width * 0.7, size.height * 0.8),
      Offset(size.width * 0.05, size.height * 0.45),
      Offset(size.width * 0.95, size.height * 0.4),
      Offset(size.width * 0.4, size.height * 0.9),
      Offset(size.width * 0.6, size.height * 0.05),
      Offset(size.width * 0.2, size.height * 0.5),
    ];

    final colors = [
      Colors.cyan.withOpacity(0.3),
      Colors.purple.withOpacity(0.3),
      Colors.pink.withOpacity(0.3),
    ];

    return Positioned(
      left: positions[index].dx,
      top: positions[index].dy,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            width: 4 + (index % 3) * 2,
            height: 4 + (index % 3) * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors[index % 3],
              boxShadow: [
                BoxShadow(
                  color: colors[index % 3].withOpacity(_glowAnimation.value),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
