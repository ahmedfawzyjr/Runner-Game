// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio/audio_manager.dart';
import '../core/game_config.dart';
import '../core/game_state.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';
import 'settings_screen.dart';
import 'character_select_screen.dart';

/// Premium home screen with enhanced visuals and animations
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _rotationController;
  late AnimationController _floatController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for play button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pulseAnimation = Tween<double>(begin: 1, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // Glow animation for ambient effects
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 1).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowController.repeat(reverse: true);

    // Rotation for character ring - faster for dynamic feel
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Float animation for character
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _floatController.repeat(reverse: true);

    AudioManager().playMenuMusic();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _rotationController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _startGame() {
    AudioManager().playButton();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const GameScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _openSettings() {
    AudioManager().playButton();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _openLeaderboard() {
    AudioManager().playButton();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
    );
  }

  void _changeDifficulty() {
    AudioManager().playSelect();
    final state = GameState();
    setState(() {
      final currentIndex = state.difficulty.index;
      final nextIndex = (currentIndex + 1) % Difficulty.values.length;
      state.difficulty = Difficulty.values[nextIndex];
      state.saveData();
    });
  }

  void _openCharacterSelect() {
    AudioManager().playButton();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CharacterSelectScreen(
          onSelected: () => setState(() {}),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    // Unified responsive sizing for symmetry
    final verticalSpacing = size.height * 0.018;
    final titleFontSize = (size.width * 0.08).clamp(26.0, 48.0);
    
    // Unified width for badges and buttons
    final unifiedWidth = (size.width * 0.65).clamp(220.0, 320.0);
    final buttonHeight = (size.height * 0.06).clamp(44.0, 54.0);
    
    final characterSize = isLandscape
        ? (size.height * 0.30).clamp(120.0, 220.0)
        : (size.width * 0.38).clamp(120.0, 220.0);
    final iconButtonSize = (size.width * 0.13).clamp(48.0, 64.0);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A1A),
              Color(0xFF12082A),
              Color(0xFF1A0A3E),
              Color(0xFF0D0D1A),
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated mesh gradient background
            _buildMeshGradient(size),

            // Dynamic floating particles
            ...List.generate(20, (i) => _buildFloatingParticle(i, size)),

            // Scan line effect
            _buildScanLines(size),

            // Main content
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                ),
                child: Column(
                  children: [
                    SizedBox(height: verticalSpacing),

                    // Enhanced title with multi-layer glow
                    _buildTitle(titleFontSize),

                    SizedBox(height: verticalSpacing),

                    // High score badge - unified width
                    _buildHighScoreBadge(unifiedWidth, buttonHeight),

                    SizedBox(height: verticalSpacing),

                    // Character preview with animated ring
                    Expanded(
                      child: Center(
                        child: _buildCharacterPreview(characterSize),
                      ),
                    ),

                    SizedBox(height: verticalSpacing),

                    // Difficulty selector - unified width
                    GestureDetector(
                      onTap: _changeDifficulty,
                      child: _buildDifficultyBadge(unifiedWidth, buttonHeight),
                    ),

                    SizedBox(height: verticalSpacing),

                    // Play button - unified width
                    _buildPlayButton(unifiedWidth, buttonHeight),

                    SizedBox(height: verticalSpacing * 1.2),

                    // Bottom action buttons
                    _buildBottomButtons(iconButtonSize),

                    SizedBox(height: verticalSpacing),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeshGradient(Size size) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: size,
          painter: _MeshGradientPainter(
            animationValue: _glowAnimation.value,
          ),
        );
      },
    );
  }

  Widget _buildScanLines(Size size) {
    return Opacity(
      opacity: 0.03,
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          backgroundBlendMode: BlendMode.overlay,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: List.generate(50, (i) {
              return i.isEven
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.1);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(double fontSize) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Column(
          children: [
            // Main title with layered glow
            Stack(
              children: [
                // Outer glow layer
                Text(
                  'NEON',
                  style: GoogleFonts.audiowide(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 8
                      ..color = Colors.cyan.withOpacity(0.2 * _glowAnimation.value),
                  ),
                ),
                // Mid glow layer
                Text(
                  'NEON',
                  style: GoogleFonts.audiowide(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 4
                      ..color = Colors.purple.withOpacity(0.3 * _glowAnimation.value),
                  ),
                ),
                // Main gradient text
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.cyan.shade200,
                      Colors.cyan.shade400,
                      Colors.purple.shade300,
                      Colors.pink.shade300,
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ).createShader(bounds),
                  child: Text(
                    'NEON',
                    style: GoogleFonts.audiowide(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 3,
                      shadows: [
                        Shadow(
                          color: Colors.cyan.withOpacity(0.8),
                          blurRadius: 20,
                        ),
                        Shadow(
                          color: Colors.purple.withOpacity(0.5),
                          blurRadius: 40,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Subtitle
            Text(
              'ENDLESS ADVENTURE',
              style: GoogleFonts.rajdhani(
                fontSize: fontSize * 0.32,
                color: Colors.cyan.shade200.withOpacity(0.7),
                fontWeight: FontWeight.w500,
                letterSpacing: 8,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHighScoreBadge(double width, double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.withOpacity(0.12),
                    Colors.orange.withOpacity(0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(height / 2),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.4 + 0.2 * _glowAnimation.value),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.amber,
                    size: height * 0.45,
                  ),
                  SizedBox(width: height * 0.2),
                  Text(
                    'BEST: ${GameState().highScores[GameState().difficulty]}',
                    style: GoogleFonts.audiowide(
                      fontSize: height * 0.32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCharacterPreview(double characterSize) {
    return GestureDetector(
      onTap: _openCharacterSelect,
      child: AnimatedBuilder(
        animation: Listenable.merge([_glowAnimation, _floatAnimation, _rotationController]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: SizedBox(
              width: characterSize * 1.15,
              height: characterSize * 1.15,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer rotating ring
                  Transform.rotate(
                    angle: _rotationController.value * 2 * math.pi,
                    child: Container(
                      width: characterSize * 1.12,
                      height: characterSize * 1.12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            Colors.cyan.withOpacity(0.8),
                            Colors.transparent,
                            Colors.purple.withOpacity(0.8),
                            Colors.transparent,
                            Colors.cyan.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Inner container
                  Container(
                    width: characterSize,
                    height: characterSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0D0D1A),
                      border: Border.all(
                        color: Colors.cyan.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withOpacity(0.3 * _glowAnimation.value),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.2 * _glowAnimation.value),
                          blurRadius: 50,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Radial gradient background
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.cyan.withOpacity(0.15),
                                Colors.purple.withOpacity(0.08),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        // Character image
                        Padding(
                          padding: EdgeInsets.all(characterSize * 0.08),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/platform/Sprites/Characters/Default/character_${GameState().selectedCharacter}_idle.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/Run__001.png',
                                  fit: BoxFit.contain,
                                );
                              },
                            ),
                          ),
                        ),

                        // "Tap to change" label
                        Positioned(
                          bottom: characterSize * 0.08,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.cyan.withOpacity(0.6),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.cyan.withOpacity(0.3),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.touch_app_rounded,
                                  size: 12,
                                  color: Colors.cyan.shade200,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'TAP TO CHANGE',
                                  style: GoogleFonts.rajdhani(
                                    fontSize: 11,
                                    color: Colors.cyan.shade200,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Corner accents
                  ..._buildCornerAccents(characterSize),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildCornerAccents(double size) {
    const positions = [
      Alignment(-0.85, -0.85),
      Alignment(0.85, -0.85),
      Alignment(-0.85, 0.85),
      Alignment(0.85, 0.85),
    ];

    return positions.map((alignment) {
      return Align(
        alignment: alignment,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.cyan.withOpacity(0.8),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.cyan.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildDifficultyBadge(double width, double height) {
    final difficultyColor = _getDifficultyColor();

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    difficultyColor.withOpacity(0.15),
                    difficultyColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(height / 2),
                border: Border.all(
                  color: difficultyColor.withOpacity(0.5 + 0.2 * _glowAnimation.value),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getDifficultyIcon(),
                    color: difficultyColor,
                    size: height * 0.45,
                  ),
                  SizedBox(width: height * 0.2),
                  Text(
                    GameConfig.difficulties[GameState().difficulty]!.name.toUpperCase(),
                    style: GoogleFonts.audiowide(
                      fontSize: height * 0.32,
                      color: difficultyColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: height * 0.15),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: difficultyColor.withOpacity(0.7),
                    size: height * 0.4,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlayButton(double width, double height) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: GestureDetector(
        onTap: _startGame,
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF00D4FF),
                    Color(0xFF7B2FFF),
                    Color(0xFFFF2D92),
                  ],
                ),
                borderRadius: BorderRadius.circular(height / 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.5 * _glowAnimation.value),
                    blurRadius: 25,
                    spreadRadius: 3,
                    offset: const Offset(-5, 0),
                  ),
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.4 * _glowAnimation.value),
                    blurRadius: 35,
                    spreadRadius: 5,
                    offset: const Offset(5, 5),
                  ),
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.3 * _glowAnimation.value),
                    blurRadius: 45,
                    spreadRadius: 8,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Shine effect
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(height / 2),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.25),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: height * 0.4,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'PLAY',
                          style: GoogleFonts.audiowide(
                            fontSize: height * 0.32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 6,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
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
    );
  }

  Widget _buildBottomButtons(double buttonSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIconButton(
          Icons.leaderboard_rounded,
          'Ranks',
          _openLeaderboard,
          Colors.amber,
          buttonSize,
        ),
        SizedBox(width: buttonSize * 0.8),
        _buildIconButton(
          Icons.settings_rounded,
          'Settings',
          _openSettings,
          Colors.grey.shade400,
          buttonSize,
        ),
      ],
    );
  }

  Widget _buildIconButton(
    IconData icon,
    String label,
    VoidCallback onTap,
    Color color,
    double buttonSize,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(buttonSize / 3),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: buttonSize * 1.4,
                height: buttonSize * 1.4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(buttonSize / 3),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.2),
                      color.withOpacity(0.08),
                    ],
                  ),
                  border: Border.all(
                    color: color.withOpacity(0.4 + 0.2 * _glowAnimation.value),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2 * _glowAnimation.value),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          color,
                          color.withOpacity(0.7),
                        ],
                      ).createShader(bounds),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: buttonSize * 0.55,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: GoogleFonts.rajdhani(
                        color: color.withOpacity(0.9),
                        fontSize: buttonSize * 0.22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingParticle(int index, Size size) {
    final random = math.Random(index * 42);
    final startX = random.nextDouble() * size.width;
    final startY = random.nextDouble() * size.height;
    final particleSize = 2.0 + random.nextDouble() * 4;

    final colors = [
      Colors.cyan,
      Colors.purple,
      Colors.pink,
      Colors.blue,
    ];

    return Positioned(
      left: startX,
      top: startY,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          final floatOffset = math.sin(
            _glowAnimation.value * math.pi * 2 + index * 0.5,
          ) * 8;

          return Transform.translate(
            offset: Offset(0, floatOffset),
            child: Container(
              width: particleSize,
              height: particleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors[index % colors.length].withOpacity(
                  0.3 + 0.4 * _glowAnimation.value * (random.nextDouble()),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors[index % colors.length].withOpacity(
                      0.5 * _glowAnimation.value,
                    ),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (GameState().difficulty) {
      case Difficulty.easy:
        return const Color(0xFF4ADE80);
      case Difficulty.medium:
        return const Color(0xFFFBBF24);
      case Difficulty.hard:
        return const Color(0xFFEF4444);
    }
  }

  IconData _getDifficultyIcon() {
    switch (GameState().difficulty) {
      case Difficulty.easy:
        return Icons.sentiment_satisfied_rounded;
      case Difficulty.medium:
        return Icons.speed_rounded;
      case Difficulty.hard:
        return Icons.local_fire_department_rounded;
    }
  }
}

/// Custom painter for animated mesh gradient background
class _MeshGradientPainter extends CustomPainter {
  final double animationValue;

  _MeshGradientPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Cyan orb - top right
    paint.shader = RadialGradient(
      center: Alignment.center,
      radius: 0.8,
      colors: [
        Colors.cyan.withOpacity(0.15 * animationValue),
        Colors.transparent,
      ],
    ).createShader(
      Rect.fromCircle(
        center: Offset(size.width * 0.85, size.height * 0.15),
        radius: size.width * 0.5,
      ),
    );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      size.width * 0.5,
      paint,
    );

    // Purple orb - bottom left
    paint.shader = RadialGradient(
      center: Alignment.center,
      radius: 0.8,
      colors: [
        Colors.purple.withOpacity(0.12 * animationValue),
        Colors.transparent,
      ],
    ).createShader(
      Rect.fromCircle(
        center: Offset(size.width * 0.15, size.height * 0.75),
        radius: size.width * 0.6,
      ),
    );
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.75),
      size.width * 0.6,
      paint,
    );

    // Pink orb - center bottom
    paint.shader = RadialGradient(
      center: Alignment.center,
      radius: 0.8,
      colors: [
        Colors.pink.withOpacity(0.08 * animationValue),
        Colors.transparent,
      ],
    ).createShader(
      Rect.fromCircle(
        center: Offset(size.width * 0.5, size.height * 0.9),
        radius: size.width * 0.4,
      ),
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.9),
      size.width * 0.4,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _MeshGradientPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
