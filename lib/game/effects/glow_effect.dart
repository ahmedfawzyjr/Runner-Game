import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Glow effect component for visual polish
class GlowEffect extends CircleComponent {
  final Color glowColor;
  final double maxRadius;
  final double pulseSpeed;
  double _time = 0;
  
  GlowEffect({
    required Vector2 position,
    this.glowColor = Colors.cyan,
    this.maxRadius = 30,
    this.pulseSpeed = 2.0,
  }) : super(
    position: position,
    radius: maxRadius,
    anchor: Anchor.center,
    paint: Paint()
      ..color = glowColor.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
  );
  
  @override
  void update(double dt) {
    super.update(dt);
    _time += dt * pulseSpeed;
    
    // Pulsing effect
    final pulse = (sin(_time) + 1) / 2; // 0 to 1
    final currentRadius = maxRadius * (0.8 + 0.2 * pulse);
    radius = currentRadius;
    
    // Fade in and out
    final alpha = 0.2 + 0.2 * pulse;
    paint.color = glowColor.withValues(alpha: alpha);
  }
}

/// Neon outline effect for shapes
class NeonOutline extends RectangleComponent {
  final Color neonColor;
  final double glowIntensity;
  
  NeonOutline({
    required Vector2 position,
    required Vector2 size,
    this.neonColor = Colors.cyan,
    this.glowIntensity = 15,
  }) : super(
    position: position,
    size: size,
    anchor: Anchor.center,
    paint: Paint()
      ..color = neonColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowIntensity),
  );
}

/// Collectible sparkle effect
class SparkleEffect extends PositionComponent {
  final Color sparkleColor;
  final int particleCount;
  final double lifetime;
  double _time = 0;
  final List<_Sparkle> _sparkles = [];
  
  SparkleEffect({
    required Vector2 position,
    this.sparkleColor = Colors.yellow,
    this.particleCount = 8,
    this.lifetime = 0.5,
  }) : super(position: position);
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    final random = Random();
    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * pi;
      _sparkles.add(_Sparkle(
        angle: angle,
        speed: 50 + random.nextDouble() * 50,
        size: 2 + random.nextDouble() * 3,
      ));
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    
    if (_time >= lifetime) {
      removeFromParent();
    }
  }
  
  @override
  void render(Canvas canvas) {
    final progress = _time / lifetime;
    
    for (var sparkle in _sparkles) {
      final x = cos(sparkle.angle) * sparkle.speed * progress;
      final y = sin(sparkle.angle) * sparkle.speed * progress;
      final alpha = 1.0 - progress;
      
      final paint = Paint()
        ..color = sparkleColor.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      canvas.drawCircle(
        Offset(x, y),
        sparkle.size * (1 - progress * 0.5),
        paint,
      );
    }
  }
}

class _Sparkle {
  final double angle;
  final double speed;
  final double size;
  
  _Sparkle({
    required this.angle,
    required this.speed,
    required this.size,
  });
}

/// Trail effect for player movement
class TrailEffect extends PositionComponent {
  final Color trailColor;
  final double fadeSpeed;
  final List<Vector2> _positions = [];
  static const int maxPositions = 10;
  double _alpha = 0.8;
  
  TrailEffect({
    this.trailColor = Colors.cyan,
    this.fadeSpeed = 2.0,
  });
  
  void addPosition(Vector2 pos) {
    _positions.add(pos.clone());
    if (_positions.length > maxPositions) {
      _positions.removeAt(0);
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Fade out when not moving
    if (_positions.length < 2) {
      _alpha -= fadeSpeed * dt;
      if (_alpha <= 0) {
        _positions.clear();
        _alpha = 0.8;
      }
    }
  }
  
  @override
  void render(Canvas canvas) {
    if (_positions.length < 2) return;
    
    for (int i = 0; i < _positions.length - 1; i++) {
      final progress = i / _positions.length;
      final alpha = _alpha * progress * 0.5;
      
      final paint = Paint()
        ..color = trailColor.withValues(alpha: alpha)
        ..strokeWidth = 3 * (1 - progress)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      
      canvas.drawLine(
        _positions[i].toOffset(),
        _positions[i + 1].toOffset(),
        paint,
      );
    }
  }
}

/// Speed lines effect for fast movement
class SpeedLines extends PositionComponent {
  final Color lineColor;
  final int lineCount;
  final double speed;
  final List<_SpeedLine> _lines = [];
  
  SpeedLines({
    required Vector2 size,
    this.lineColor = Colors.white,
    this.lineCount = 20,
    this.speed = 500,
  }) : super(size: size);
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    final random = Random();
    for (int i = 0; i < lineCount; i++) {
      _lines.add(_SpeedLine(
        x: random.nextDouble() * size.x,
        y: random.nextDouble() * size.y,
        length: 20 + random.nextDouble() * 40,
        alpha: 0.1 + random.nextDouble() * 0.3,
      ));
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    final random = Random();
    for (var line in _lines) {
      line.x -= speed * dt;
      if (line.x < -line.length) {
        line.x = size.x;
        line.y = random.nextDouble() * size.y;
      }
    }
  }
  
  @override
  void render(Canvas canvas) {
    for (var line in _lines) {
      final paint = Paint()
        ..color = lineColor.withValues(alpha: line.alpha)
        ..strokeWidth = 1;
      
      canvas.drawLine(
        Offset(line.x, line.y),
        Offset(line.x + line.length, line.y),
        paint,
      );
    }
  }
}

class _SpeedLine {
  double x;
  double y;
  double length;
  double alpha;
  
  _SpeedLine({
    required this.x,
    required this.y,
    required this.length,
    required this.alpha,
  });
}
