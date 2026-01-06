import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

/// Camera shake effect
class CameraShake extends Component with HasGameReference<FlameGame> {
  double _shakeDuration = 0;
  double _shakeIntensity = 0;
  final Random _random = Random();
  Vector2 _originalPosition = Vector2.zero();
  bool _isShaking = false;

  /// Trigger camera shake
  void shake({double duration = 0.2, double intensity = 5.0}) {
    _shakeDuration = duration;
    _shakeIntensity = intensity;
    _isShaking = true;
    // Store original position if not already shaking
    if (game.camera.viewfinder.position == Vector2.zero()) {
       _originalPosition = game.camera.viewfinder.position.clone();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isShaking) {
      _shakeDuration -= dt;
      if (_shakeDuration <= 0) {
        _isShaking = false;
        game.camera.viewfinder.position = _originalPosition;
      } else {
        final offset = Vector2(
          (_random.nextDouble() * 2 - 1) * _shakeIntensity,
          (_random.nextDouble() * 2 - 1) * _shakeIntensity,
        );
        game.camera.viewfinder.position = _originalPosition + offset;
      }
    }
  }
}
