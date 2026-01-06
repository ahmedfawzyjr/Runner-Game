import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio/audio_manager.dart';
import '../core/game_config.dart';
import '../core/game_state.dart';
import 'home_screen.dart';
import 'game_screen.dart';

/// Animated game over screen with score breakdown
class GameOverScreen extends StatefulWidget {
  const GameOverScreen({super.key});

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _countController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _countAnimation;

  @override
  void initState() {
    super.initState();

    // Slide animation
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Count up animation for score
    _countController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _countAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _countController, curve: Curves.easeOutCubic),
    );

    _slideController.forward();
    _countController.forward();

    // Play game over music
    AudioManager().playGameOverMusic();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _countController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final state = GameState();
    final isNewHighScore =
        state.score >= state.highScores[state.difficulty]!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D0D1A),
              Color(0xFF2A0A1E),
              Color(0xFF0D0D1A),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Game Over title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.red, Colors.orange],
                    ).createShader(bounds),
                    child: Text(
                      'GAME OVER',
                      style: GoogleFonts.orbitron(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 6,
                      ),
                    ),
                  ),
                  if (isNewHighScore) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.amber, Colors.orange],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '🏆 NEW HIGH SCORE!',
                        style: GoogleFonts.orbitron(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 50),
                  // Score breakdown
                  Container(
                    width: 300,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.shade800,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Animated score
                        AnimatedBuilder(
                          animation: _countAnimation,
                          builder: (context, child) {
                            final displayScore =
                                (state.score * _countAnimation.value).round();
                            return Text(
                              displayScore.toString(),
                              style: GoogleFonts.orbitron(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: Colors.cyan,
                                shadows: [
                                  Shadow(
                                    color: Colors.cyan.withOpacity(0.5),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        Text(
                          'SCORE',
                          style: GoogleFonts.rajdhani(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Stats breakdown
                        _buildStatRow(
                          'Kills',
                          state.killCount.toString(),
                          Icons.dangerous,
                          Colors.red,
                        ),
                        _buildStatRow(
                          'Max Combo',
                          '${state.maxCombo}x',
                          Icons.flash_on,
                          Colors.amber,
                        ),
                        _buildStatRow(
                          'Distance',
                          '${(state.distanceTraveled / 100).toStringAsFixed(0)} m',
                          Icons.straighten,
                          Colors.green,
                        ),
                        _buildStatRow(
                          'Time',
                          '${state.timeSurvived.toStringAsFixed(1)} s',
                          Icons.timer,
                          Colors.purple,
                        ),
                        const Divider(color: Colors.grey, height: 30),
                        _buildStatRow(
                          'Difficulty',
                          GameConfig.difficulties[state.difficulty]!.name,
                          Icons.speed,
                          _getDifficultyColor(),
                        ),
                        _buildStatRow(
                          'Best Score',
                          state.highScores[state.difficulty].toString(),
                          Icons.emoji_events,
                          Colors.amber,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildButton(
                        'HOME',
                        Icons.home,
                        _goHome,
                        Colors.grey.shade700,
                      ),
                      const SizedBox(width: 20),
                      _buildButton(
                        'PLAY AGAIN',
                        Icons.refresh,
                        _playAgain,
                        Colors.cyan,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.rajdhani(
                color: Colors.grey.shade400,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    String label,
    IconData icon,
    VoidCallback onTap,
    Color color,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 15,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (GameState().difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
    }
  }
}
