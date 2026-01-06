import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

/// Particle system for visual effects
class ParticleSystem extends Component {
  final Random _random = Random();

  /// Create explosion effect at position
  void createExplosion(Vector2 position) {
    parent?.add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 20,
          lifespan: 0.8,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 200),
            speed: Vector2(
              _random.nextDouble() * 200 - 100,
              _random.nextDouble() * 200 - 200,
            ),
            child: CircleParticle(
              radius: 2 + _random.nextDouble() * 3,
              paint: Paint()..color = Colors.orange.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
    
    // Add some smoke
    parent?.add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 10,
          lifespan: 1.2,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, -50),
            speed: Vector2(
              _random.nextDouble() * 100 - 50,
              _random.nextDouble() * -50,
            ),
            child: CircleParticle(
              radius: 3 + _random.nextDouble() * 4,
              paint: Paint()..color = Colors.grey.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  /// Create hit effect at position
  void createHitEffect(Vector2 position) {
    parent?.add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 10,
          lifespan: 0.5,
          generator: (i) => AcceleratedParticle(
            speed: Vector2(
              _random.nextDouble() * 300 - 150,
              _random.nextDouble() * 300 - 150,
            ),
            child: CircleParticle(
              radius: 2,
              paint: Paint()..color = Colors.cyan,
            ),
          ),
        ),
      ),
    );
  }
  
  /// Create speed lines effect
  void createSpeedLines(Vector2 position) {
    parent?.add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 5,
          lifespan: 0.3,
          generator: (i) => MovingParticle(
            from: Vector2(0, _random.nextDouble() * 40 - 20),
            to: Vector2(-100, _random.nextDouble() * 40 - 20),
            child: CircleParticle(
              radius: 1,
              paint: Paint()..color = Colors.white.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }
}
