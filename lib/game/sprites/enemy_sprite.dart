// ignore_for_file: prefer_const_declarations, avoid_print

import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import '../../core/asset_paths.dart';

/// Enemy types available in the platform pack
enum EnemyType {
  slimeNormal,
  slimeFire,
  slimeSpike,
  slimeBlock,
  bee,
  fly,
  frog,
  snail,
  ladybug,
  mouse,
  wormNormal,
  wormRing,
  saw,
}

/// Enemy animation states
enum EnemyState {
  idle,
  moving,
  attacking,
}

/// A platform enemy sprite with animations
class EnemySprite extends SpriteAnimationGroupComponent<EnemyState> {
  final EnemyType enemyType;
  final double stepTime;
  
  EnemySprite({
    required this.enemyType,
    this.stepTime = 0.15,
    super.position,
    super.size,
    super.anchor = Anchor.bottomCenter,
  });
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Load animations based on enemy type
    animations = await _loadEnemyAnimations();
    current = EnemyState.idle;
  }
  
  Future<Map<EnemyState, SpriteAnimation>> _loadEnemyAnimations() async {
    switch (enemyType) {
      case EnemyType.slimeNormal:
        return {
          EnemyState.idle: await _loadAnimation('slime_normal', ['rest']),
          EnemyState.moving: await _loadAnimation('slime_normal', ['walk_a', 'walk_b']),
          EnemyState.attacking: await _loadAnimation('slime_normal', ['flat']),
        };
      case EnemyType.slimeFire:
        return {
          EnemyState.idle: await _loadAnimation('slime_fire', ['rest']),
          EnemyState.moving: await _loadAnimation('slime_fire', ['walk_a', 'walk_b']),
          EnemyState.attacking: await _loadAnimation('slime_fire', ['flat']),
        };
      case EnemyType.slimeSpike:
        return {
          EnemyState.idle: await _loadAnimation('slime_spike', ['rest']),
          EnemyState.moving: await _loadAnimation('slime_spike', ['walk_a', 'walk_b']),
          EnemyState.attacking: await _loadAnimation('slime_spike', ['flat']),
        };
      case EnemyType.slimeBlock:
        return {
          EnemyState.idle: await _loadAnimation('slime_block', ['rest']),
          EnemyState.moving: await _loadAnimation('slime_block', ['walk_a', 'walk_b']),
          EnemyState.attacking: await _loadAnimation('slime_block', ['jump']),
        };
      case EnemyType.bee:
        return {
          EnemyState.idle: await _loadAnimation('bee', ['rest']),
          EnemyState.moving: await _loadAnimation('bee', ['a', 'b']),
          EnemyState.attacking: await _loadAnimation('bee', ['a', 'b']),
        };
      case EnemyType.fly:
        return {
          EnemyState.idle: await _loadAnimation('fly', ['rest']),
          EnemyState.moving: await _loadAnimation('fly', ['a', 'b']),
          EnemyState.attacking: await _loadAnimation('fly', ['a', 'b']),
        };
      case EnemyType.frog:
        return {
          EnemyState.idle: await _loadAnimation('frog', ['rest', 'idle']),
          EnemyState.moving: await _loadAnimation('frog', ['idle', 'jump']),
          EnemyState.attacking: await _loadAnimation('frog', ['jump']),
        };
      case EnemyType.snail:
        return {
          EnemyState.idle: await _loadAnimation('snail', ['rest']),
          EnemyState.moving: await _loadAnimation('snail', ['walk_a', 'walk_b']),
          EnemyState.attacking: await _loadAnimation('snail', ['shell']),
        };
      case EnemyType.ladybug:
        return {
          EnemyState.idle: await _loadAnimation('ladybug', ['rest']),
          EnemyState.moving: await _loadAnimation('ladybug', ['walk_a', 'walk_b']),
          EnemyState.attacking: await _loadAnimation('ladybug', ['fly']),
        };
      case EnemyType.mouse:
        return {
          EnemyState.idle: await _loadAnimation('mouse', ['rest']),
          EnemyState.moving: await _loadAnimation('mouse', ['walk_a', 'walk_b']),
          EnemyState.attacking: await _loadAnimation('mouse', ['walk_a', 'walk_b']),
        };
      case EnemyType.wormNormal:
        return {
          EnemyState.idle: await _loadAnimation('worm_normal', ['rest']),
          EnemyState.moving: await _loadAnimation('worm_normal', ['move_a', 'move_b']),
          EnemyState.attacking: await _loadAnimation('worm_normal', ['move_a', 'move_b']),
        };
      case EnemyType.wormRing:
        return {
          EnemyState.idle: await _loadAnimation('worm_ring', ['rest']),
          EnemyState.moving: await _loadAnimation('worm_ring', ['move_a', 'move_b']),
          EnemyState.attacking: await _loadAnimation('worm_ring', ['move_a', 'move_b']),
        };
      case EnemyType.saw:
        return {
          EnemyState.idle: await _loadAnimation('saw', ['rest']),
          EnemyState.moving: await _loadAnimation('saw', ['a', 'b']),
          EnemyState.attacking: await _loadAnimation('saw', ['a', 'b']),
        };
    }
  }
  
  Future<SpriteAnimation> _loadAnimation(String enemyName, List<String> states) async {
    final sprites = <Sprite>[];
    
    for (final state in states) {
      final path = AssetPaths.getEnemySprite(enemyName, state);
      try {
        final sprite = await _loadSprite(path);
        sprites.add(sprite);
      } catch (e) {
        print('Warning: Could not load enemy sprite: $path');
      }
    }
    
    if (sprites.isEmpty) {
      // Return a placeholder if no sprites loaded
      throw Exception('No sprites loaded for $enemyName');
    }
    
    return SpriteAnimation.spriteList(sprites, stepTime: stepTime);
  }
  
  Future<Sprite> _loadSprite(String path) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return Sprite(frame.image);
  }
  
  void setState(EnemyState state) {
    if (current != state) {
      current = state;
    }
  }
}

/// Factory for creating enemies
class EnemyFactory {
  static EnemySprite createEnemy(EnemyType type, {Vector2? position, Vector2? size}) {
    size ??= _getDefaultSize(type);
    
    return EnemySprite(
      enemyType: type,
      position: position,
      size: size,
    );
  }
  
  static Vector2 _getDefaultSize(EnemyType type) {
    switch (type) {
      case EnemyType.bee:
      case EnemyType.fly:
        return Vector2(48, 48);
      case EnemyType.frog:
        return Vector2(56, 48);
      case EnemyType.snail:
        return Vector2(56, 48);
      case EnemyType.saw:
        return Vector2(64, 64);
      default:
        return Vector2(48, 48);
    }
  }
  
  /// Get a random enemy type for spawning
  static EnemyType getRandomEnemyType() {
    final types = EnemyType.values;
    return types[(DateTime.now().millisecondsSinceEpoch % types.length)];
  }
}
