import 'package:shared_preferences/shared_preferences.dart';
import 'game_config.dart';
import '../data/leaderboard_entry.dart';

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
  
  // Collectibles
  int coinsCollected = 0;
  int totalCoinsCollected = 0;
  
  // Getter/setter for coins (alias for coinsCollected)
  int get coins => coinsCollected;
  set coins(int value) => coinsCollected = value;
  
  // Power-up states
  bool hasShield = false;
  bool hasMagnet = false;
  bool hasSpeedBoost = false;
  bool hasDoublePoints = false;
  double shieldTimeRemaining = 0;
  double magnetTimeRemaining = 0;
  double speedBoostTimeRemaining = 0;

  // Character settings
  String selectedCharacter = 'green';

  // Settings
  bool soundEnabled = true;
  bool musicEnabled = true;
  int graphicsQuality = 2; // 0=low, 1=medium, 2=high
  
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

  // Leaderboard manager
  final LeaderboardManager leaderboard = LeaderboardManager();

  /// Reset current game state for new game
  void resetGame() {
    score = 0;
    killCount = 0;
    comboCount = 0;
    maxCombo = 0;
    distanceTraveled = 0;
    timeSurvived = 0;
    coinsCollected = 0;
    
    // Reset power-ups
    hasShield = false;
    hasMagnet = false;
    hasSpeedBoost = false;
    shieldTimeRemaining = 0;
    magnetTimeRemaining = 0;
    speedBoostTimeRemaining = 0;
  }
  
  /// Collect a coin
  void collectCoin(int value) {
    coinsCollected += value;
    addScore(value * 10);
  }
  
  /// Activate shield power-up
  void activateShield(double duration) {
    hasShield = true;
    shieldTimeRemaining = duration;
  }
  
  /// Activate magnet power-up
  void activateMagnet(double duration) {
    hasMagnet = true;
    magnetTimeRemaining = duration;
  }
  
  /// Activate speed boost power-up
  void activateSpeedBoost(double duration) {
    hasSpeedBoost = true;
    speedBoostTimeRemaining = duration;
  }
  
  /// Update power-up timers (call each frame)
  void updatePowerUps(double dt) {
    if (hasShield) {
      shieldTimeRemaining -= dt;
      if (shieldTimeRemaining <= 0) hasShield = false;
    }
    if (hasMagnet) {
      magnetTimeRemaining -= dt;
      if (magnetTimeRemaining <= 0) hasMagnet = false;
    }
    if (hasSpeedBoost) {
      speedBoostTimeRemaining -= dt;
      if (speedBoostTimeRemaining <= 0) hasSpeedBoost = false;
    }
  }

  /// Add points to score
  void addScore(int points) {
    final multiplier = GameConfig.difficulties[difficulty]!.scoreMultiplier;
    score += (points * multiplier).round();
  }

  /// Add distance points (called during gameplay)
  void addDistance(double distance) {
    distanceTraveled += distance;
    // Add score for distance (1 point per 10 units)
    addScore((distance / 10).round());
  }

  /// Add time bonus
  void addTimeSurvived(double dt) {
    timeSurvived += dt;
    // Bonus points for surviving (1 point per second)
    addScore(1);
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

    // Create and add leaderboard entry
    final entry = LeaderboardEntry.fromGameState(
      score: score,
      kills: killCount,
      maxCombo: maxCombo,
      distance: distanceTraveled,
      timeSurvived: timeSurvived,
      difficulty: difficulty,
      characterColor: selectedCharacter,
    );
    leaderboard.addEntry(entry);

    await saveData();
    return isNewHighScore;
  }

  /// Get current run summary for game over screen
  Map<String, dynamic> getRunSummary() {
    final settings = GameConfig.difficulties[difficulty]!;
    return {
      'score': score,
      'kills': killCount,
      'maxCombo': maxCombo,
      'distance': distanceTraveled,
      'timeSurvived': timeSurvived,
      'difficulty': difficulty,
      'difficultyName': settings.name,
      'multiplier': settings.scoreMultiplier,
      'isNewHighScore': score > (highScores[difficulty] ?? 0),
      'previousBest': highScores[difficulty] ?? 0,
      'rank': leaderboard.getRank(score, difficulty: difficulty),
    };
  }

  /// Load saved data from SharedPreferences
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    soundEnabled = prefs.getBool('soundEnabled') ?? true;
    musicEnabled = prefs.getBool('musicEnabled') ?? true;
    graphicsQuality = prefs.getInt('graphicsQuality') ?? 2;
    selectedCharacter = prefs.getString('selectedCharacter') ?? 'green';
    
    highScores[Difficulty.easy] = prefs.getInt('highScore_easy') ?? 0;
    highScores[Difficulty.medium] = prefs.getInt('highScore_medium') ?? 0;
    highScores[Difficulty.hard] = prefs.getInt('highScore_hard') ?? 0;
    
    totalKills = prefs.getInt('totalKills') ?? 0;
    totalRuns = prefs.getInt('totalRuns') ?? 0;
    totalDistance = prefs.getDouble('totalDistance') ?? 0;
    
    final diffIndex = prefs.getInt('difficulty') ?? 1;
    difficulty = Difficulty.values[diffIndex];

    // Load leaderboard
    final leaderboardJson = prefs.getString('leaderboard');
    if (leaderboardJson != null) {
      leaderboard.fromJson(leaderboardJson);
    }
  }

  /// Save data to SharedPreferences
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('soundEnabled', soundEnabled);
    await prefs.setBool('musicEnabled', musicEnabled);
    await prefs.setInt('graphicsQuality', graphicsQuality);
    await prefs.setString('selectedCharacter', selectedCharacter);
    
    await prefs.setInt('highScore_easy', highScores[Difficulty.easy]!);
    await prefs.setInt('highScore_medium', highScores[Difficulty.medium]!);
    await prefs.setInt('highScore_hard', highScores[Difficulty.hard]!);
    
    await prefs.setInt('totalKills', totalKills);
    await prefs.setInt('totalRuns', totalRuns);
    await prefs.setDouble('totalDistance', totalDistance);
    
    await prefs.setInt('difficulty', difficulty.index);

    // Save leaderboard
    await prefs.setString('leaderboard', leaderboard.toJson());
  }

  /// Change selected character
  Future<void> setCharacter(String color) async {
    selectedCharacter = color;
    await saveData();
  }

  /// Change difficulty
  Future<void> setDifficulty(Difficulty diff) async {
    difficulty = diff;
    await saveData();
  }
}
