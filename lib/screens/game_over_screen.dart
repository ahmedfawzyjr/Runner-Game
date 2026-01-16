// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio/audio_manager.dart';
import '../core/game_config.dart';
import '../core/game_state.dart';
import 'game_screen.dart';
import 'home_screen.dart';

/// Premium game over screen with animated score and share dialog
class GameOverScreen extends StatefulWidget {
  const GameOverScreen({super.key});

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _countController;
  late AnimationController _glowController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _countAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _countController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _countAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _countController, curve: Curves.easeOutCubic),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _glowAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowController.repeat(reverse: true);

    _slideController.forward();
    _countController.forward();

    AudioManager().playGameOverMusic();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _countController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _playAgain() {
    AudioManager().playButton();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const GameScreen()),
    );
  }

  void _goHome() {
    AudioManager().playButton();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _shareScore() {
    AudioManager().playSelect();
    _showShareDialog();
  }

  void _showShareDialog() {
    final state = GameState();
    final difficulty = GameConfig.difficulties[state.difficulty]!.name;
    final message = '''🎮 Neon Runner
📊 Score: ${state.score}
💀 Kills: ${state.killCount}
🔥 Max Combo: ${state.maxCombo}x
⚡ Difficulty: $difficulty
Can you beat my score?''';

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Share',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return ScaleTransition(
          scale: curvedAnimation,
          child: FadeTransition(
            opacity: animation,
            child: Center(
              child: _ShareDialog(
                message: message,
                score: state.score,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = GameState();
    final isNewHighScore = state.score >= state.highScores[state.difficulty]!;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final isLandscape = size.width > size.height;

    // Responsive sizing
    final titleFontSize = (size.width * 0.09).clamp(28.0, 48.0);
    final scoreFontSize = (size.width * 0.15).clamp(48.0, 90.0);
    final cardPadding = isLandscape ? 40.0 : 24.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.5,
            colors: [
              Color(0xFF2A0A1E),
              Color(0xFF0D0D1A),
              Color(0xFF050510),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background particles
            ...List.generate(12, (i) => _buildParticle(i, size)),

            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: cardPadding),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              SizedBox(height: isSmallScreen ? 16 : 28),
                              // Game Over title
                              AnimatedBuilder(
                                animation: _glowAnimation,
                                builder: (context, child) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.3 * _glowAnimation.value),
                                          blurRadius: 40,
                                          spreadRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: ShaderMask(
                                      shaderCallback: (bounds) => const LinearGradient(
                                        colors: [Colors.red, Colors.orange, Colors.amber],
                                      ).createShader(bounds),
                                      child: Text(
                                        'GAME OVER',
                                        style: GoogleFonts.audiowide(
                                          fontSize: titleFontSize,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 3,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              if (isNewHighScore) ...[
                                SizedBox(height: isSmallScreen ? 12 : 18),
                                _buildNewHighScoreBadge(isSmallScreen),
                              ],
                              SizedBox(height: isSmallScreen ? 24 : 36),
                              // Score section
                              _buildScoreCard(state, scoreFontSize, isSmallScreen, isLandscape),
                              SizedBox(height: isSmallScreen ? 20 : 32),
                              // Stats grid
                              _buildStatsGrid(state, isSmallScreen, isLandscape),
                              SizedBox(height: isSmallScreen ? 24 : 36),
                              // Action buttons
                              _buildActionButtons(isSmallScreen),
                              SizedBox(height: isSmallScreen ? 16 : 24),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildNewHighScoreBadge(bool isSmall) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 20 : 28,
        vertical: isSmall ? 10 : 14,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.amber, Colors.orange],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_rounded, color: Colors.white, size: isSmall ? 20 : 24),
          SizedBox(width: isSmall ? 8 : 12),
          Text(
            'NEW HIGH SCORE!',
            style: GoogleFonts.audiowide(
              fontSize: isSmall ? 13 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(GameState state, double scoreFontSize, bool isSmall, bool isLandscape) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AnimatedBuilder(
          animation: Listenable.merge([_countAnimation, _glowAnimation]),
          builder: (context, child) {
            final displayScore = (state.score * _countAnimation.value).round();
            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isSmall ? 28 : 40,
                horizontal: 24,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.cyan.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.2 * _glowAnimation.value),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'FINAL SCORE',
                    style: GoogleFonts.rajdhani(
                      fontSize: isSmall ? 14 : 16,
                      color: Colors.grey.shade500,
                      letterSpacing: 6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: isSmall ? 8 : 12),
                  Text(
                    displayScore.toString(),
                    style: GoogleFonts.audiowide(
                      fontSize: scoreFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyan.shade300,
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

  Widget _buildStatsGrid(GameState state, bool isSmall, bool isLandscape) {
    final stats = [
      _StatItem('Kills', state.killCount.toString(), Icons.dangerous_rounded, Colors.red),
      _StatItem('Combo', '${state.maxCombo}x', Icons.flash_on_rounded, Colors.amber),
      _StatItem('Distance', '${(state.distanceTraveled / 100).toStringAsFixed(0)}m', Icons.straighten_rounded, Colors.green),
      _StatItem('Time', '${state.timeSurvived.toStringAsFixed(1)}s', Icons.timer_rounded, Colors.purple),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(isSmall ? 16 : 22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildStatTile(stats[0], isSmall)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatTile(stats[1], isSmall)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatTile(stats[2], isSmall)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatTile(stats[3], isSmall)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(_StatItem stat, bool isSmall) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      decoration: BoxDecoration(
        color: stat.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: stat.color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Icon(stat.icon, color: stat.color, size: isSmall ? 22 : 28),
          SizedBox(height: isSmall ? 6 : 10),
          Text(
            stat.value,
            style: GoogleFonts.audiowide(
              color: Colors.white,
              fontSize: isSmall ? 18 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isSmall ? 2 : 4),
          Text(
            stat.label,
            style: GoogleFonts.rajdhani(
              color: Colors.grey.shade500,
              fontSize: isSmall ? 11 : 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isSmall) {
    return Row(
      children: [
        Expanded(
          child: _buildButton(
            'HOME',
            Icons.home_rounded,
            Colors.grey.shade600,
            _goHome,
            isSmall,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildButton(
            'SHARE',
            Icons.share_rounded,
            Colors.purple,
            _shareScore,
            isSmall,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _buildButton(
            'PLAY AGAIN',
            Icons.refresh_rounded,
            Colors.cyan,
            _playAgain,
            isSmall,
            isPrimary: true,
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isSmall, {
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isSmall ? 14 : 18,
        ),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(colors: [color, Colors.purple])
              : null,
          color: isPrimary ? null : color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? null : Border.all(color: color.withOpacity(0.4)),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isPrimary ? Colors.white : color, size: isSmall ? 22 : 26),
            SizedBox(height: isSmall ? 4 : 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: GoogleFonts.audiowide(
                  color: isPrimary ? Colors.white : color,
                  fontSize: isSmall ? 10 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticle(int index, Size size) {
    final positions = [
      Offset(size.width * 0.08, size.height * 0.15),
      Offset(size.width * 0.92, size.height * 0.1),
      Offset(size.width * 0.12, size.height * 0.7),
      Offset(size.width * 0.88, size.height * 0.65),
      Offset(size.width * 0.5, size.height * 0.06),
      Offset(size.width * 0.25, size.height * 0.88),
      Offset(size.width * 0.75, size.height * 0.85),
      Offset(size.width * 0.04, size.height * 0.42),
      Offset(size.width * 0.96, size.height * 0.48),
      Offset(size.width * 0.38, size.height * 0.92),
      Offset(size.width * 0.62, size.height * 0.04),
      Offset(size.width * 0.18, size.height * 0.55),
    ];

    final colors = [
      Colors.red.withOpacity(0.2),
      Colors.orange.withOpacity(0.2),
      Colors.amber.withOpacity(0.15),
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
                  color: colors[index % 3].withOpacity(_glowAnimation.value * 0.7),
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
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  _StatItem(this.label, this.value, this.icon, this.color);
}

/// Premium share dialog
class _ShareDialog extends StatelessWidget {
  final String message;
  final int score;

  const _ShareDialog({required this.message, required this.score});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dialogWidth = (size.width * 0.85).clamp(300.0, 420.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: dialogWidth,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A0A2E).withOpacity(0.95),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.purple.withOpacity(0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.share_rounded,
                      color: Colors.purple,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Share Score',
                          style: GoogleFonts.audiowide(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            decorationThickness: 0,
                          ),
                        ),
                        Text(
                          'Show off your score!',
                          style: GoogleFonts.rajdhani(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.none,
                            decorationThickness: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white54, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Score preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'NEON RUNNER',
                      style: GoogleFonts.audiowide(
                        fontSize: 14,
                        color: Colors.cyan,
                        letterSpacing: 2,
                        decoration: TextDecoration.none,
                        decorationThickness: 0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      score.toString(),
                      style: GoogleFonts.audiowide(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                        decorationThickness: 0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Can you beat my score?',
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                        decoration: TextDecoration.none,
                        decorationThickness: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Copy button
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: message));
                  AudioManager().playButton();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Score copied to clipboard!',
                        style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.cyan],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.copy_rounded, color: Colors.white),
                      const SizedBox(width: 12),
                      Text(
                        'COPY TO CLIPBOARD',
                        style: GoogleFonts.audiowide(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                          decorationThickness: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
