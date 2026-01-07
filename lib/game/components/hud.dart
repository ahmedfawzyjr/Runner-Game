// ignore_for_file: deprecated_member_use

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/game_config.dart';
import '../../core/game_state.dart';
import '../neon_runner_game.dart';

/// Enhanced HUD with health hearts, coins, and power-up indicators
class HudComponent extends PositionComponent
    with HasGameReference<NeonRunnerGame> {
  late TextComponent scoreText;
  late TextComponent comboText;
  late TextComponent killsText;
  late TextComponent coinsText;

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
          fontSize: 36,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.cyan,
              blurRadius: 15,
            ),
          ],
        ),
      ),
    );
    add(scoreText);

    // Combo display
    comboText = TextComponent(
      text: '',
      position: Vector2(game.size.x / 2, 65),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.orange,
              blurRadius: 10,
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
          fontSize: 18,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.redAccent,
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
    add(killsText);

    // Coins display below kills
    coinsText = TextComponent(
      text: '🪙 0',
      position: Vector2(game.size.x - 20, 45),
      anchor: Anchor.topRight,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFD700),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(coinsText);

    // Add health hearts display
    add(HealthDisplay());

    // Add power-up indicators
    add(PowerUpIndicators());
  }

  @override
  void update(double dt) {
    super.update(dt);

    final state = GameState();

    // Update score with multiplier indicator
    if (state.hasDoublePoints) {
      scoreText.text = '${state.score} (x2)';
    } else {
      scoreText.text = state.score.toString();
    }

    // Update kills
    killsText.text = 'Kills: ${state.killCount}';

    // Update coins
    coinsText.text = '🪙 ${state.coins}';

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

/// Health display showing hearts
class HealthDisplay extends PositionComponent
    with HasGameReference<NeonRunnerGame> {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = Vector2(20, 20);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final health = game.player.health;
    const maxHealth = GameConfig.playerMaxHealth;
    final hasShield = GameState().hasShield;

    for (int i = 0; i < maxHealth; i++) {
      final heartX = i * 30.0;
      final isFilled = i < health;

      // Draw heart
      final paint = Paint()
        ..color = isFilled
            ? (hasShield ? Colors.cyan : Colors.red)
            : Colors.grey.withOpacity(0.4)
        ..style = PaintingStyle.fill;

      // Simple heart shape using circles
      canvas.drawCircle(Offset(heartX + 6, 8), 6, paint);
      canvas.drawCircle(Offset(heartX + 14, 8), 6, paint);

      // Triangle bottom
      final path = Path()
        ..moveTo(heartX, 10)
        ..lineTo(heartX + 10, 22)
        ..lineTo(heartX + 20, 10)
        ..close();
      canvas.drawPath(path, paint);

      // Glow effect for shield
      if (hasShield && isFilled) {
        final glowPaint = Paint()
          ..color = Colors.cyan.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawCircle(Offset(heartX + 10, 12), 12, glowPaint);
      }
    }
  }
}

/// Power-up indicators showing active power-ups
class PowerUpIndicators extends PositionComponent
    with HasGameReference<NeonRunnerGame> {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = Vector2(20, 55);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final state = GameState();
    double xOffset = 0;

    if (state.hasShield) {
      _drawIndicator(canvas, xOffset, Colors.cyan, '🛡️');
      xOffset += 35;
    }

    if (state.hasMagnet) {
      _drawIndicator(canvas, xOffset, Colors.pink, '🧲');
      xOffset += 35;
    }

    if (state.hasDoublePoints) {
      _drawIndicator(canvas, xOffset, Colors.amber, 'x2');
      xOffset += 35;
    }
  }

  void _drawIndicator(Canvas canvas, double x, Color color, String text) {
    // Background circle
    final bgPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x + 12, 12), 14, bgPaint);

    // Border
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(x + 12, 12), 13, borderPaint);

    // Text
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(x + 12 - textPainter.width / 2, 6));
  }
}
