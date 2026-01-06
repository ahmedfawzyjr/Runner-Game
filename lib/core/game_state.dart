import 'package:shared_preferences/shared_preferences.dart';
import 'game_config.dart';

/// Global game state management
class GameState {
  static final GameState _instance = GameState._internal();
  factory GameState() => _instance;
  GameState._internal();

  // Current game state
  int score = 0;
  int killCount = 0;
  int comboCount = 0;
  int maxCombo = 0;
  double distanceTraveled = 0;
  double timeSurvived = 0;
  Difficulty difficulty = Difficulty.medium;

  // Settings
  bool soundEnabled = true;
  bool musicEnabled = true;
  
  // High scores per difficulty
  Map<Difficulty, int> highScores = {
    Difficulty.easy: 0,
    Difficulty.medium: 0,
    Difficulty.hard: 0,
  };

  // Total stats
  int totalKills = 0;
  int totalRuns = 0;
  double totalDistance = 0;

  /// Reset current game state for new game
  void resetGame() {
    score = 0;
    killCount = 0;
    comboCount = 0;
    maxCombo = 0;
    distanceTraveled = 0;
    timeSurvived = 0;
  }

  /// Add points to score
  void addScore(int points) {
    final multiplier = GameConfig.difficulties[difficulty]!.scoreMultiplier;
    score += (points * multiplier).round();
  }

  /// Register a kill and update combo
  void registerKill() {
    killCount++;
    comboCount++;
    if (comboCount > maxCombo) maxCombo = comboCount;
    
    // Calculate combo bonus
    final comboBonus = (comboCount - 1) * GameConfig.comboBonus;
    addScore(GameConfig.killPoints + comboBonus);
  }

  /// Reset combo (called when combo timer expires)
  void resetCombo() {
    comboCount = 0;
  }

  /// End game and update stats
  Future<bool> endGame() async {
    totalKills += killCount;
    totalRuns++;
    totalDistance += distanceTraveled;

    // Check for high score
    bool isNewHighScore = false;
    if (score > highScores[difficulty]!) {
      highScores[difficulty] = score;
      isNewHighScore = true;
    }

    await saveData();
    return isNewHighScore;
  }

  /// Load saved data from SharedPreferences
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    soundEnabled = prefs.getBool('soundEnabled') ?? true;
    musicEnabled = prefs.getBool('musicEnabled') ?? true;
    
    highScores[Difficulty.easy] = prefs.getInt('highScore_easy') ?? 0;
    highScores[Difficulty.medium] = prefs.getInt('highScore_medium') ?? 0;
    highScores[Difficulty.hard] = prefs.getInt('highScore_hard') ?? 0;
    
    totalKills = prefs.getInt('totalKills') ?? 0;
    totalRuns = prefs.getInt('totalRuns') ?? 0;
    totalDistance = prefs.getDouble('totalDistance') ?? 0;
    
    final diffIndex = prefs.getInt('difficulty') ?? 1;
    difficulty = Difficulty.values[diffIndex];
  }

  /// Save data to SharedPreferences
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('soundEnabled', soundEnabled);
    await prefs.setBool('musicEnabled', musicEnabled);
    
    await prefs.setInt('highScore_easy', highScores[Difficulty.easy]!);
    await prefs.setInt('highScore_medium', highScores[Difficulty.medium]!);
    await prefs.setInt('highScore_hard', highScores[Difficulty.hard]!);
    
    await prefs.setInt('totalKills', totalKills);
    await prefs.setInt('totalRuns', totalRuns);
    await prefs.setDouble('totalDistance', totalDistance);
    
    await prefs.setInt('difficulty', difficulty.index);
  }
}
