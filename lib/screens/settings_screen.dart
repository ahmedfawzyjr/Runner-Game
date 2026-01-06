import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio/audio_manager.dart';
import '../core/game_config.dart';
import '../core/game_state.dart';

/// Settings screen for sound, music, and difficulty
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
                      'SETTINGS',
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
              const SizedBox(height: 40),
              // Settings list
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  children: [
                    // Sound toggle
                    _buildSettingsTile(
                      icon: state.soundEnabled ? Icons.volume_up : Icons.volume_off,
                      title: 'Sound Effects',
                      subtitle: state.soundEnabled ? 'On' : 'Off',
                      trailing: Switch(
                        value: state.soundEnabled,
                        activeColor: Colors.cyan,
                        onChanged: (value) {
                          AudioManager().playButton();
                          setState(() {
                            AudioManager().toggleSound();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Music toggle
                    _buildSettingsTile(
                      icon: state.musicEnabled ? Icons.music_note : Icons.music_off,
                      title: 'Background Music',
                      subtitle: state.musicEnabled ? 'On' : 'Off',
                      trailing: Switch(
                        value: state.musicEnabled,
                        activeColor: Colors.cyan,
                        onChanged: (value) {
                          setState(() {
                            AudioManager().toggleMusic();
                            if (state.musicEnabled) {
                              AudioManager().playMenuMusic();
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Difficulty selector
                    _buildSettingsTile(
                      icon: Icons.speed,
                      title: 'Difficulty',
                      subtitle: GameConfig.difficulties[state.difficulty]!.name,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: Difficulty.values.map((d) {
                          final isSelected = d == state.difficulty;
                          return GestureDetector(
                            onTap: () {
                              AudioManager().playButton();
                              setState(() {
                                state.difficulty = d;
                                state.saveData();
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _getDifficultyColor(d)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getDifficultyColor(d),
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                GameConfig.difficulties[d]!.name[0],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : _getDifficultyColor(d),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Stats section
                    Text(
                      'STATISTICS',
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        color: Colors.grey.shade500,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildStatTile('Total Runs', state.totalRuns.toString()),
                    _buildStatTile('Total Kills', state.totalKills.toString()),
                    _buildStatTile(
                      'Total Distance',
                      '${(state.totalDistance / 1000).toStringAsFixed(1)} km',
                    ),
                    const SizedBox(height: 40),
                    // Reset button
                    Center(
                      child: TextButton(
                        onPressed: () => _showResetDialog(),
                        child: Text(
                          'Reset All Data',
                          style: GoogleFonts.rajdhani(
                            color: Colors.red.shade400,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyan, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.rajdhani(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.rajdhani(
              color: Colors.grey.shade400,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.orbitron(
              color: Colors.cyan,
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

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0A2E),
        title: Text(
          'Reset Data?',
          style: GoogleFonts.orbitron(color: Colors.white),
        ),
        content: Text(
          'This will reset all your scores and statistics.',
          style: GoogleFonts.rajdhani(color: Colors.grey.shade400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.rajdhani(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
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
            child: Text(
              'Reset',
              style: GoogleFonts.rajdhani(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
