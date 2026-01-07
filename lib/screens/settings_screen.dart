// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio/audio_manager.dart';
import '../core/game_config.dart';
import '../core/game_state.dart';

/// Premium settings screen with larger elements
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = GameState();
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final isLandscape = size.width > size.height;
    final horizontalPadding = isLandscape ? 60.0 : 24.0;

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
                            'SETTINGS',
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
              SizedBox(height: isSmallScreen ? 16 : 28),
              // Settings list
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  children: [
                    // Sound toggle
                    _buildSettingsTile(
                      icon: state.soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                      iconColor: Colors.cyan,
                      title: 'Sound Effects',
                      subtitle: state.soundEnabled ? 'On' : 'Off',
                      trailing: _buildSwitch(
                        value: state.soundEnabled,
                        onChanged: (value) {
                          AudioManager().playButton();
                          setState(() => AudioManager().toggleSound());
                        },
                      ),
                      isSmall: isSmallScreen,
                    ),
                    SizedBox(height: isSmallScreen ? 14 : 20),
                    // Music toggle
                    _buildSettingsTile(
                      icon: state.musicEnabled ? Icons.music_note_rounded : Icons.music_off_rounded,
                      iconColor: Colors.purple,
                      title: 'Background Music',
                      subtitle: state.musicEnabled ? 'On' : 'Off',
                      trailing: _buildSwitch(
                        value: state.musicEnabled,
                        onChanged: (value) {
                          setState(() {
                            AudioManager().toggleMusic();
                            if (state.musicEnabled) {
                              AudioManager().playMenuMusic();
                            }
                          });
                        },
                      ),
                      isSmall: isSmallScreen,
                    ),
                    SizedBox(height: isSmallScreen ? 14 : 20),
                    // Difficulty selector
                    _buildDifficultySelector(state, isSmallScreen),
                    SizedBox(height: isSmallScreen ? 28 : 40),
                    // Stats section
                    _buildStatsSection(state, isSmallScreen),
                    SizedBox(height: isSmallScreen ? 24 : 36),
                    // Reset button
                    Center(
                      child: GestureDetector(
                        onTap: () => _showResetDialog(isSmallScreen),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 24 : 32,
                            vertical: isSmallScreen ? 12 : 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: isSmallScreen ? 20 : 24),
                              SizedBox(width: isSmallScreen ? 8 : 12),
                              Text(
                                'Reset All Data',
                                style: GoogleFonts.rajdhani(
                                  color: Colors.red.shade400,
                                  fontSize: isSmallScreen ? 15 : 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitch({required bool value, required ValueChanged<bool> onChanged}) {
    return Transform.scale(
      scale: 1.1,
      child: Switch(
        value: value,
        activeColor: Colors.cyan,
        activeTrackColor: Colors.cyan.withOpacity(0.3),
        inactiveThumbColor: Colors.grey.shade600,
        inactiveTrackColor: Colors.grey.withOpacity(0.2),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDifficultySelector(GameState state, bool isSmall) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(isSmall ? 18 : 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmall ? 10 : 12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.speed_rounded, color: Colors.orange, size: isSmall ? 24 : 28),
                  ),
                  SizedBox(width: isSmall ? 14 : 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Difficulty',
                          style: GoogleFonts.rajdhani(
                            color: Colors.white,
                            fontSize: isSmall ? 18 : 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          GameConfig.difficulties[state.difficulty]!.description,
                          style: GoogleFonts.rajdhani(
                            color: Colors.grey.shade500,
                            fontSize: isSmall ? 13 : 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmall ? 18 : 24),
              // Difficulty buttons - LARGER
              Row(
                children: Difficulty.values.map((d) {
                  final isSelected = d == state.difficulty;
                  final color = _getDifficultyColor(d);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: GestureDetector(
                        onTap: () {
                          AudioManager().playSelect();
                          setState(() {
                            state.difficulty = d;
                            state.saveData();
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            vertical: isSmall ? 14 : 18,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? color : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: color,
                              width: isSelected ? 2.5 : 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withOpacity(0.4),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              GameConfig.difficulties[d]!.name,
                              style: GoogleFonts.orbitron(
                                color: isSelected ? Colors.white : color,
                                fontWeight: FontWeight.bold,
                                fontSize: isSmall ? 13 : 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    required bool isSmall,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(isSmall ? 16 : 22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isSmall ? 10 : 12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: isSmall ? 24 : 28),
              ),
              SizedBox(width: isSmall ? 14 : 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: isSmall ? 17 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.rajdhani(
                        color: Colors.grey.shade500,
                        fontSize: isSmall ? 13 : 15,
                      ),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(GameState state, bool isSmall) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(isSmall ? 18 : 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'STATISTICS',
                style: GoogleFonts.orbitron(
                  fontSize: isSmall ? 14 : 16,
                  color: Colors.grey.shade500,
                  letterSpacing: 4,
                ),
              ),
              SizedBox(height: isSmall ? 16 : 24),
              _buildStatTile('Total Runs', state.totalRuns.toString(), Icons.replay_rounded, Colors.blue, isSmall),
              _buildStatTile('Total Kills', state.totalKills.toString(), Icons.dangerous_rounded, Colors.red, isSmall),
              _buildStatTile('Total Distance', '${(state.totalDistance / 1000).toStringAsFixed(1)} km', Icons.straighten_rounded, Colors.green, isSmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color color, bool isSmall) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmall ? 8 : 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmall ? 8 : 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: isSmall ? 18 : 22),
          ),
          SizedBox(width: isSmall ? 12 : 16),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.rajdhani(
                color: Colors.grey.shade300,
                fontSize: isSmall ? 15 : 18,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.orbitron(
              color: Colors.cyan,
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

  void _showResetDialog(bool isSmall) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.all(isSmall ? 20 : 28),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red.shade400, size: isSmall ? 24 : 28),
            SizedBox(width: isSmall ? 10 : 14),
            Text(
              'Reset Data?',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: isSmall ? 18 : 22,
              ),
            ),
          ],
        ),
        content: Text(
          'This will permanently delete all your scores and statistics. This action cannot be undone.',
          style: GoogleFonts.rajdhani(
            color: Colors.grey.shade400,
            fontSize: isSmall ? 15 : 17,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.rajdhani(
                color: Colors.grey.shade400,
                fontSize: isSmall ? 15 : 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              final state = GameState();
              state.highScores = {
                Difficulty.easy: 0,
                Difficulty.medium: 0,
                Difficulty.hard: 0,
              };
              state.totalKills = 0;
              state.totalRuns = 0;
              state.totalDistance = 0;
              await state.saveData();
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: isSmall ? 18 : 24, vertical: isSmall ? 10 : 14),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.5)),
              ),
              child: Text(
                'Reset',
                style: GoogleFonts.rajdhani(
                  color: Colors.red.shade400,
                  fontSize: isSmall ? 15 : 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
