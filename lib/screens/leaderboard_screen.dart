// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio/audio_manager.dart';
import '../core/game_config.dart';
import '../core/game_state.dart';

/// Premium leaderboard screen with larger score display
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
    
    // Find initial tab based on current difficulty
    final currentDifficulty = GameState().difficulty;
    _tabController.index = currentDifficulty.index;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = GameState();
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final isLandscape = size.width > size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.5),
            radius: 1.5,
            colors: [
              Color(0xFF1A0A2E),
              Color(0xFF0D0D1A),
              Color(0xFF050510),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: isSmallScreen ? 12 : 16,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () {
                        AudioManager().playButton();
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.cyan, Colors.purple],
                        ).createShader(bounds),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'LEADERBOARD',
                            style: GoogleFonts.orbitron(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Difficulty tabs
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isLandscape ? 40 : 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.cyan, Colors.purple],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey.shade500,
                        labelStyle: GoogleFonts.orbitron(
                          fontSize: isSmallScreen ? 13 : 15,
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelStyle: GoogleFonts.orbitron(
                          fontSize: isSmallScreen ? 13 : 15,
                        ),
                        tabs: const [
                          Tab(text: 'EASY'),
                          Tab(text: 'MEDIUM'),
                          Tab(text: 'HARD'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 16 : 24),
              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLeaderboardContent(Difficulty.easy, state, size, isSmallScreen, isLandscape),
                    _buildLeaderboardContent(Difficulty.medium, state, size, isSmallScreen, isLandscape),
                    _buildLeaderboardContent(Difficulty.hard, state, size, isSmallScreen, isLandscape),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardContent(
    Difficulty difficulty,
    GameState state,
    Size size,
    bool isSmall,
    bool isLandscape,
  ) {
    final highScore = state.highScores[difficulty]!;
    final diffSettings = GameConfig.difficulties[difficulty]!;
    final horizontalPadding = isLandscape ? 60.0 : 24.0;
    final scoreFontSize = (size.width * 0.18).clamp(48.0, 100.0);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          // Your best score card - BIGGER
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: isSmall ? 28 : 40,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getDifficultyColor(difficulty).withOpacity(0.25),
                      Colors.black.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _getDifficultyColor(difficulty).withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    // Trophy icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(difficulty).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.emoji_events_rounded,
                        color: _getDifficultyColor(difficulty),
                        size: isSmall ? 40 : 56,
                      ),
                    ),
                    SizedBox(height: isSmall ? 12 : 20),
                    Text(
                      'YOUR BEST',
                      style: GoogleFonts.rajdhani(
                        color: Colors.grey.shade400,
                        fontSize: isSmall ? 14 : 16,
                        letterSpacing: 6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: isSmall ? 8 : 12),
                    // BIG SCORE NUMBER
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: _getDifficultyColor(difficulty).withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Text(
                        highScore.toString(),
                        style: GoogleFonts.orbitron(
                          fontSize: scoreFontSize,
                          fontWeight: FontWeight.bold,
                          color: _getDifficultyColor(difficulty),
                        ),
                      ),
                    ),
                    SizedBox(height: isSmall ? 8 : 12),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmall ? 18 : 24,
                        vertical: isSmall ? 6 : 10,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(difficulty).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getDifficultyColor(difficulty).withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        diffSettings.name.toUpperCase(),
                        style: GoogleFonts.orbitron(
                          fontSize: isSmall ? 14 : 18,
                          color: Colors.white,
                          letterSpacing: 4,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: isSmall ? 20 : 28),
          // Stats card
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(isSmall ? 18 : 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR STATS',
                      style: GoogleFonts.orbitron(
                        color: Colors.grey.shade500,
                        fontSize: isSmall ? 13 : 15,
                        letterSpacing: 4,
                      ),
                    ),
                    SizedBox(height: isSmall ? 14 : 20),
                    _buildStatRow('Total Runs', state.totalRuns.toString(), Icons.replay_rounded, Colors.blue, isSmall),
                    _buildStatRow('Total Kills', state.totalKills.toString(), Icons.dangerous_rounded, Colors.red, isSmall),
                    _buildStatRow('Total Distance', '${(state.totalDistance / 1000).toStringAsFixed(1)} km', Icons.straighten_rounded, Colors.green, isSmall),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: isSmall ? 16 : 24),
          // Info card
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: EdgeInsets.all(isSmall ? 14 : 18),
              decoration: BoxDecoration(
                color: Colors.cyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.cyan.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.cyan.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.info_outline_rounded, color: Colors.cyan, size: isSmall ? 20 : 24),
                  ),
                  SizedBox(width: isSmall ? 12 : 16),
                  Expanded(
                    child: Text(
                      'Score multiplier: ${diffSettings.scoreMultiplier}x\nPlay on harder difficulties for higher scores!',
                      style: GoogleFonts.rajdhani(
                        color: Colors.grey.shade300,
                        fontSize: isSmall ? 13 : 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: isSmall ? 20 : 30),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color, bool isSmall) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmall ? 8 : 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmall ? 8 : 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: isSmall ? 20 : 24),
          ),
          SizedBox(width: isSmall ? 14 : 18),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.rajdhani(
                color: Colors.grey.shade300,
                fontSize: isSmall ? 15 : 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: isSmall ? 18 : 22,
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
        return Colors.green.shade400;
      case Difficulty.medium:
        return Colors.orange.shade400;
      case Difficulty.hard:
        return Colors.red.shade400;
    }
  }
}
