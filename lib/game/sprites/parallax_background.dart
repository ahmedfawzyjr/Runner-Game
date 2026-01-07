// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import '../../core/asset_paths.dart';

/// Background themes from the platform pack
enum BackgroundTheme {
  hills,
  trees,
  desert,
  mushrooms,
}

/// Parallax background component using platform pack backgrounds
class PlatformParallaxBackground extends ParallaxComponent {
  final BackgroundTheme theme;
  final double scrollSpeed;

  PlatformParallaxBackground({
    required this.theme,
    this.scrollSpeed = 50.0,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final themeName = theme.name;

    // Build parallax layers from back to front with different speeds
    final layers = <ParallaxLayer>[];

    // Layer 1: Sky/Solid background (slowest)
    try {
      final skyImage =
          await _loadImage('${AssetPaths.backgrounds}background_solid_sky.png');
      layers.add(ParallaxLayer(
        ParallaxImage(skyImage, repeat: ImageRepeat.repeatX),
        velocityMultiplier: Vector2(0.1, 0),
      ));
    } catch (e) {
      print('Warning: Could not load sky background');
    }

    // Layer 2: Clouds
    try {
      final cloudsImage =
          await _loadImage('${AssetPaths.backgrounds}background_clouds.png');
      layers.add(ParallaxLayer(
        ParallaxImage(cloudsImage, repeat: ImageRepeat.repeatX),
        velocityMultiplier: Vector2(0.2, 0),
      ));
    } catch (e) {
      print('Warning: Could not load clouds background');
    }

    // Layer 3: Fade theme (middle distance)
    try {
      final fadeImage = await _loadImage(
        AssetPaths.getBackground(themeName, 'fade'),
      );
      layers.add(ParallaxLayer(
        ParallaxImage(fadeImage, repeat: ImageRepeat.repeatX),
        velocityMultiplier: Vector2(0.4, 0),
      ));
    } catch (e) {
      print('Warning: Could not load fade background');
    }

    // Layer 4: Color theme (closest background layer)
    try {
      final colorImage = await _loadImage(
        AssetPaths.getBackground(themeName, 'color'),
      );
      layers.add(ParallaxLayer(
        ParallaxImage(colorImage, repeat: ImageRepeat.repeatX),
        velocityMultiplier: Vector2(0.6, 0),
      ));
    } catch (e) {
      print('Warning: Could not load color background');
    }

    parallax = Parallax(
      layers,
      baseVelocity: Vector2(scrollSpeed, 0),
    );
  }

  Future<ui.Image> _loadImage(String path) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  /// Update the base scroll speed
  void setScrollSpeed(double speed) {
    parallax?.baseVelocity = Vector2(speed, 0);
  }

  /// Stop scrolling
  void stop() {
    parallax?.baseVelocity = Vector2.zero();
  }

  /// Resume scrolling
  void resume() {
    parallax?.baseVelocity = Vector2(scrollSpeed, 0);
  }
}

/// Simple layered background without parallax effect
class StaticBackground extends PositionComponent {
  final BackgroundTheme theme;
  final List<SpriteComponent> layers = [];

  StaticBackground({required this.theme});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final themeName = theme.name;

    // Add layers from back to front
    final layerPaths = [
      '${AssetPaths.backgrounds}background_solid_sky.png',
      '${AssetPaths.backgrounds}background_clouds.png',
      AssetPaths.getBackground(themeName, 'fade'),
      AssetPaths.getBackground(themeName, 'color'),
    ];

    for (final path in layerPaths) {
      try {
        final data = await rootBundle.load(path);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();

        final sprite = SpriteComponent(
          sprite: Sprite(frame.image),
          size: size,
        );

        layers.add(sprite);
        add(sprite);
      } catch (e) {
        print('Warning: Could not load layer: $path');
      }
    }
  }
}
