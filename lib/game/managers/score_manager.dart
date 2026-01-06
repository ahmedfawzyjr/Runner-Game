import 'dart:async';
import '../../core/game_config.dart';
import '../../core/game_state.dart';

/// Manages scoring, combos, and points
class ScoreManager {
  Timer? _comboTimer;
  double _distanceAccumulator = 0;

  /// Add points for distance traveled
  void addDistancePoints(double dt) {
    final settings = GameConfig.difficulties[GameState().difficulty]!;
    _distanceAccumulator += dt * settings.gameSpeed;
    
    // Add 1 point for every 0.1 seconds of travel
    if (_distanceAccumulator >= 0.1) {
      GameState().addScore(1);
      _distanceAccumulator = 0;
    }
  }

  /// Register a kill and start/reset combo timer
  void registerKill() {
    GameState().registerKill();
    
    // Reset combo timer
    _comboTimer?.cancel();
    _comboTimer = Timer(
      Duration(milliseconds: (GameConfig.comboTimeWindow * 1000).round()),
      () {
        GameState().resetCombo();
      },
    );
  }

  /// Dispose timers
  void dispose() {
    _comboTimer?.cancel();
  }
}
