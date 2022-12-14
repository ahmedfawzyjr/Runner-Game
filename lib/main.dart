import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ],
  );
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyGame(),
    );
  }
}

class MyGame extends StatefulWidget {
  const MyGame({
    super.key,
  });

  @override
  State<MyGame> createState() => _MyGameState();
}

class _MyGameState extends State<MyGame> {
  bool isGameStarted = false;

  late Timer backgroundTimer;
  late Timer playerTimer;
  late Timer zombieTimer;
  late Timer spawnZombieTimer;

  List<double> parallaxEffect = [
    0,
    0,
    0,
    0,
    0,
    0,
  ];

  int score = 0;

  // Player Variables

  int numberOfPlayerImages = 0;
  double playerHeight = 0.8;
  double height = 0;
  double initialHeight = 0.8;
  double time = 0;
  double speedJump = 4;
  bool isJumping = false;
  double playerX = -0.8;

  List<Zombie> zombieList = [
    Zombie(),
  ];

  // This Method For Moving The Background

  void moveBackground() {
    isGameStarted = true;

    backgroundTimer = Timer.periodic(
      const Duration(
        milliseconds: 20,
      ),
      (
        timer,
      ) {
        detectCollision();
        setState(
          () {
            parallaxEffect[1] -= 3.5;
            parallaxEffect[2] -= 4;
            parallaxEffect[3] -= 4.5;
            parallaxEffect[4] -= 5.3;
            parallaxEffect[5] -= 4;
          },
        );
      },
    );
  }

  // This Method For Showing The Animation of Moving for The Player

  void movePlayer() {
    playerTimer = Timer.periodic(
      const Duration(
        milliseconds: 50,
      ),
      (
        timer,
      ) {
        score++;
        setState(
          () {
            numberOfPlayerImages++;
            if (numberOfPlayerImages == 9) {
              numberOfPlayerImages = 1;
            }
          },
        );
      },
    );
  }

  void jump() {
    isJumping = true;
    time = 0;
    height = 0;
    initialHeight = playerHeight;
    Timer.periodic(
      const Duration(
        milliseconds: 50,
      ),
      (
        timer,
      ) {
        time += 0.05;
        height = -4.0 * time * time + speedJump * time;
        playerHeight = initialHeight - height;
        if (playerHeight >= 0.8) {
          playerHeight = 0.8;
          isJumping = false;
          timer.cancel();
        }
      },
    );
  }

  void moveZombie() {
    zombieTimer = Timer.periodic(
      const Duration(
        milliseconds: 50,
      ),
      (
        timer,
      ) {
        for (int i = 0; i < zombieList.length; i++) {
          setState(
            () {
              zombieList[i].numberOfImage++;
              if (zombieList[i].numberOfImage > 7) {
                zombieList[i].numberOfImage = 1;
              }
              zombieList[i].zombieX -= 0.02;
              if (zombieList[i].zombieX < -1.2) {
                zombieList.removeAt(
                  i,
                );
              }
            },
          );
        }
      },
    );
  }

  void spawnZombie() {
    spawnZombieTimer = Timer.periodic(
      const Duration(
        milliseconds: 2800,
      ),
      (
        timer,
      ) {
        zombieList.add(
          Zombie(),
        );
      },
    );
  }

  void detectCollision() {
    for (int i = 0; i < zombieList.length; i++) {
      if ((playerX - zombieList[i].zombieX).abs() < 0.05) {
        // This If Condition Meaning That The Player is Not Jumping Over

        if (playerHeight > 0.6) {
          backgroundTimer.cancel();
          playerTimer.cancel();
          zombieTimer.cancel();
          spawnZombieTimer.cancel();
          zombieList.clear();
          showDialog(
            context: context,
            builder: (
              context,
            ) =>
                Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  20,
                ),
              ),
              child: SizedBox(
                height: 200,
                width: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'G A M E O V E R',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                      ),
                    ),
                    Text(
                      'Your Score $score',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        moveBackground();
                        movePlayer();
                        moveZombie();
                        spawnZombie();
                        score = 0;
                        isGameStarted = true;
                        isJumping = false;
                        Navigator.of(
                          context,
                        ).pop();
                      },
                      child: const Text(
                        'START AGAIN',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isGameStarted) {
                  moveBackground();
                  movePlayer();
                  moveZombie();
                  spawnZombie();
                } else {
                  if (!isJumping) {
                    jump();
                  }
                }
              },
              child: Stack(
                children: [
                  Stack(
                    children: List.generate(
                      6,
                      (
                        index,
                      ) =>
                          Positioned.fill(
                        left: parallaxEffect[index],
                        child: Image(
                          fit: BoxFit.contain,
                          repeat: ImageRepeat.repeat,
                          image: AssetImage(
                            'assets/images/plx-${index + 1}.png',
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment(
                      playerX,
                      playerHeight,
                    ),
                    child: SizedBox(
                      height: 80,
                      width: 80,
                      child: Image.asset(
                        'assets/images/Run__00$numberOfPlayerImages.png',
                      ),
                    ),
                  ),
                  Stack(
                    children: List.generate(
                      zombieList.length,
                      (
                        index,
                      ) =>
                          Container(
                        alignment: Alignment(
                          zombieList[index].zombieX,
                          zombieList[index].zombieHeight,
                        ),
                        child: SizedBox(
                          height: 80,
                          width: 80,
                          child: Image.asset(
                            'assets/images/Zombiz${zombieList[index].numberOfImage}.png',
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    alignment: const Alignment(
                      0,
                      -1,
                    ),
                    child: Text(
                      score.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Zombie {
  int numberOfImage = 1;
  double zombieHeight = 0.8;
  double zombieX = 1.1;
}
