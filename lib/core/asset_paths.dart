/// Asset paths for the Platform Pack assets (Kenney.nl)
///
/// All paths are relative to the project root.
// ignore_for_file: unnecessary_brace_in_string_interps

class AssetPaths {
  AssetPaths._();

  // Base paths
  static const String platformBase = 'assets/platform/';
  static const String spritesBase = '${platformBase}Sprites/';

  // Character sprites (5 colors × 9 animations)
  static const String characters = '${spritesBase}Characters/Default/';
  static const String charactersDouble = '${spritesBase}Characters/Double/';

  // Enemy sprites (12+ enemy types)
  static const String enemies = '${spritesBase}Enemies/Default/';
  static const String enemiesDouble = '${spritesBase}Enemies/Double/';

  // Tile sprites (6 terrain types, 300+ tiles)
  static const String tiles = '${spritesBase}Tiles/Default/';
  static const String tilesDouble = '${spritesBase}Tiles/Double/';

  // Background sprites (4 themes)
  static const String backgrounds = '${spritesBase}Backgrounds/Default/';
  static const String backgroundsDouble = '${spritesBase}Backgrounds/Double/';

  // Sound effects
  static const String sounds = '${platformBase}Sounds/';

  // Spritesheets
  static const String spritesheets = '${platformBase}Spritesheets/';

  /// Character color variants available
  static const List<String> characterColors = [
    'beige',
    'green',
    'pink',
    'purple',
    'yellow',
  ];

  /// Character animation types
  static const List<String> characterAnimations = [
    'idle',
    'walk_a',
    'walk_b',
    'jump',
    'duck',
    'climb_a',
    'climb_b',
    'hit',
    'front',
  ];

  /// Enemy types available
  static const List<String> enemyTypes = [
    'slime_normal',
    'slime_fire',
    'slime_spike',
    'slime_block',
    'bee',
    'fly',
    'frog',
    'snail',
    'ladybug',
    'mouse',
    'worm_normal',
    'worm_ring',
    'fish_blue',
    'fish_purple',
    'fish_yellow',
    'barnacle',
    'saw',
    'block',
  ];

  /// Terrain theme types
  static const List<String> terrainTypes = [
    'grass',
    'dirt',
    'sand',
    'snow',
    'stone',
    'purple',
  ];

  /// Background theme types
  static const List<String> backgroundThemes = [
    'hills',
    'trees',
    'desert',
    'mushrooms',
  ];

  /// Sound effect files
  static const Map<String, String> soundEffects = {
    'bump': '${sounds}sfx_bump.ogg',
    'coin': '${sounds}sfx_coin.ogg',
    'disappear': '${sounds}sfx_disappear.ogg',
    'gem': '${sounds}sfx_gem.ogg',
    'hurt': '${sounds}sfx_hurt.ogg',
    'jump': '${sounds}sfx_jump.ogg',
    'jumpHigh': '${sounds}sfx_jump-high.ogg',
    'magic': '${sounds}sfx_magic.ogg',
    'select': '${sounds}sfx_select.ogg',
    'throw': '${sounds}sfx_throw.ogg',
  };

  // Helper methods

  /// Get character sprite path for a given color and animation
  static String getCharacterSprite(String color, String animation) {
    return '${characters}character_${color}_$animation.png';
  }

  /// Get enemy sprite path for a given type and state
  static String getEnemySprite(String type, String state) {
    return '${enemies}${type}_$state.png';
  }

  /// Get terrain tile path
  static String getTerrainTile(String terrainType, String tileName) {
    return '${tiles}terrain_${terrainType}_$tileName.png';
  }

  /// Get background layer path
  static String getBackground(String theme, String layer) {
    return '${backgrounds}background_${layer}_$theme.png';
  }

  /// Get HUD element path
  static String getHudElement(String name) {
    return '${tiles}hud_$name.png';
  }

  /// Get collectible path
  static String getCollectible(String type, String variant) {
    return '${tiles}${type}_$variant.png';
  }
}
