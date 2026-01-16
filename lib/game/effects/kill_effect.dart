import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../neon_runner_game.dart';

/// Visual effect when an enemy is killed
class KillEffect extends PositionComponent
    with HasGameReference<NeonRunnerGame> {
  final int score;
  final int comboCount;

  KillEffect({
    required Vector2 position,
    required this.score,
    this.comboCount = 0,
  }) : super(position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add score popup text
    add(ScorePopup(score: score, comboCount: comboCount));

    // Add particle burst
    _createParticleBurst();

    // Remove after animation completes
    add(RemoveEffect(delay: 1.5));
  }

  void _createParticleBurst() {
    final random = Random();
    final colors = [
      Colors.yellow,
      Colors.orange,
      Colors.red,
      Colors.cyan,
    ];

    // Create 8-12 particles
    for (int i = 0; i < 8 + random.nextInt(5); i++) {
      final angle = (i / 12) * 2 * pi + random.nextDouble() * 0.3;
      final speed = 100 + random.nextDouble() * 100;
      final color = colors[random.nextInt(colors.length)];

      add(KillParticle(
        angle: angle,
        speed: speed,
        color: color,
        size: 4 + random.nextDouble() * 4,
      ));
    }
  }
}

/// Floating score popup text with enhanced neon design
class ScorePopup extends PositionComponent {
  final int score;
  final int comboCount;
  double _lifetime = 0;
  double _glowPulse = 0;

  ScorePopup({
    required this.score,
    this.comboCount = 0,
  }) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Float up animation
    add(MoveEffect.by(
      Vector2(0, -80),
      EffectController(duration: 1.2, curve: Curves.easeOutCubic),
    ));

    // Scale pop effect - bounce in
    add(SequenceEffect([
      ScaleEffect.to(
        Vector2.all(1.4),
        EffectController(duration: 0.1, curve: Curves.easeOut),
      ),
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(duration: 0.15, curve: Curves.elasticOut),
      ),
    ]));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifetime += dt;
    _glowPulse += dt * 8; // Pulse animation speed
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Calculate fade out
    const fadeStart = 0.8;
    final alpha = _lifetime < fadeStart
        ? 1.0
        : 1.0 - ((_lifetime - fadeStart) / 0.5).clamp(0.0, 1.0);

    if (alpha <= 0) return;

    // Get style based on combo
    final style = _getComboStyle();

    // Draw glow background circle
    _drawGlowBackground(canvas, style, alpha);

    // Draw score text with neon effect
    _drawScoreText(canvas, style, alpha);

    // Draw combo indicator
    if (comboCount >= 2) {
      _drawComboIndicator(canvas, style, alpha);
    }

    // Draw icon/emoji
    _drawIcon(canvas, style, alpha);
  }

  _ComboStyle _getComboStyle() {
    if (comboCount >= 10) {
      return _ComboStyle(
        primaryColor: const Color(0xFFFF00FF), // Magenta
        secondaryColor: const Color(0xFF00FFFF), // Cyan
        glowColor: const Color(0xFFFF00FF),
        fontSize: 36,
        icon: '💀',
        label: 'LEGENDARY!',
      );
    } else if (comboCount >= 7) {
      return _ComboStyle(
        primaryColor: const Color(0xFFFFD700), // Gold
        secondaryColor: const Color(0xFFFF6B00), // Orange
        glowColor: const Color(0xFFFFD700),
        fontSize: 32,
        icon: '🔥',
        label: 'ON FIRE!',
      );
    } else if (comboCount >= 5) {
      return _ComboStyle(
        primaryColor: const Color(0xFFAA00FF), // Purple
        secondaryColor: const Color(0xFFFF0080), // Pink
        glowColor: const Color(0xFFAA00FF),
        fontSize: 30,
        icon: '⚡',
        label: 'ULTRA!',
      );
    } else if (comboCount >= 3) {
      return _ComboStyle(
        primaryColor: const Color(0xFFFF6B00), // Orange
        secondaryColor: const Color(0xFFFFD700), // Yellow
        glowColor: const Color(0xFFFF6B00),
        fontSize: 26,
        icon: '💥',
        label: 'COMBO!',
      );
    } else if (comboCount >= 2) {
      return _ComboStyle(
        primaryColor: const Color(0xFFFFEB3B), // Yellow
        secondaryColor: const Color(0xFFFF9800), // Orange
        glowColor: const Color(0xFFFFEB3B),
        fontSize: 24,
        icon: '✨',
        label: '${comboCount}x',
      );
    } else {
      return _ComboStyle(
        primaryColor: const Color(0xFF00E5FF), // Cyan
        secondaryColor: const Color(0xFF00BCD4), // Teal
        glowColor: const Color(0xFF00E5FF),
        fontSize: 22,
        icon: '💫',
        label: '',
      );
    }
  }

  void _drawGlowBackground(Canvas canvas, _ComboStyle style, double alpha) {
    final pulseSize = 1.0 + sin(_glowPulse) * 0.1;
    final baseRadius = 25.0 + (comboCount * 2).clamp(0, 20);
    final radius = baseRadius * pulseSize;

    // Outer glow
    final glowPaint = Paint()
      ..color = style.glowColor.withValues(alpha: 0.3 * alpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(Offset.zero, radius + 10, glowPaint);

    // Inner glow
    final innerGlowPaint = Paint()
      ..color = style.glowColor.withValues(alpha: 0.5 * alpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset.zero, radius, innerGlowPaint);

    // Core circle
    final corePaint = Paint()
      ..color = style.primaryColor.withValues(alpha: 0.2 * alpha);
    canvas.drawCircle(Offset.zero, radius * 0.8, corePaint);
  }

  void _drawScoreText(Canvas canvas, _ComboStyle style, double alpha) {
    final scoreText = '+$score';

    // Glow text (drawn behind)
    final glowPainter = TextPainter(
      text: TextSpan(
        text: scoreText,
        style: TextStyle(
          color: style.glowColor.withValues(alpha: 0.8 * alpha),
          fontSize: style.fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Draw glow layers
    for (var i = 3; i > 0; i--) {
      final blurPaint = Paint()
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, i * 2.0)
        ..colorFilter = ColorFilter.mode(
          style.glowColor.withValues(alpha: 0.4 * alpha),
          BlendMode.srcIn,
        );
      canvas.saveLayer(null, blurPaint);
      glowPainter.paint(
        canvas,
        Offset(-glowPainter.width / 2, -glowPainter.height / 2 - 5),
      );
      canvas.restore();
    }

    // Main text with gradient shader
    final textPainter = TextPainter(
      text: TextSpan(
        text: scoreText,
        style: TextStyle(
          fontSize: style.fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          foreground: Paint()
            ..shader = LinearGradient(
              colors: [style.primaryColor, style.secondaryColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(Rect.fromLTWH(0, 0, 100, style.fontSize)),
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.8 * alpha),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
            Shadow(
              color: style.glowColor.withValues(alpha: 0.5 * alpha),
              offset: const Offset(0, 0),
              blurRadius: 10,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2 - 5),
    );
  }

  void _drawComboIndicator(Canvas canvas, _ComboStyle style, double alpha) {
    final labelPainter = TextPainter(
      text: TextSpan(
        text: style.label,
        style: TextStyle(
          color: style.secondaryColor.withValues(alpha: alpha),
          fontSize: 12 + (comboCount * 0.5).clamp(0, 6),
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          letterSpacing: 1.5,
          shadows: [
            Shadow(
              color: style.glowColor.withValues(alpha: 0.8 * alpha),
              blurRadius: 6,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    labelPainter.paint(
      canvas,
      Offset(-labelPainter.width / 2, 18),
    );
  }

  void _drawIcon(Canvas canvas, _ComboStyle style, double alpha) {
    // Animated bounce for icon
    final bounce = sin(_glowPulse * 1.5) * 3;

    final iconPainter = TextPainter(
      text: TextSpan(
        text: style.icon,
        style: TextStyle(
          fontSize: 16 + (comboCount * 0.5).clamp(0, 8),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    iconPainter.paint(
      canvas,
      Offset(-iconPainter.width / 2, -45 + bounce),
    );
  }
}

class _ComboStyle {
  final Color primaryColor;
  final Color secondaryColor;
  final Color glowColor;
  final double fontSize;
  final String icon;
  final String label;

  _ComboStyle({
    required this.primaryColor,
    required this.secondaryColor,
    required this.glowColor,
    required this.fontSize,
    required this.icon,
    required this.label,
  });
}

/// Individual kill particle
class KillParticle extends CircleComponent {
  // ignore: annotate_overrides
  final double angle;
  final double speed;
  double velocityX;
  double velocityY;
  double lifetime = 0;
  static const double maxLifetime = 0.8;

  KillParticle({
    required this.angle,
    required this.speed,
    required Color color,
    required double size,
  })  : velocityX = cos(angle) * speed,
        velocityY = sin(angle) * speed,
        super(
          radius: size / 2,
          paint: Paint()..color = color,
        );

  @override
  void update(double dt) {
    super.update(dt);

    lifetime += dt;

    // Move particle
    position.x += velocityX * dt;
    position.y += velocityY * dt;

    // Apply gravity
    velocityY += 300 * dt;

    // Fade out
    final opacity = 1.0 - (lifetime / maxLifetime);
    paint.color = paint.color.withValues(alpha: opacity.clamp(0, 1));

    // Shrink
    final scale = 1.0 - (lifetime / maxLifetime) * 0.5;
    this.scale = Vector2.all(scale.clamp(0.1, 1));

    // Remove when expired
    if (lifetime >= maxLifetime) {
      removeFromParent();
    }
  }
}

/// Screen flash effect on big kills
class ScreenFlash extends RectangleComponent
    with HasGameReference<NeonRunnerGame> {
  final Color flashColor;
  final double duration;

  ScreenFlash({
    this.flashColor = Colors.white,
    this.duration = 0.2,
  }) : super(
          paint: Paint()..color = flashColor.withValues(alpha: 0.4),
          priority: 1000,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = game.size;

    add(OpacityEffect.fadeOut(
      EffectController(duration: duration),
      onComplete: removeFromParent,
    ));
  }
}
