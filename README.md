# 🏃 Neon Runner

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Flame](https://img.shields.io/badge/Flame_Engine-FF6F00?style=for-the-badge&logo=firebase&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**A high-octane, endless runner game built with Flutter and the Flame Engine.**

*Dash through a neon-lit cyberpunk world, battle zombie enemies, and rack up high scores with a dynamic combo system!*

</div>

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🎮 **Endless Action** | Run as far as you can in a procedurally generated cyberpunk world |
| ⚔️ **Combat System** | Attack enemies to clear your path and build your combo multiplier |
| 🎯 **Kill Score Popups** | Dynamic animated score popups with combo indicators |
| 📚 **Interactive Tutorial** | Learn the game mechanics with a guided tutorial system |
| 🎚️ **Dynamic Difficulty** | Choose from Easy, Medium, or Hard modes |
| 🎨 **Stunning Visuals** | Parallax backgrounds, particle effects, and camera shake |
| 🔊 **Immersive Audio** | Background music and sound effects with volume controls |
| 🏆 **Leaderboards** | Track your high scores and stats locally |
| 👤 **Character Selection** | Choose your runner from multiple characters |

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) 3.x
- **Game Engine**: [Flame](https://flame-engine.org/) 1.x
- **Language**: Dart
- **State Management**: Built-in Flame components & Game Loop
- **Storage**: `shared_preferences` for local data persistence

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.0 or higher)
- Android Studio / VS Code with Flutter extensions
- An Android or iOS device/emulator

### Installation

```bash
# Clone the repository
git clone https://github.com/ahmedfawzyjr/Runner-Game.git
cd Runner-Game

# Install dependencies
flutter pub get

# Run the game
flutter run
```

---

## 📱 Build for Release

### Android APK

```bash
flutter build apk --release
```

The APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.

### Android App Bundle (AAB)

```bash
flutter build appbundle --release
```

### 🌐 Web Build (Vercel Hosting)

```bash
flutter build web --release
```

The web build will be located at `build/web`. Deploy this folder to Vercel or any static hosting platform.

---

## 📂 Project Structure

```
lib/
├── audio/              # Audio manager for music & SFX
├── core/               # Game configuration and state
│   ├── game_config.dart
│   ├── game_state.dart
│   └── difficulty.dart
├── data/               # Data persistence layer
├── game/               # Flame game components
│   ├── components/     # Player, Enemy, Parallax, HUD
│   ├── effects/        # Particles, Camera Shake, Kill Popups
│   ├── managers/       # Resource & Score Managers
│   ├── sprites/        # Sprite sheets and animations
│   └── neon_runner_game.dart
├── screens/            # Flutter UI Screens
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── game_screen.dart
│   ├── game_over_screen.dart
│   ├── settings_screen.dart
│   ├── leaderboard_screen.dart
│   └── character_select_screen.dart
└── main.dart           # App entry point
```

---

## 🎮 How to Play

| Control | Action |
|---------|--------|
| **Tap** | Jump |
| **Double Tap** | Double Jump |
| **Swipe Up** | Jump |
| **Swipe Down** | Slide |
| **Tap (near enemy)** | Attack |

**Tips:**
- 🎯 Chain kills to build your combo multiplier
- ⚡ Higher combos = more points per kill
- 🏃 The game speeds up as your score increases
- 💀 Avoid obstacles or lose health

---

## 🤝 Contributing

Contributions are welcome! Feel free to:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Built with ❤️ by [Ahmed Fawzy](https://github.com/ahmedfawzyjr)**

⭐ Star this repo if you like the game!

</div>
