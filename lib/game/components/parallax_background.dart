import 'package:flutter/painting.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';

import '../../core/game_config.dart';
import '../../core/game_state.dart';
import '../neon_runner_game.dart';

/// Parallax scrolling background component
class ParallaxBackgroundComponent extends ParallaxComponent<NeonRunnerGame> {
  
  @override
  Future<void> onLoad() async {
    final settings = GameConfig.difficulties[GameState().difficulty]!;
    
    parallax = await game.loadParallax(
      [
        ParallaxImageData('plx-1.png'),
        ParallaxImageData('plx-2.png'),
        ParallaxImageData('plx-3.png'),
        ParallaxImageData('plx-4.png'),
        ParallaxImageData('plx-5.png'),
        ParallaxImageData('plx-6.png'),
      ],
      baseVelocity: Vector2(20 * settings.gameSpeed, 0),
      velocityMultiplierDelta: Vector2(1.5, 0),
      repeat: ImageRepeat.repeatX,
    );
    
    await super.onLoad();
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Adjust speed based on difficulty
    final settings = GameConfig.difficulties[GameState().difficulty]!;
    parallax?.baseVelocity = Vector2(20 * settings.gameSpeed, 0);
  }
}
