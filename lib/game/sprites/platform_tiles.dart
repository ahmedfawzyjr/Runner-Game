// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import '../../core/asset_paths.dart';

/// Terrain types available in the platform pack
enum TerrainType {
  grass,
  dirt,
  sand,
  snow,
  stone,
  purple,
}

/// Platform tile component for building ground and platforms
class PlatformTile extends SpriteComponent {
  final TerrainType terrainType;
  final String tileType;

  PlatformTile({
    required this.terrainType,
    required this.tileType,
    super.position,
    super.size,
    super.anchor = Anchor.topLeft,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final terrainName = terrainType.name;
    final path = AssetPaths.getTerrainTile(terrainName, tileType);

    try {
      final data = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      sprite = Sprite(frame.image);
    } catch (e) {
      print('Warning: Could not load tile: $path');
    }
  }
}

/// Builds a multi-tile platform from the 9-slice tiles
class PlatformBuilder {
  static const double tileSize = 64.0;

  /// Create a horizontal platform of given width (in tiles)
  static Future<List<PlatformTile>> buildHorizontalPlatform({
    required TerrainType terrain,
    required Vector2 startPosition,
    required int widthInTiles,
  }) async {
    final tiles = <PlatformTile>[];

    for (int i = 0; i < widthInTiles; i++) {
      String tileType;

      if (widthInTiles == 1) {
        // Single tile
        tileType = 'block';
      } else if (i == 0) {
        // Left edge
        tileType = 'horizontal_left';
      } else if (i == widthInTiles - 1) {
        // Right edge
        tileType = 'horizontal_right';
      } else {
        // Middle
        tileType = 'horizontal_middle';
      }

      final tile = PlatformTile(
        terrainType: terrain,
        tileType: tileType,
        position: Vector2(startPosition.x + (i * tileSize), startPosition.y),
        size: Vector2.all(tileSize),
      );

      tiles.add(tile);
    }

    return tiles;
  }

  /// Create a full block platform (with top surface)
  static Future<List<PlatformTile>> buildBlockPlatform({
    required TerrainType terrain,
    required Vector2 startPosition,
    required int widthInTiles,
    required int heightInTiles,
  }) async {
    final tiles = <PlatformTile>[];

    for (int y = 0; y < heightInTiles; y++) {
      for (int x = 0; x < widthInTiles; x++) {
        String tileType;

        // Determine tile type based on position in grid
        final isTop = y == 0;
        final isBottom = y == heightInTiles - 1;
        final isLeft = x == 0;
        final isRight = x == widthInTiles - 1;

        if (isTop && isLeft) {
          tileType = 'block_top_left';
        } else if (isTop && isRight) {
          tileType = 'block_top_right';
        } else if (isTop) {
          tileType = 'block_top';
        } else if (isBottom && isLeft) {
          tileType = 'block_bottom_left';
        } else if (isBottom && isRight) {
          tileType = 'block_bottom_right';
        } else if (isBottom) {
          tileType = 'block_bottom';
        } else if (isLeft) {
          tileType = 'block_left';
        } else if (isRight) {
          tileType = 'block_right';
        } else {
          tileType = 'block_center';
        }

        final tile = PlatformTile(
          terrainType: terrain,
          tileType: tileType,
          position: Vector2(
            startPosition.x + (x * tileSize),
            startPosition.y + (y * tileSize),
          ),
          size: Vector2.all(tileSize),
        );

        tiles.add(tile);
      }
    }

    return tiles;
  }

  /// Create a floating cloud platform
  static Future<List<PlatformTile>> buildCloudPlatform({
    required TerrainType terrain,
    required Vector2 startPosition,
    required int widthInTiles,
  }) async {
    final tiles = <PlatformTile>[];

    for (int i = 0; i < widthInTiles; i++) {
      String tileType;

      if (widthInTiles == 1) {
        tileType = 'cloud';
      } else if (i == 0) {
        tileType = 'cloud_left';
      } else if (i == widthInTiles - 1) {
        tileType = 'cloud_right';
      } else {
        tileType = 'cloud_middle';
      }

      final tile = PlatformTile(
        terrainType: terrain,
        tileType: tileType,
        position: Vector2(startPosition.x + (i * tileSize), startPosition.y),
        size: Vector2.all(tileSize),
      );

      tiles.add(tile);
    }

    return tiles;
  }
}

/// Hazard types
enum HazardType {
  spikes,
  saw,
  lava,
}

/// Hazard component for dangerous obstacles
class HazardTile extends SpriteComponent with HasGameRef {
  final HazardType hazardType;

  HazardTile({
    required this.hazardType,
    super.position,
    super.size,
    super.anchor = Anchor.bottomCenter,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    String path;
    switch (hazardType) {
      case HazardType.spikes:
        path = '${AssetPaths.tiles}spikes.png';
        break;
      case HazardType.saw:
        path = '${AssetPaths.tiles}saw.png';
        break;
      case HazardType.lava:
        path = '${AssetPaths.tiles}lava_top.png';
        break;
    }

    try {
      final data = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      sprite = Sprite(frame.image);
    } catch (e) {
      print('Warning: Could not load hazard: $path');
    }
  }
}
