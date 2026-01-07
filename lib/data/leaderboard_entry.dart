// ignore_for_file: avoid_print

import 'dart:convert';
import '../core/game_config.dart';

/// Represents a single leaderboard entry with detailed stats
class LeaderboardEntry {
  final int score;
  final int kills;
  final int maxCombo;
  final double distance;
  final double timeSurvived;
  final DateTime timestamp;
  final Difficulty difficulty;
  final String playerName;
  final String characterColor;

  LeaderboardEntry({
    required this.score,
    required this.kills,
    required this.maxCombo,
    required this.distance,
    required this.timeSurvived,
    required this.timestamp,
    required this.difficulty,
    this.playerName = 'Player',
    this.characterColor = 'green',
  });

  /// Create entry from current game state
  factory LeaderboardEntry.fromGameState({
    required int score,
    required int kills,
    required int maxCombo,
    required double distance,
    required double timeSurvived,
    required Difficulty difficulty,
    String playerName = 'Player',
    String characterColor = 'green',
  }) {
    return LeaderboardEntry(
      score: score,
      kills: kills,
      maxCombo: maxCombo,
      distance: distance,
      timeSurvived: timeSurvived,
      timestamp: DateTime.now(),
      difficulty: difficulty,
      playerName: playerName,
      characterColor: characterColor,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'score': score,
    'kills': kills,
    'maxCombo': maxCombo,
    'distance': distance,
    'timeSurvived': timeSurvived,
    'timestamp': timestamp.toIso8601String(),
    'difficulty': difficulty.index,
    'playerName': playerName,
    'characterColor': characterColor,
  };

  /// Create from JSON
  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      score: json['score'] as int,
      kills: json['kills'] as int,
      maxCombo: json['maxCombo'] as int,
      distance: (json['distance'] as num).toDouble(),
      timeSurvived: (json['timeSurvived'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      difficulty: Difficulty.values[json['difficulty'] as int],
      playerName: json['playerName'] as String? ?? 'Player',
      characterColor: json['characterColor'] as String? ?? 'green',
    );
  }

  /// Check if this entry is from today
  bool get isToday {
    final now = DateTime.now();
    return timestamp.year == now.year &&
           timestamp.month == now.month &&
           timestamp.day == now.day;
  }

  /// Check if this entry is from this week
  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return timestamp.isAfter(weekStart.subtract(const Duration(days: 1)));
  }

  /// Get formatted time survived string
  String get timeSurvivedFormatted {
    final minutes = (timeSurvived / 60).floor();
    final seconds = (timeSurvived % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get formatted distance string
  String get distanceFormatted {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
    return '${distance.toStringAsFixed(0)}m';
  }
}

/// Manages leaderboard data with filtering and ranking
class LeaderboardManager {
  final List<LeaderboardEntry> _entries = [];
  static const int maxEntries = 100;

  /// Add a new entry
  void addEntry(LeaderboardEntry entry) {
    _entries.add(entry);
    
    // Sort by score descending
    _entries.sort((a, b) => b.score.compareTo(a.score));
    
    // Keep only top entries
    if (_entries.length > maxEntries) {
      _entries.removeRange(maxEntries, _entries.length);
    }
  }

  /// Get entries filtered by time period
  List<LeaderboardEntry> getEntries({
    LeaderboardPeriod period = LeaderboardPeriod.allTime,
    Difficulty? difficulty,
    int limit = 20,
  }) {
    var filtered = _entries.where((entry) {
      // Filter by period
      switch (period) {
        case LeaderboardPeriod.daily:
          if (!entry.isToday) return false;
          break;
        case LeaderboardPeriod.weekly:
          if (!entry.isThisWeek) return false;
          break;
        case LeaderboardPeriod.allTime:
          break;
      }
      
      // Filter by difficulty
      if (difficulty != null && entry.difficulty != difficulty) {
        return false;
      }
      
      return true;
    }).toList();
    
    return filtered.take(limit).toList();
  }

  /// Get rank for a given score
  int getRank(int score, {Difficulty? difficulty}) {
    final entries = getEntries(difficulty: difficulty);
    for (int i = 0; i < entries.length; i++) {
      if (entries[i].score == score) {
        return i + 1;
      }
    }
    return entries.length + 1;
  }

  /// Get player's best score for a difficulty
  LeaderboardEntry? getBestScore(Difficulty difficulty) {
    final entries = getEntries(difficulty: difficulty, limit: 1);
    return entries.isNotEmpty ? entries.first : null;
  }

  /// Convert to JSON for storage
  String toJson() {
    return jsonEncode(_entries.map((e) => e.toJson()).toList());
  }

  /// Load from JSON
  void fromJson(String jsonString) {
    _entries.clear();
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      for (var item in list) {
        _entries.add(LeaderboardEntry.fromJson(item as Map<String, dynamic>));
      }
    } catch (e) {
      // Handle corrupt data
      print('Leaderboard data error: $e');
    }
  }

  /// Clear all entries
  void clear() {
    _entries.clear();
  }

  /// Get total stats
  Map<String, dynamic> getTotalStats() {
    int totalKills = 0;
    double totalDistance = 0;
    int totalRuns = _entries.length;
    int bestScore = 0;

    for (var entry in _entries) {
      totalKills += entry.kills;
      totalDistance += entry.distance;
      if (entry.score > bestScore) {
        bestScore = entry.score;
      }
    }

    return {
      'totalKills': totalKills,
      'totalDistance': totalDistance,
      'totalRuns': totalRuns,
      'bestScore': bestScore,
    };
  }
}

/// Time periods for leaderboard filtering
enum LeaderboardPeriod {
  daily,
  weekly,
  allTime,
}
