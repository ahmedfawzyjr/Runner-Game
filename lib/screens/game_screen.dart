import 'package:flutter/material.dart';
import 'package:flame/game.dart';

import '../game/neon_runner_game.dart';
import 'game_over_screen.dart';
import 'home_screen.dart';

/// Game screen that hosts the Flame game
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late NeonRunnerGame game;

  @override
  void initState() {
    super.initState();
    game = NeonRunnerGame(
      onGameOver: _handleGameOver,
      onPause: _handlePause,
    );
  }

  void _handleGameOver() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const GameOverScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _handlePause() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0A2E),
        title: const Text(
          'PAUSED',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              game.resume();
            },
            child: const Text('Resume', style: TextStyle(color: Colors.cyan)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            child: const Text('Quit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Game
          GameWidget(game: game),
          // Pause button
          Positioned(
            top: 20,
            left: 20,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(
                  Icons.pause_circle_filled,
                  color: Colors.white54,
                  size: 40,
                ),
                onPressed: () => game.pause(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
