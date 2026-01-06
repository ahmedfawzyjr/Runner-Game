import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio/audio_manager.dart';
import '../core/game_config.dart';
import '../core/game_state.dart';

/// Leaderboard screen showing high scores
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = GameState();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D0D1A),
              Color(0xFF1A0A2E),
              Color(0xFF0D0D1A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        AudioManager().playButton();
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'LEADERBOARD',
                      style: GoogleFonts.orbitron(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
              // Difficulty tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.cyan, Colors.purple],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: const [
                    Tab(text: 'EASY'),
                    Tab(text: 'MEDIUM'),
                    Tab(text: 'HARD'),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLeaderboardContent(Difficulty.easy, state),
                    _buildLeaderboardContent(Difficulty.medium, state),
                    _buildLeaderboardContent(Difficulty.hard, state),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardContent(Difficulty difficulty, GameState state) {
    final highScore = state.highScores[difficulty]!;
    final diffSettings = GameConfig.difficulties[difficulty]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          // Your best score card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getDifficultyColor(difficulty).withOpacity(0.3),
                  Colors.black.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getDifficultyColor(difficulty).withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: _getDifficultyColor(difficulty),
                  size: 50,
                ),
                const SizedBox(height: 15),
                Text(
                  'YOUR BEST',
                  style: GoogleFonts.rajdhani(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  highScore.toString(),
                  style: GoogleFonts.orbitron(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: _getDifficultyColor(difficulty),
                    shadows: [
                      Shadow(
                        color: _getDifficultyColor(difficulty).withOpacity(0.5),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
                Text(
                  diffSettings.name.toUpperCase(),
                  style: GoogleFonts.orbitron(
                    fontSize: 18,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Stats
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR STATS',
                  style: GoogleFonts.orbitron(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 15),
                _buildStatRow(
                  'Total Runs',
                  state.totalRuns.toString(),
                  Icons.replay,
                  Colors.blue,
                ),
                _buildStatRow(
                  'Total Kills',
                  state.totalKills.toString(),
                  Icons.dangerous,
                  Colors.red,
                ),
                _buildStatRow(
                  'Total Distance',
                  '${(state.totalDistance / 1000).toStringAsFixed(1)} km',
                  Icons.straighten,
                  Colors.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.cyan.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.cyan),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    'Score multiplier: ${diffSettings.scoreMultiplier}x\nPlay on harder difficulties for higher scores!',
                    style: GoogleFonts.rajdhani(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.rajdhani(
                color: Colors.grey.shade400,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
    }
  }
}
