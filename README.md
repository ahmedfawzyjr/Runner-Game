# Neon Runner 🏃‍♂️💨

**Neon Runner** is a high-octane, endless runner game built with **Flutter** and the **Flame Engine**. Dash through a neon-lit cyberpunk world, battle zombie enemies, and rack up high scores with a dynamic combo system!

![Neon Runner Banner](https://via.placeholder.com/1200x600/0D0F23/00ACEA?text=Neon+Runner)

## 🎮 Features

*   **Endless Action**: Run as far as you can in a procedurally generated world.
*   **Combat System**: Attack enemies to clear your path and build your combo multiplier.
*   **Dynamic Difficulty**: Choose from Easy, Medium, or Hard modes. The game gets faster and more intense as you play!
*   **Visuals**: Stunning parallax backgrounds, particle effects, and camera shake feedback.
*   **Audio**: Immersive background music and sound effects.
*   **Leaderboards**: Track your high scores and stats locally.

## 🛠️ Tech Stack

*   **Framework**: [Flutter](https://flutter.dev/)
*   **Game Engine**: [Flame](https://flame-engine.org/)
*   **Language**: Dart
*   **State Management**: Built-in Flame components & Game Loop
*   **Storage**: `shared_preferences` for local data persistence

## 🚀 Getting Started

### Prerequisites

*   [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
*   An Android or iOS device/emulator.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/ahmedfawzyjr/Runner-Game.git
    cd Runner-Game
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the game:**
    ```bash
    flutter run
    ```

## 📱 Build for Release

To build the Android APK:

```bash
flutter build apk --release
```

The APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.

## 📂 Project Structure

```
lib/
├── audio/          # Audio manager and assets
├── core/           # Game configuration and state
├── data/           # Data persistence
├── game/           # Flame game components
│   ├── components/ # Player, Enemy, Parallax, HUD
│   ├── effects/    # Particles, Camera Shake
│   └── managers/   # Resource & Score Managers
└── screens/        # Flutter UI Screens (Menu, Settings, etc.)
```

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
*Built with ❤️ by Ahmed Fawzy*
