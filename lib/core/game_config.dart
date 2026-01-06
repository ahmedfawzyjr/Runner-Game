/// Game configuration constants for Neon Runner
library;

/// Difficulty levels
enum Difficulty { easy, medium, hard }

/// Game configuration constants
class GameConfig {
  // Difficulty settings
  static const Map<Difficulty, DifficultySettings> difficulties = {
    Difficulty.easy: DifficultySettings(
      name: 'Easy',
      gameSpeed: 1.0,
      enemySpawnInterval: 3.5,
      scoreMultiplier: 1.0,
      enemySpeed: 80,
    ),
    Difficulty.medium: DifficultySettings(
      name: 'Medium',
      gameSpeed: 1.3,
      enemySpawnInterval: 2.5,
      scoreMultiplier: 1.5,
      enemySpeed: 100,
    ),
    Difficulty.hard: DifficultySettings(
      name: 'Hard',
      gameSpeed: 1.6,
      enemySpawnInterval: 1.8,
      scoreMultiplier: 2.0,
      enemySpeed: 130,
    ),
  };

  // Player settings
  static const double playerSize = 80;
  static const double playerJumpForce = 400;
  static const double gravity = 900;
  static const int playerMaxHealth = 3;

  // Combat settings
  static const double attackRange = 60;
  static const double attackCooldown = 0.5;
  static const int killPoints = 100;
  static const int comboBonus = 50;
  static const double comboTimeWindow = 2.0;

  // Animation speeds (in seconds per frame)
  static const double runAnimSpeed = 0.08;
  static const double attackAnimSpeed = 0.06;
  static const double deathAnimSpeed = 0.1;

  // Parallax layer speeds
  static const List<double> parallaxSpeeds = [10, 20, 30, 40, 50, 60];

  // Screen
  static const double groundY = 0.8;
}

/// Settings for each difficulty level
class DifficultySettings {
  final String name;
  final double gameSpeed;
  final double enemySpawnInterval;
  final double scoreMultiplier;
  final double enemySpeed;

  const DifficultySettings({
    required this.name,
    required this.gameSpeed,
    required this.enemySpawnInterval,
    required this.scoreMultiplier,
    required this.enemySpeed,
  });
}
