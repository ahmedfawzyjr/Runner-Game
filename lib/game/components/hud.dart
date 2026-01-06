import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/game_state.dart';
import '../neon_runner_game.dart';

/// In-game HUD displaying score, combo, and health
class HudComponent extends PositionComponent with HasGameReference<NeonRunnerGame> {
  late TextComponent scoreText;
  late TextComponent comboText;
  late TextComponent killsText;
  
  double comboDisplayTime = 0;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Score display at top center
    scoreText = TextComponent(
      text: '0',
      position: Vector2(game.size.x / 2, 20),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.cyan,
              blurRadius: 10,
            ),
          ],
        ),
      ),
    );
    add(scoreText);
    
    // Combo display
    comboText = TextComponent(
      text: '',
      position: Vector2(game.size.x / 2, 60),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.orange,
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
    add(comboText);
    
    // Kills display at top right
    killsText = TextComponent(
      text: 'Kills: 0',
      position: Vector2(game.size.x - 20, 20),
      anchor: Anchor.topRight,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(killsText);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    final state = GameState();
    
    // Update score
    scoreText.text = state.score.toString();
    
    // Update kills
    killsText.text = 'Kills: ${state.killCount}';
    
    // Handle combo display timeout
    if (comboDisplayTime > 0) {
      comboDisplayTime -= dt;
      if (comboDisplayTime <= 0) {
        comboText.text = '';
      }
    }
  }
  
  /// Show combo text when player gets a kill
  void showComboText(int combo) {
    if (combo > 1) {
      comboText.text = '${combo}x COMBO!';
      comboDisplayTime = 2.0;
    }
  }
}
