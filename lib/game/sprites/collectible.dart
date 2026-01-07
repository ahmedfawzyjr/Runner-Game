// ignore_for_file: deprecated_member_use, avoid_print

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/services.dart';

import '../../core/asset_paths.dart';

/// Collectible types available
enum CollectibleType {
  coinGold,
  coinSilver,
  coinBronze,
  gemBlue,
  gemGreen,
  gemRed,
  gemYellow,
  keyBlue,
  keyGreen,
  keyRed,
  keyYellow,
  star,
  heart,
}

/// A collectible item that can be picked up by the player
class Collectible extends SpriteComponent with HasGameRef {
  final CollectibleType type;
  final int value;
  bool isCollected = false;

  /// Floating animation parameters
  double _floatTime = 0;
  final double floatAmplitude;
  final double floatSpeed;
  final Vector2 _initialPosition;

  Collectible({
    required this.type,
    required Vector2 position,
    Vector2? size,
    this.floatAmplitude = 4.0,
    this.floatSpeed = 3.0,
  })  : _initialPosition = position.clone(),
        value = _getValue(type),
        super(
          position: position,
          size: size ?? Vector2.all(48),
          anchor: Anchor.center,
        );

  static int _getValue(CollectibleType type) {
    switch (type) {
      case CollectibleType.coinGold:
        return 10;
      case CollectibleType.coinSilver:
        return 5;
      case CollectibleType.coinBronze:
        return 1;
      case CollectibleType.gemBlue:
      case CollectibleType.gemGreen:
      case CollectibleType.gemRed:
      case CollectibleType.gemYellow:
        return 25;
      case CollectibleType.star:
        return 50;
      case CollectibleType.heart:
        return 0; // Hearts give health, not points
      default:
        return 0;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final path = _getSpritePath();

    try {
      final data = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      sprite = Sprite(frame.image);
    } catch (e) {
      print('Warning: Could not load collectible: $path');
    }
  }

  String _getSpritePath() {
    switch (type) {
      case CollectibleType.coinGold:
        return '${AssetPaths.tiles}coin_gold.png';
      case CollectibleType.coinSilver:
        return '${AssetPaths.tiles}coin_silver.png';
      case CollectibleType.coinBronze:
        return '${AssetPaths.tiles}coin_bronze.png';
      case CollectibleType.gemBlue:
        return '${AssetPaths.tiles}gem_blue.png';
      case CollectibleType.gemGreen:
        return '${AssetPaths.tiles}gem_green.png';
      case CollectibleType.gemRed:
        return '${AssetPaths.tiles}gem_red.png';
      case CollectibleType.gemYellow:
        return '${AssetPaths.tiles}gem_yellow.png';
      case CollectibleType.keyBlue:
        return '${AssetPaths.tiles}key_blue.png';
      case CollectibleType.keyGreen:
        return '${AssetPaths.tiles}key_green.png';
      case CollectibleType.keyRed:
        return '${AssetPaths.tiles}key_red.png';
      case CollectibleType.keyYellow:
        return '${AssetPaths.tiles}key_yellow.png';
      case CollectibleType.star:
        return '${AssetPaths.tiles}star.png';
      case CollectibleType.heart:
        return '${AssetPaths.tiles}heart.png';
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isCollected) {
      // Floating animation
      _floatTime += dt * floatSpeed;
      position.y = _initialPosition.y +
          (floatAmplitude * (0.5 + 0.5 * _sin(_floatTime)));
    }
  }

  // Simple sine approximation
  double _sin(double x) {
    x = x % (2 * 3.14159);
    if (x > 3.14159) x -= 2 * 3.14159;
    return x - (x * x * x / 6) + (x * x * x * x * x / 120);
  }

  /// Called when player collects this item
  void collect() {
    if (isCollected) return;

    isCollected = true;

    // Scale down animation before removal
    add(
      ScaleEffect.by(
        Vector2.all(0),
        EffectController(duration: 0.2),
        onComplete: removeFromParent,
      ),
    );
  }

  /// Check if collectible is a key
  bool get isKey =>
      type == CollectibleType.keyBlue ||
      type == CollectibleType.keyGreen ||
      type == CollectibleType.keyRed ||
      type == CollectibleType.keyYellow;

  /// Check if collectible is a coin
  bool get isCoin =>
      type == CollectibleType.coinGold ||
      type == CollectibleType.coinSilver ||
      type == CollectibleType.coinBronze;

  /// Check if collectible is a gem
  bool get isGem =>
      type == CollectibleType.gemBlue ||
      type == CollectibleType.gemGreen ||
      type == CollectibleType.gemRed ||
      type == CollectibleType.gemYellow;
}

/// Factory for creating collectibles
class CollectibleFactory {
  static Collectible createCoin(
      {required Vector2 position, CoinType coin = CoinType.gold}) {
    CollectibleType type;
    switch (coin) {
      case CoinType.gold:
        type = CollectibleType.coinGold;
        break;
      case CoinType.silver:
        type = CollectibleType.coinSilver;
        break;
      case CoinType.bronze:
        type = CollectibleType.coinBronze;
        break;
    }
    return Collectible(type: type, position: position);
  }

  static Collectible createGem(
      {required Vector2 position, GemColor color = GemColor.blue}) {
    CollectibleType type;
    switch (color) {
      case GemColor.blue:
        type = CollectibleType.gemBlue;
        break;
      case GemColor.green:
        type = CollectibleType.gemGreen;
        break;
      case GemColor.red:
        type = CollectibleType.gemRed;
        break;
      case GemColor.yellow:
        type = CollectibleType.gemYellow;
        break;
    }
    return Collectible(type: type, position: position);
  }

  static Collectible createHeart({required Vector2 position}) {
    return Collectible(type: CollectibleType.heart, position: position);
  }

  static Collectible createStar({required Vector2 position}) {
    return Collectible(type: CollectibleType.star, position: position);
  }
}

enum CoinType { gold, silver, bronze }

enum GemColor { blue, green, red, yellow }
