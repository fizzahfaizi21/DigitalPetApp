import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;
  TextEditingController nameController = TextEditingController();
  bool nameSet = false;
  Timer? hungerTimer;
  Timer? winTimer;
  bool gameOver = false;
  bool wonGame = false;

  @override
  void initState() {
    super.initState();
    startHungerTimer();
  }

  void startHungerTimer() {
    hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      setState(() {
        hungerLevel = (hungerLevel + 5).clamp(0, 100);
        if (hungerLevel >= 100 && happinessLevel <= 10) {
          gameOver = true;
          hungerTimer?.cancel();
          winTimer?.cancel();
        }
      });
    });
  }

  void startWinTimer() {
    winTimer?.cancel();
    winTimer = Timer(Duration(minutes: 3), () {
      setState(() {
        if (happinessLevel > 80) {
          wonGame = true;
          hungerTimer?.cancel();
        }
      });
    });
  }

  Map<String, dynamic> getPetMood() {
    if (happinessLevel > 80) {
      return {
        'image': 'lib/assets/happy_cat.png',
        'color': Colors.green.withOpacity(0.3),
        'mood': 'Happy 😊',
      };
    } else if (happinessLevel >= 30) {
      return {
        'image': 'lib/assets/content_cat.png',
        'color': Colors.yellow.withOpacity(0.3),
        'mood': 'Neutral 😐',
      };
    } else {
      return {
        'image': 'lib/assets/sad_cat.png',
        'color': Colors.red.withOpacity(0.3),
        'mood': 'Unhappy 😢',
      };
    }
  }

  Widget _buildTextWithBackground(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20.0,
          color: Colors.black87,
        ),
      ),
    );
  }

  void _setPetName() {
    setState(() {
      petName =
          nameController.text.isNotEmpty ? nameController.text : "Your Pet";
      nameSet = true;
    });
  }

  void _playWithPet() {
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      _updateHunger();
      if (happinessLevel > 80) {
        startWinTimer();
      }
    });
  }

  void _feedPet() {
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      _updateHappiness();
    });
  }

  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    } else {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
    }
  }

  void _updateHunger() {
    hungerLevel = (hungerLevel + 5).clamp(0, 100);
    if (hungerLevel > 100) {
      hungerLevel = 100;
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    final petMood = getPetMood();

    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet'),
      ),
      backgroundColor: petMood['color'],
      body: Center(
        child: gameOver
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Game Over! Your pet has been neglected.",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red)),
                ],
              )
            : wonGame
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Congratulations! You kept your pet happy!",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (!nameSet) ...[
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: "Enter Pet Name",
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _setPetName,
                          child: Text("Set Name"),
                        ),
                      ] else ...[
                        Container(
                          width: 200,
                          height: 200,
                          child: Image.asset(
                            petMood['image'],
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 24.0),
                        _buildTextWithBackground('Name: $petName'),
                        SizedBox(height: 16.0),
                        _buildTextWithBackground(
                            'Happiness Level: $happinessLevel'),
                        SizedBox(height: 16.0),
                        _buildTextWithBackground('Hunger Level: $hungerLevel'),
                        SizedBox(height: 16.0),
                        _buildTextWithBackground('Mood: ${petMood['mood']}'),
                        SizedBox(height: 32.0),
                        ElevatedButton(
                          onPressed: _playWithPet,
                          child: Text('Play with Your Pet'),
                        ),
                        SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: _feedPet,
                          child: Text('Feed Your Pet'),
                        ),
                      ]
                    ],
                  ),
      ),
    );
  }
}
