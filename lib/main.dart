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
  int energyLevel = 80; // New energy level variable
  TextEditingController nameController = TextEditingController();
  bool nameSet = false;
  Timer? hungerTimer;
  Timer? energyTimer; // New timer for energy depletion
  Timer? winTimer;
  bool gameOver = false;
  bool wonGame = false;
  
  // Activity selection
  String selectedActivity = "Play";
  List<String> activities = ["Play", "Walk", "Train", "Rest", "Groom"];

  @override
  void initState() {
    super.initState();
    startHungerTimer();
    startEnergyTimer();
  }

  void startHungerTimer() {
    hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      setState(() {
        hungerLevel = (hungerLevel + 5).clamp(0, 100);
        if (hungerLevel >= 100 && happinessLevel <= 10) {
          gameOver = true;
          hungerTimer?.cancel();
          energyTimer?.cancel();
          winTimer?.cancel();
        }
      });
    });
  }
  
  void startEnergyTimer() {
    energyTimer = Timer.periodic(Duration(seconds: 45), (timer) {
      setState(() {
        energyLevel = (energyLevel - 5).clamp(0, 100);
        if (energyLevel <= 20) {
          happinessLevel = (happinessLevel - 5).clamp(0, 100);
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
          energyTimer?.cancel();
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
  
  // Build energy bar widget
  Widget _buildEnergyBar() {
    Color barColor;
    if (energyLevel > 70) {
      barColor = Colors.green;
    } else if (energyLevel > 30) {
      barColor = Colors.amber;
    } else {
      barColor = Colors.red;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextWithBackground('Energy: $energyLevel'),
        SizedBox(height: 8.0),
        Container(
          width: 250,
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: energyLevel / 100,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ),
      ],
    );
  }

  void _setPetName() {
    setState(() {
      petName =
          nameController.text.isNotEmpty ? nameController.text : "Your Pet";
      nameSet = true;
    });
  }

  // Updated to use selected activity
  void _performActivity() {
    if (energyLevel < 10) {
      // Too tired to do activities
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$petName is too tired for that activity!')),
      );
      return;
    }
    
    setState(() {
      switch (selectedActivity) {
        case "Play":
          happinessLevel = (happinessLevel + 15).clamp(0, 100);
          energyLevel = (energyLevel - 10).clamp(0, 100);
          break;
        case "Walk":
          happinessLevel = (happinessLevel + 10).clamp(0, 100);
          energyLevel = (energyLevel - 15).clamp(0, 100);
          break;
        case "Train":
          happinessLevel = (happinessLevel + 5).clamp(0, 100);
          energyLevel = (energyLevel - 20).clamp(0, 100);
          break;
        case "Rest":
          happinessLevel = (happinessLevel + 5).clamp(0, 100);
          energyLevel = (energyLevel + 25).clamp(0, 100);
          break;
        case "Groom":
          happinessLevel = (happinessLevel + 8).clamp(0, 100);
          energyLevel = (energyLevel - 5).clamp(0, 100);
          break;
      }
      
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
      // Feeding also slightly increases energy
      energyLevel = (energyLevel + 5).clamp(0, 100);
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
                        SizedBox(height: 16.0),
                        // New Energy Bar
                        _buildEnergyBar(),
                        SizedBox(height: 32.0),
                        
                        // Activity Selection Section
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300)
                          ),
                          child: Column(
                            children: [
                              Text('Choose an Activity', 
                                style: TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold
                                )
                              ),
                              SizedBox(height: 12),
                              DropdownButton<String>(
                                value: selectedActivity,
                                isExpanded: true,
                                items: activities.map((String activity) {
                                  return DropdownMenuItem<String>(
                                    value: activity,
                                    child: Text(activity),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedActivity = newValue!;
                                  });
                                },
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _performActivity,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                ),
                                child: Text('Do Activity'),
                              ),
                            ],
                          ),
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
  
  @override
  void dispose() {
    hungerTimer?.cancel();
    energyTimer?.cancel();
    winTimer?.cancel();
    super.dispose();
  }
}