// ignore_for_file: deprecated_member_use

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
          count: 15,
          lifespan: 0.5,
          generator: (i) => AcceleratedParticle(
            speed: Vector2(
              _random.nextDouble() * 300 - 150,
              _random.nextDouble() * 300 - 150,
            ),
            child: CircleParticle(
              radius: 2,
              paint: Paint()..color = Colors.red.withOpacity(0.8),
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
          count: 6,
          lifespan: 0.3,
          generator: (i) => MovingParticle(
            from: Vector2(0, _random.nextDouble() * 40 - 20),
            to: Vector2(-120, _random.nextDouble() * 40 - 20),
            child: CircleParticle(
              radius: 1.5,
              paint: Paint()..color = Colors.white.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }

  /// Create coin collection effect
  void createCoinEffect(Vector2 position) {
    parent?.add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 12,
          lifespan: 0.6,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, -100),
            speed: Vector2(
              _random.nextDouble() * 150 - 75,
              _random.nextDouble() * -100,
            ),
            child: CircleParticle(
              radius: 2 + _random.nextDouble() * 2,
              paint: Paint()..color = const Color(0xFFFFD700).withOpacity(0.9),
            ),
          ),
        ),
      ),
    );
    
    // Add sparkle
    parent?.add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 8,
          lifespan: 0.4,
          generator: (i) => AcceleratedParticle(
            speed: Vector2(
              _random.nextDouble() * 100 - 50,
              _random.nextDouble() * 100 - 50,
            ),
            child: CircleParticle(
              radius: 1,
              paint: Paint()..color = Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// Create power-up collection effect
  void createPowerUpEffect(Vector2 position, Color color) {
    parent?.add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 25,
          lifespan: 0.8,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 50),
            speed: Vector2(
              _random.nextDouble() * 200 - 100,
              _random.nextDouble() * 200 - 100,
            ),
            child: CircleParticle(
              radius: 3 + _random.nextDouble() * 3,
              paint: Paint()..color = color.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
    
    // Ring effect
    parent?.add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 16,
          lifespan: 0.5,
          generator: (i) {
            final angle = (i / 16) * 3.14159 * 2;
            return AcceleratedParticle(
              speed: Vector2(cos(angle) * 150, sin(angle) * 150),
              child: CircleParticle(
                radius: 2,
                paint: Paint()..color = Colors.white.withOpacity(0.7),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Create jump dust effect
  void createJumpDust(Vector2 position) {
    parent?.add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 8,
          lifespan: 0.4,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 100),
            speed: Vector2(
              _random.nextDouble() * 80 - 40,
              _random.nextDouble() * -30,
            ),
            child: CircleParticle(
              radius: 2,
              paint: Paint()..color = Colors.brown.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  /// Create landing dust effect
  void createLandingDust(Vector2 position) {
    parent?.add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 10,
          lifespan: 0.5,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 50),
            speed: Vector2(
              _random.nextDouble() * 120 - 60,
              _random.nextDouble() * -20 - 10,
            ),
            child: CircleParticle(
              radius: 2 + _random.nextDouble() * 2,
              paint: Paint()..color = Colors.brown.withOpacity(0.4),
            ),
          ),
        ),
      ),
    );
  }
}
