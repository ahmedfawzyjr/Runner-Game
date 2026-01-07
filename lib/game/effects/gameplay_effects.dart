// ignore_for_file: deprecated_member_use

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../neon_runner_game.dart';

/// Tutorial overlay showing control hints at game start
class ControlsTutorial extends PositionComponent
    with HasGameReference<NeonRunnerGame> {
  double displayTime = 0;
  static const double totalDisplayTime = 5.0;
  bool isHiding = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = game.size;
  }

  @override
  void update(double dt) {
    super.update(dt);

    displayTime += dt;

    // Start hiding after display time
    if (displayTime >= totalDisplayTime && !isHiding) {
      isHiding = true;
      // Remove after fade animation completes (handled in render)
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (isMounted) {
          removeFromParent();
        }
      });
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (isHiding) return;

    // Semi-transparent background
    final bgPaint = Paint()..color = Colors.black.withOpacity(0.3);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      bgPaint,
    );

    // Calculate fade based on time
    final fadeIn = (displayTime / 0.5).clamp(0.0, 1.0);
    final fadeOut =
        displayTime > 4.0 ? 1.0 - ((displayTime - 4.0) / 1.0).clamp(0.0, 1.0) : 1.0;
    final alpha = fadeIn * fadeOut;

    // Left side - Jump
    _drawControlHint(
      canvas,
      Offset(size.x * 0.25, size.y * 0.5),
      '👆 TAP',
      'JUMP',
      Colors.cyan,
      alpha,
    );

    // Right side - Attack
    _drawControlHint(
      canvas,
      Offset(size.x * 0.75, size.y * 0.5),
      '👆 TAP',
      'ATTACK',
      Colors.red,
      alpha,
    );

    // Bottom center - Swipe hints
    _drawSwipeHint(
      canvas,
      Offset(size.x * 0.5, size.y * 0.75),
      alpha,
    );
  }

  void _drawControlHint(
    Canvas canvas,
    Offset position,
    String action,
    String label,
    Color color,
    double alpha,
  ) {
    // Circle background
    final bgPaint = Paint()
      ..color = color.withOpacity(0.2 * alpha)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 60, bgPaint);

    // Border
    final borderPaint = Paint()
      ..color = color.withOpacity(0.8 * alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(position, 60, borderPaint);

    // Action text
    final actionPainter = TextPainter(
      text: TextSpan(
        text: action,
        style: TextStyle(
          color: Colors.white.withOpacity(alpha),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    actionPainter.paint(
      canvas,
      Offset(position.dx - actionPainter.width / 2, position.dy - 20),
    );

    // Label text
    final labelPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color.withOpacity(alpha),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    labelPainter.paint(
      canvas,
      Offset(position.dx - labelPainter.width / 2, position.dy + 10),
    );
  }

  void _drawSwipeHint(Canvas canvas, Offset position, double alpha) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '⬆️ SWIPE UP = JUMP   ⬇️ SWIPE DOWN = SLIDE',
        style: TextStyle(
          color: Colors.white.withOpacity(alpha * 0.8),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(position.dx - textPainter.width / 2, position.dy),
    );
  }
}

/// Combo meter that fills up with kills
class ComboMeter extends PositionComponent with HasGameReference<NeonRunnerGame> {
  double comboTimer = 0;
  int currentCombo = 0;
  static const double comboWindow = 2.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = Vector2(game.size.x / 2, 100);
    size = Vector2(200, 10);
    anchor = Anchor.center;
  }

  void registerKill() {
    currentCombo++;
    comboTimer = comboWindow;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (comboTimer > 0) {
      comboTimer -= dt;
      if (comboTimer <= 0) {
        currentCombo = 0;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (currentCombo < 2) return;

    // Background bar
    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(5),
      ),
      bgPaint,
    );

    // Fill bar based on timer
    final fillPercent = comboTimer / comboWindow;
    final fillColor = currentCombo >= 5
        ? Colors.purple
        : currentCombo >= 3
            ? Colors.orange
            : Colors.yellow;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x * fillPercent, size.y),
        const Radius.circular(5),
      ),
      fillPaint,
    );

    // Glow
    final glowPaint = Paint()
      ..color = fillColor.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, -2, size.x * fillPercent, size.y + 4),
        const Radius.circular(5),
      ),
      glowPaint,
    );
  }
}

/// Speed lines effect for fast gameplay
class SpeedLinesOverlay extends PositionComponent
    with HasGameReference<NeonRunnerGame> {
  final List<SpeedLine> lines = [];
  double spawnTimer = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = game.size;
    priority = -1;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Spawn new lines
    spawnTimer += dt;
    if (spawnTimer > 0.05) {
      spawnTimer = 0;
      lines.add(SpeedLine(
        y: game.size.y * (0.3 + 0.4 * (lines.length % 10) / 10),
        speed: 800 + (lines.length % 5) * 100,
        length: 50 + (lines.length % 3) * 30,
      ));
    }

    // Update lines
    for (final line in lines) {
      line.x -= line.speed * dt;
    }

    // Remove off-screen lines
    lines.removeWhere((line) => line.x + line.length < 0);

    // Limit line count
    if (lines.length > 20) {
      lines.removeAt(0);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    for (final line in lines) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(line.x, line.y),
        Offset(line.x + line.length, line.y),
        paint,
      );
    }
  }
}

class SpeedLine {
  double x;
  double y;
  double speed;
  double length;

  SpeedLine({
    required this.y,
    required this.speed,
    required this.length,
  }) : x = 1000; // Start off screen right
}
