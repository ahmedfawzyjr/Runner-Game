// ignore_for_file: unnecessary_import, avoid_print

import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import '../../core/asset_paths.dart';

/// Character animation states
enum CharacterState {
  idle,
  walking,
  jumping,
  ducking,
  climbing,
  hit,
}

/// A character sprite component with support for multiple animations
/// and color variants from the Kenney Platform Pack.
class CharacterSprite extends SpriteAnimationGroupComponent<CharacterState> {
  /// The color variant of this character (beige, green, pink, purple, yellow)
  final String colorVariant;
  
  /// Animation duration for each frame
  final double stepTime;
  
  CharacterSprite({
    this.colorVariant = 'green',
    this.stepTime = 0.12,
    super.position,
    super.size,
    super.anchor = Anchor.bottomCenter,
  });
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Load all animations for this character color
    animations = {
      CharacterState.idle: await _loadAnimation(['idle'], stepTime),
      CharacterState.walking: await _loadAnimation(['walk_a', 'walk_b'], stepTime),
      CharacterState.jumping: await _loadAnimation(['jump'], stepTime),
      CharacterState.ducking: await _loadAnimation(['duck'], stepTime),
      CharacterState.climbing: await _loadAnimation(['climb_a', 'climb_b'], stepTime),
      CharacterState.hit: await _loadAnimation(['hit'], stepTime),
    };
    
    // Start with idle animation
    current = CharacterState.idle;
  }
  
  /// Load an animation from a list of animation frame names
  Future<SpriteAnimation> _loadAnimation(
    List<String> frameNames, 
    double stepTime,
  ) async {
    final sprites = <Sprite>[];
    
    for (final frameName in frameNames) {
      final path = AssetPaths.getCharacterSprite(colorVariant, frameName);
      final sprite = await _loadSprite(path);
      sprites.add(sprite);
    }
    
    return SpriteAnimation.spriteList(sprites, stepTime: stepTime);
  }
  
  /// Load a single sprite from an asset path
  Future<Sprite> _loadSprite(String path) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return Sprite(frame.image);
  }
  
  /// Set the character state (plays corresponding animation)
  void setState(CharacterState state) {
    if (current != state) {
      current = state;
    }
  }
  
  /// Check if character is in a specific state
  bool isInState(CharacterState state) => current == state;
  
  /// Flip character horizontally (for facing left/right)
  void faceLeft() {
    if (scale.x > 0) {
      flipHorizontally();
    }
  }
  
  /// Face right (default)
  void faceRight() {
    if (scale.x < 0) {
      flipHorizontally();
    }
  }
}

/// Factory for creating character sprites with preloaded assets
class CharacterSpriteFactory {
  static final Map<String, Map<String, Sprite>> _spriteCache = {};
  
  /// Preload all sprites for a character color
  static Future<void> preloadCharacter(String color) async {
    if (_spriteCache.containsKey(color)) return;
    
    _spriteCache[color] = {};
    
    for (final animation in AssetPaths.characterAnimations) {
      final path = AssetPaths.getCharacterSprite(color, animation);
      try {
        final data = await rootBundle.load(path);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        _spriteCache[color]![animation] = Sprite(frame.image);
      } catch (e) {
        // Skip if sprite doesn't exist
        print('Warning: Could not load sprite: $path');
      }
    }
  }
  
  /// Preload all character colors
  static Future<void> preloadAllCharacters() async {
    for (final color in AssetPaths.characterColors) {
      await preloadCharacter(color);
    }
  }
  
  /// Get a cached sprite
  static Sprite? getSprite(String color, String animation) {
    return _spriteCache[color]?[animation];
  }
  
  /// Clear the sprite cache
  static void clearCache() {
    _spriteCache.clear();
  }
}
