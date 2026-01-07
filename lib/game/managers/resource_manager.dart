// ignore_for_file: avoid_print

import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import '../../core/game_config.dart';

/// Manages shared game resources to optimize memory and performance
class ResourceManager {
  static final ResourceManager _instance = ResourceManager._internal();
  factory ResourceManager() => _instance;
  ResourceManager._internal();

  // Current character color
  String characterColor = 'green';

  // Player animations - platform pack style
  late SpriteAnimation playerRun;
  late SpriteAnimation playerJump;
  late SpriteAnimation playerAttack;
  late SpriteAnimation playerHit;
  late SpriteAnimation playerDeath;
  late SpriteAnimation playerIdle;
  late SpriteAnimation playerDuck;
  late SpriteAnimation playerClimb;

  // Enemy animations - multiple types
  late Map<String, SpriteAnimation> enemyAnimations;
  late SpriteAnimation enemyWalk;
  late SpriteAnimation enemyDeath;

  bool _initialized = false;
  bool _platformAssetsLoaded = false;

  /// Load all game assets
  Future<void> loadAssets() async {
    if (_initialized) return;

    // Load platform character assets
    await loadPlatformCharacter(characterColor);

    // Load platform enemy assets
    await loadPlatformEnemies();

    _initialized = true;
  }

  /// Load platform character sprites for given color
  Future<void> loadPlatformCharacter(String color) async {
    characterColor = color;
    // ignore: prefer_const_declarations
    final basePath = 'platform/Sprites/Characters/Default/';

    // Preload all character images for this color
    final imagesToLoad = [
      '${basePath}character_${color}_idle.png',
      '${basePath}character_${color}_walk_a.png',
      '${basePath}character_${color}_walk_b.png',
      '${basePath}character_${color}_jump.png',
      '${basePath}character_${color}_duck.png',
      '${basePath}character_${color}_hit.png',
      '${basePath}character_${color}_climb_a.png',
      '${basePath}character_${color}_climb_b.png',
      '${basePath}character_${color}_front.png',
    ];

    try {
      await Flame.images.loadAll(imagesToLoad);
      _platformAssetsLoaded = true;
    } catch (e) {
      print('Platform character loading error: $e');
      // Fall back to original assets
      await _loadLegacyAssets();
      return;
    }

    // Create Player Animations from platform sprites
    playerIdle = SpriteAnimation.spriteList(
      [
        Sprite(Flame.images.fromCache('${basePath}character_${color}_idle.png'))
      ],
      stepTime: 0.5,
    );

    playerRun = SpriteAnimation.spriteList(
      [
        Sprite(
            Flame.images.fromCache('${basePath}character_${color}_walk_a.png')),
        Sprite(
            Flame.images.fromCache('${basePath}character_${color}_idle.png')),
        Sprite(
            Flame.images.fromCache('${basePath}character_${color}_walk_b.png')),
        Sprite(
            Flame.images.fromCache('${basePath}character_${color}_idle.png')),
      ],
      stepTime: GameConfig.runAnimSpeed,
    );

    playerJump = SpriteAnimation.spriteList(
      [
        Sprite(Flame.images.fromCache('${basePath}character_${color}_jump.png'))
      ],
      stepTime: 0.1,
      loop: false,
    );

    playerDuck = SpriteAnimation.spriteList(
      [
        Sprite(Flame.images.fromCache('${basePath}character_${color}_duck.png'))
      ],
      stepTime: 0.1,
      loop: false,
    );

    // Attack animation (using jump + front for punch effect)
    playerAttack = SpriteAnimation.spriteList(
      [
        Sprite(
            Flame.images.fromCache('${basePath}character_${color}_front.png')),
        Sprite(
            Flame.images.fromCache('${basePath}character_${color}_jump.png')),
        Sprite(
            Flame.images.fromCache('${basePath}character_${color}_front.png')),
      ],
      stepTime: GameConfig.attackAnimSpeed,
      loop: false,
    );

    playerHit = SpriteAnimation.spriteList(
      [Sprite(Flame.images.fromCache('${basePath}character_${color}_hit.png'))],
      stepTime: 0.2,
      loop: false,
    );

    // Death animation (hit + duck combo)
    playerDeath = SpriteAnimation.spriteList(
      [
        Sprite(Flame.images.fromCache('${basePath}character_${color}_hit.png')),
        Sprite(
            Flame.images.fromCache('${basePath}character_${color}_duck.png')),
      ],
      stepTime: GameConfig.deathAnimSpeed,
      loop: false,
    );

    playerClimb = SpriteAnimation.spriteList(
      [
        Sprite(Flame.images
            .fromCache('${basePath}character_${color}_climb_a.png')),
        Sprite(Flame.images
            .fromCache('${basePath}character_${color}_climb_b.png')),
      ],
      stepTime: 0.2,
    );
  }

  /// Load platform enemy sprites
  Future<void> loadPlatformEnemies() async {
    const basePath = 'platform/Sprites/Enemies/Default/';

    // Load slime enemies (most common)
    final enemyImages = [
      '${basePath}slime_normal_rest.png',
      '${basePath}slime_normal_walk_a.png',
      '${basePath}slime_normal_walk_b.png',
      '${basePath}slime_normal_flat.png',
      '${basePath}bee_rest.png',
      '${basePath}bee_a.png',
      '${basePath}bee_b.png',
      '${basePath}fly_rest.png',
      '${basePath}fly_a.png',
      '${basePath}fly_b.png',
      '${basePath}snail_rest.png',
      '${basePath}snail_walk_a.png',
      '${basePath}snail_walk_b.png',
      '${basePath}snail_shell.png',
    ];

    try {
      await Flame.images.loadAll(enemyImages);

      // Create slime walk animation (default enemy)
      enemyWalk = SpriteAnimation.spriteList(
        [
          Sprite(Flame.images.fromCache('${basePath}slime_normal_rest.png')),
          Sprite(Flame.images.fromCache('${basePath}slime_normal_walk_a.png')),
          Sprite(Flame.images.fromCache('${basePath}slime_normal_rest.png')),
          Sprite(Flame.images.fromCache('${basePath}slime_normal_walk_b.png')),
        ],
        stepTime: 0.15,
      );

      // Death animation (squash flat)
      enemyDeath = SpriteAnimation.spriteList(
        [
          Sprite(Flame.images.fromCache('${basePath}slime_normal_rest.png')),
          Sprite(Flame.images.fromCache('${basePath}slime_normal_flat.png')),
        ],
        stepTime: 0.1,
        loop: false,
      );

      // Store additional enemy animations
      enemyAnimations = {
        'slime_walk': enemyWalk,
        'slime_death': enemyDeath,
        'bee_fly': SpriteAnimation.spriteList(
          [
            Sprite(Flame.images.fromCache('${basePath}bee_a.png')),
            Sprite(Flame.images.fromCache('${basePath}bee_b.png')),
          ],
          stepTime: 0.1,
        ),
        'fly_fly': SpriteAnimation.spriteList(
          [
            Sprite(Flame.images.fromCache('${basePath}fly_a.png')),
            Sprite(Flame.images.fromCache('${basePath}fly_b.png')),
          ],
          stepTime: 0.1,
        ),
        'snail_walk': SpriteAnimation.spriteList(
          [
            Sprite(Flame.images.fromCache('${basePath}snail_walk_a.png')),
            Sprite(Flame.images.fromCache('${basePath}snail_rest.png')),
            Sprite(Flame.images.fromCache('${basePath}snail_walk_b.png')),
            Sprite(Flame.images.fromCache('${basePath}snail_rest.png')),
          ],
          stepTime: 0.2,
        ),
        'snail_death': SpriteAnimation.spriteList(
          [Sprite(Flame.images.fromCache('${basePath}snail_shell.png'))],
          stepTime: 0.1,
          loop: false,
        ),
      };
    } catch (e) {
      print('Platform enemy loading error: $e');
      await _loadLegacyEnemies();
    }
  }

  /// Fall back to legacy assets if platform assets fail
  Future<void> _loadLegacyAssets() async {
    await Flame.images.loadAll([
      'Run__001.png',
      'Run__002.png',
      'Run__003.png',
      'Run__004.png',
      'Run__005.png',
      'Run__006.png',
      'Run__007.png',
      'Run__008.png',
      'Run__009.png',
    ]);

    final runSprites = List.generate(
        8, (i) => Sprite(Flame.images.fromCache('Run__00${i + 1}.png')));
    playerRun = SpriteAnimation.spriteList(runSprites,
        stepTime: GameConfig.runAnimSpeed);

    playerIdle = SpriteAnimation.spriteList(
      [
        Sprite(Flame.images.fromCache('Run__001.png')),
        Sprite(Flame.images.fromCache('Run__002.png'))
      ],
      stepTime: 0.3,
    );

    playerJump = SpriteAnimation.spriteList(
      [Sprite(Flame.images.fromCache('Run__003.png'))],
      stepTime: 0.1,
      loop: false,
    );

    playerAttack = SpriteAnimation.spriteList(
      [
        Sprite(Flame.images.fromCache('Run__005.png')),
        Sprite(Flame.images.fromCache('Run__006.png')),
        Sprite(Flame.images.fromCache('Run__007.png')),
      ],
      stepTime: GameConfig.attackAnimSpeed,
      loop: false,
    );

    playerHit = SpriteAnimation.spriteList(
      [Sprite(Flame.images.fromCache('Run__004.png'))],
      stepTime: 0.2,
      loop: false,
    );

    playerDeath = SpriteAnimation.spriteList(
      [
        Sprite(Flame.images.fromCache('Run__008.png')),
        Sprite(Flame.images.fromCache('Run__001.png'))
      ],
      stepTime: GameConfig.deathAnimSpeed,
      loop: false,
    );

    playerDuck = playerHit; // Fallback
    playerClimb = playerRun; // Fallback
  }

  /// Fall back to legacy enemy assets
  Future<void> _loadLegacyEnemies() async {
    await Flame.images.loadAll([
      'Zombiz1.png',
      'Zombiz2.png',
      'Zombiz3.png',
      'Zombiz4.png',
      'Zombiz5.png',
      'Zombiz6.png',
      'Zombiz7.png',
    ]);

    final zombieSprites = List.generate(
        7, (i) => Sprite(Flame.images.fromCache('Zombiz${i + 1}.png')));
    enemyWalk = SpriteAnimation.spriteList(zombieSprites, stepTime: 0.1);
    enemyDeath = SpriteAnimation.spriteList(
      zombieSprites.reversed.take(3).toList(),
      stepTime: 0.15,
      loop: false,
    );
    enemyAnimations = {'slime_walk': enemyWalk, 'slime_death': enemyDeath};
  }

  /// Change character color and reload sprites
  Future<void> changeCharacterColor(String newColor) async {
    if (newColor != characterColor) {
      await loadPlatformCharacter(newColor);
    }
  }

  /// Get available character colors
  static const List<String> characterColors = [
    'beige',
    'green',
    'pink',
    'purple',
    'yellow'
  ];

  /// Check if platform assets are loaded
  bool get hasPlatformAssets => _platformAssetsLoaded;
}
