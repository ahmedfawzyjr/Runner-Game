// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../audio/audio_manager.dart';
import '../../core/game_config.dart';
import '../../core/game_state.dart';
import '../neon_runner_game.dart';

/// Coin collectible that gives points when collected
class Coin extends PositionComponent
    with HasGameReference<NeonRunnerGame>, CollisionCallbacks {
  bool isCollected = false;
  double floatTime = 0;
  final double baseY;
  final int value;

  Coin({
    required Vector2 position,
    this.value = 50,
  })  : baseY = position.y,
        super(
          position: position,
          size: Vector2.all(32),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw a golden coin
    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = const Color(0xFFB8860B)
      ..style = PaintingStyle.fill;

    // Shadow
    canvas.drawCircle(
      Offset(size.x / 2 + 2, size.y / 2 + 2),
      size.x / 2 - 2,
      shadowPaint,
    );

    // Main coin
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2 - 2,
      paint,
    );

    // Shine effect
    final shinePaint = Paint()
      ..color = const Color(0xFFFFE44D)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.x / 3, size.y / 3),
      4,
      shinePaint,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isCollected) return;

    // Float up and down
    floatTime += dt * 4;
    position.y = baseY + sin(floatTime) * 8;

    // Move left
    final settings = GameConfig.difficulties[GameState().difficulty]!;
    position.x -= settings.gameSpeed * 120 * dt;

    // Remove if off screen
    if (position.x < -50) {
      removeFromParent();
    }
  }

  void collect() {
    if (isCollected) return;
    isCollected = true;

    // Add coins and score
    GameState().coins += value;
    GameState().addScore(value);

    // Play sound
    AudioManager().playCoinPickup();

    // Create particle effect
    game.particleSystem.createCoinEffect(position);

    // Remove
    removeFromParent();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other == game.player && !isCollected) {
      collect();
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}

/// Power-up that gives temporary abilities
class PowerUp extends PositionComponent
    with HasGameReference<NeonRunnerGame>, CollisionCallbacks {
  final PowerUpType type;
  bool isCollected = false;
  double floatTime = 0;
  final double baseY;

  PowerUp({
    required Vector2 position,
    required this.type,
  })  : baseY = position.y,
        super(
          position: position,
          size: Vector2.all(40),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Background circle
    final bgPaint = Paint()
      ..color = _getTypeColor().withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, bgPaint);

    // Border
    final borderPaint = Paint()
      ..color = _getTypeColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(
        Offset(size.x / 2, size.y / 2), size.x / 2 - 2, borderPaint);

    // Icon
    final iconPaint = Paint()..color = _getTypeColor();
    _drawIcon(canvas, iconPaint);
  }

  Color _getTypeColor() {
    switch (type) {
      case PowerUpType.shield:
        return const Color(0xFF00BFFF);
      case PowerUpType.magnet:
        return const Color(0xFFFF1493);
      case PowerUpType.doublePoints:
        return const Color(0xFFFFD700);
    }
  }

  void _drawIcon(Canvas canvas, Paint paint) {
    final center = Offset(size.x / 2, size.y / 2);
    switch (type) {
      case PowerUpType.shield:
        // Draw shield shape
        final path = Path()
          ..moveTo(center.dx, center.dy - 10)
          ..lineTo(center.dx + 10, center.dy - 5)
          ..lineTo(center.dx + 10, center.dy + 5)
          ..lineTo(center.dx, center.dy + 12)
          ..lineTo(center.dx - 10, center.dy + 5)
          ..lineTo(center.dx - 10, center.dy - 5)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case PowerUpType.magnet:
        // Draw U shape for magnet
        final arcPaint = Paint()
          ..color = _getTypeColor()
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke;
        canvas.drawArc(
          Rect.fromCenter(center: center, width: 16, height: 16),
          0,
          3.14,
          false,
          arcPaint,
        );
        break;
      case PowerUpType.doublePoints:
        // Draw x2 text
        final textPainter = TextPainter(
          text: TextSpan(
            text: 'x2',
            style: TextStyle(
              color: _getTypeColor(),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, Offset(center.dx - 10, center.dy - 8));
        break;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isCollected) return;

    // Float up and down
    floatTime += dt * 3;
    position.y = baseY + sin(floatTime) * 10;

    // Rotate
    angle += dt * 2;

    // Move left
    final settings = GameConfig.difficulties[GameState().difficulty]!;
    position.x -= settings.gameSpeed * 100 * dt;

    // Remove if off screen
    if (position.x < -50) {
      removeFromParent();
    }
  }

  void collect() {
    if (isCollected) return;
    isCollected = true;

    // Apply power-up
    final state = GameState();
    switch (type) {
      case PowerUpType.shield:
        state.hasShield = true;
        game.player.isInvincible = true;
        Future.delayed(const Duration(seconds: 5), () {
          state.hasShield = false;
          if (game.player.isMounted) {
            game.player.isInvincible = false;
          }
        });
        break;
      case PowerUpType.magnet:
        state.hasMagnet = true;
        Future.delayed(const Duration(seconds: 8), () {
          state.hasMagnet = false;
        });
        break;
      case PowerUpType.doublePoints:
        state.hasDoublePoints = true;
        Future.delayed(const Duration(seconds: 10), () {
          state.hasDoublePoints = false;
        });
        break;
    }

    // Play sound
    AudioManager().playMagic();

    // Create effect
    game.particleSystem.createPowerUpEffect(position, _getTypeColor());

    // Remove
    removeFromParent();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other == game.player && !isCollected) {
      collect();
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}

enum PowerUpType {
  shield,
  magnet,
  doublePoints,
}

/// Factory for spawning collectibles
class CollectibleFactory {
  static final Random _random = Random();

  static Coin spawnCoin(Vector2 position) {
    return Coin(position: position);
  }

  static List<Coin> spawnCoinLine(Vector2 startPosition, int count) {
    final coins = <Coin>[];
    for (int i = 0; i < count; i++) {
      coins.add(Coin(
        position: startPosition + Vector2(i * 40.0, 0),
      ));
    }
    return coins;
  }

  static PowerUp spawnRandomPowerUp(Vector2 position) {
    const types = PowerUpType.values;
    return PowerUp(
      position: position,
      type: types[_random.nextInt(types.length)],
    );
  }
}
