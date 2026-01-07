// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/game_state.dart';
import '../game/managers/resource_manager.dart';
import '../audio/audio_manager.dart';

/// Premium character selection screen with all 5 characters visible
class CharacterSelectScreen extends StatefulWidget {
  final VoidCallback onSelected;

  const CharacterSelectScreen({super.key, required this.onSelected});

  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen>
    with TickerProviderStateMixin {
  late String selectedColor;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  static const List<CharacterOption> characters = [
    CharacterOption('beige', 'Beige', Color(0xFFF5DEB3), Color(0xFFD2B48C)),
    CharacterOption('green', 'Green', Color(0xFF90EE90), Color(0xFF228B22)),
    CharacterOption('pink', 'Pink', Color(0xFFFFB6C1), Color(0xFFFF69B4)),
    CharacterOption('purple', 'Purple', Color(0xFFDDA0DD), Color(0xFF9932CC)),
    CharacterOption('yellow', 'Yellow', Color(0xFFFFFF00), Color(0xFFFFD700)),
  ];

  @override
  void initState() {
    super.initState();
    selectedColor = GameState().selectedCharacter;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _selectCharacter(String color) async {
    setState(() => selectedColor = color);
    AudioManager().playSelect();

    await GameState().setCharacter(color);
    await ResourceManager().changeCharacterColor(color);
  }

  void _confirmSelection() {
    AudioManager().playButton();
    widget.onSelected();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final isSmallScreen = size.height < 700;

    // Calculate card size to fit all 5 in a row on landscape, or 3+2 on portrait
    final availableWidth = size.width - 40; // padding
    final cardsPerRow = isLandscape ? 5 : 3;
    final spacing = isLandscape ? 12.0 : 16.0;
    final cardWidth = ((availableWidth - (spacing * (cardsPerRow - 1))) / cardsPerRow).clamp(70.0, 140.0);
    final cardHeight = cardWidth * 1.25;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
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
                  vertical: isSmallScreen ? 12 : 20,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
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
                            'SELECT CHARACTER',
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

              // Character grid - centered and scrollable
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: isSmallScreen ? 10 : 20,
                    ),
                    child: Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      alignment: WrapAlignment.center,
                      children: characters.map((char) {
                        final isSelected = char.id == selectedColor;
                        return _CharacterCard(
                          character: char,
                          isSelected: isSelected,
                          pulseAnimation: isSelected ? _pulseAnimation : null,
                          glowAnimation: _glowAnimation,
                          onTap: () => _selectCharacter(char.id),
                          width: cardWidth,
                          height: cardHeight,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // Confirm button
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                child: AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return GestureDetector(
                      onTap: _confirmSelection,
                      child: Container(
                        width: (size.width * 0.6).clamp(200.0, 320.0),
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 14 : 18,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.cyan.shade400, Colors.purple.shade400],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyan.withOpacity(0.4 * _glowAnimation.value),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'CONFIRM',
                            style: GoogleFonts.orbitron(
                              fontSize: isSmallScreen ? 16 : 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final CharacterOption character;
  final bool isSelected;
  final Animation<double>? pulseAnimation;
  final Animation<double> glowAnimation;
  final VoidCallback onTap;
  final double width;
  final double height;

  const _CharacterCard({
    required this.character,
    required this.isSelected,
    this.pulseAnimation,
    required this.glowAnimation,
    required this.onTap,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = width * 0.4;
    final circleSize = width * 0.55;

    Widget card = GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: glowAnimation,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  character.primaryColor.withOpacity(0.25),
                  character.secondaryColor.withOpacity(0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.cyan : Colors.white24,
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.cyan.withOpacity(0.5 * glowAnimation.value),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    color: character.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: character.secondaryColor,
                      width: 2.5,
                    ),
                  ),
                  child: Icon(
                    Icons.person,
                    size: iconSize,
                    color: character.secondaryColor,
                  ),
                ),
                SizedBox(height: height * 0.08),
                Text(
                  character.name,
                  style: GoogleFonts.rajdhani(
                    fontSize: width * 0.14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.cyan,
                      size: width * 0.15,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );

    if (pulseAnimation != null) {
      return AnimatedBuilder(
        animation: pulseAnimation!,
        builder: (context, child) {
          return Transform.scale(
            scale: pulseAnimation!.value,
            child: card,
          );
        },
      );
    }

    return card;
  }
}

class CharacterOption {
  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;

  const CharacterOption(this.id, this.name, this.primaryColor, this.secondaryColor);
}
