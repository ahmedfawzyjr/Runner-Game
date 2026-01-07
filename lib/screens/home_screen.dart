// ignore_for_file: deprecated_member_use

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

/// Premium home screen with balanced layout
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _glowAnimation = Tween<double>(begin: 0.4, end: 1).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowController.repeat(reverse: true);

    AudioManager().playMenuMusic();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
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
    
    // Consistent spacing values
    final verticalSpacing = size.height * 0.025;  // 2.5% of height
    final smallSpacing = size.height * 0.015;     // 1.5% of height
    
    // Responsive sizes - all proportional
    final titleFontSize = (size.width * 0.08).clamp(24.0, 44.0);
    final characterSize = isLandscape 
        ? (size.height * 0.38).clamp(120.0, 200.0)
        : (size.width * 0.42).clamp(130.0, 220.0);
    final playButtonWidth = (size.width * 0.55).clamp(180.0, 280.0);
    final playButtonHeight = (size.height * 0.075).clamp(48.0, 65.0);
    final iconButtonSize = (size.width * 0.12).clamp(44.0, 56.0);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.5),
            radius: 1.5,
            colors: [
              Color(0xFF1A0A2E),
              Color(0xFF0D0D1A),
              Color(0xFF050510),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background particles
            ...List.generate(12, (i) => _buildBackgroundParticle(i, size)),
            
            // Main content
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.06,
                ),
                child: Column(
                  children: [
                    SizedBox(height: verticalSpacing),
                    
                    // Title - Audiowide font
                    AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyan.withOpacity(0.25 * _glowAnimation.value),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Colors.cyan.shade300,
                                Colors.purple.shade300,
                                Colors.pink.shade300,
                              ],
                            ).createShader(bounds),
                            child: Text(
                              'NEON RUNNER',
                              style: GoogleFonts.audiowide(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    SizedBox(height: smallSpacing),
                    
                    // High score badge
                    _buildHighScoreBadge(size),
                    
                    SizedBox(height: verticalSpacing),
                    
                    // Character preview
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: GestureDetector(
                          onTap: _openCharacterSelect,
                          child: AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) {
                              return Container(
                                width: characterSize,
                                height: characterSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.cyan.withOpacity(0.7),
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.cyan.withOpacity(0.4 * _glowAnimation.value),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.cyan.withOpacity(0.1),
                                      Colors.purple.withOpacity(0.05),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10),
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
                                    Positioned(
                                      bottom: 6,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.cyan.withOpacity(0.4),
                                          ),
                                        ),
                                        child: Text(
                                          'TAP TO CHANGE',
                                          style: GoogleFonts.rajdhani(
                                            fontSize: 9,
                                            color: Colors.cyan.shade200,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: smallSpacing),
                    
                    // Difficulty selector
                    GestureDetector(
                      onTap: _changeDifficulty,
                      child: _buildDifficultyBadge(size),
                    ),
                    
                    SizedBox(height: verticalSpacing),
                    
                    // Play button
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: GestureDetector(
                        onTap: _startGame,
                        child: Container(
                          width: playButtonWidth,
                          height: playButtonHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.cyan.shade400,
                                Colors.purple.shade400,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(playButtonHeight / 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyan.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.3),
                                blurRadius: 35,
                                spreadRadius: 5,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: playButtonHeight * 0.5,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'PLAY',
                                style: GoogleFonts.audiowide(
                                  fontSize: playButtonHeight * 0.35,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: verticalSpacing),
                    
                    // Bottom buttons
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildIconButton(
                            Icons.leaderboard_rounded,
                            'Leaderboard',
                            _openLeaderboard,
                            Colors.amber,
                            iconButtonSize,
                          ),
                          SizedBox(width: size.width * 0.15),
                          _buildIconButton(
                            Icons.settings_rounded,
                            'Settings',
                            _openSettings,
                            Colors.grey.shade400,
                            iconButtonSize,
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: smallSpacing),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighScoreBadge(Size size) {
    final badgePadding = (size.width * 0.04).clamp(14.0, 22.0);
    final fontSize = (size.width * 0.04).clamp(14.0, 18.0);
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: badgePadding,
            vertical: badgePadding * 0.5,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events_rounded, color: Colors.amber, size: fontSize + 4),
              SizedBox(width: fontSize * 0.5),
              Text(
                'Best: ${GameState().highScores[GameState().difficulty]}',
                style: GoogleFonts.audiowide(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(Size size) {
    final badgePadding = (size.width * 0.045).clamp(16.0, 26.0);
    final fontSize = (size.width * 0.04).clamp(14.0, 18.0);
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: badgePadding,
            vertical: badgePadding * 0.5,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getDifficultyColor().withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.speed_rounded,
                color: _getDifficultyColor(),
                size: fontSize + 6,
              ),
              SizedBox(width: fontSize * 0.6),
              Text(
                GameConfig.difficulties[GameState().difficulty]!.name.toUpperCase(),
                style: GoogleFonts.audiowide(
                  fontSize: fontSize,
                  color: _getDifficultyColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: fontSize * 0.4),
              Icon(
                Icons.chevron_right_rounded,
                color: _getDifficultyColor().withOpacity(0.7),
                size: fontSize + 4,
              ),
            ],
          ),
        ),
      ),
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
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: buttonSize * 1.3,
                height: buttonSize * 1.3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(buttonSize / 3),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.15),
                      color.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(
                    color: color.withOpacity(0.4 + 0.2 * _glowAnimation.value),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.25 * _glowAnimation.value),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: color,
                      size: buttonSize * 0.55,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: GoogleFonts.rajdhani(
                        color: color.withOpacity(0.9),
                        fontSize: buttonSize * 0.2,
                        fontWeight: FontWeight.w600,
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

  Widget _buildBackgroundParticle(int index, Size size) {
    final positions = [
      Offset(size.width * 0.08, size.height * 0.12),
      Offset(size.width * 0.92, size.height * 0.1),
      Offset(size.width * 0.12, size.height * 0.65),
      Offset(size.width * 0.88, size.height * 0.7),
      Offset(size.width * 0.5, size.height * 0.06),
      Offset(size.width * 0.22, size.height * 0.88),
      Offset(size.width * 0.78, size.height * 0.85),
      Offset(size.width * 0.04, size.height * 0.4),
      Offset(size.width * 0.96, size.height * 0.45),
      Offset(size.width * 0.38, size.height * 0.92),
      Offset(size.width * 0.62, size.height * 0.04),
      Offset(size.width * 0.18, size.height * 0.55),
    ];

    final colors = [
      Colors.cyan.withOpacity(0.2),
      Colors.purple.withOpacity(0.2),
      Colors.pink.withOpacity(0.15),
    ];

    return Positioned(
      left: positions[index].dx,
      top: positions[index].dy,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            width: 3 + (index % 3) * 1.5,
            height: 3 + (index % 3) * 1.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors[index % 3],
              boxShadow: [
                BoxShadow(
                  color: colors[index % 3].withOpacity(_glowAnimation.value * 0.6),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (GameState().difficulty) {
      case Difficulty.easy:
        return Colors.green.shade400;
      case Difficulty.medium:
        return Colors.orange.shade400;
      case Difficulty.hard:
        return Colors.red.shade400;
    }
  }
}
