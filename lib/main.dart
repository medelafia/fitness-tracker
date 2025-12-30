import 'package:fitness_tracker/pages/exercices.dart';
import 'package:fitness_tracker/pages/running_map.dart'; // Import the new file
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Tracker',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text("Fitness Tracker"),
          backgroundColor: Colors.white,
          elevation: 0
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Button 1: The New Running Map
            _buildMenuButton(
                context,
                "Start Run",
                Icons.map,
                Colors.blue,
                // This line navigates to your new RunningMapPage
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => RunningMapPage()))
            ),

            SizedBox(height: 20),

            // Button 2: The Original Exercises
            _buildMenuButton(
                context,
                "Daily Exercises",
                Icons.fitness_center,
                Colors.orange,
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => ExercicesPage()))
            ),
          ],
        ),
      ),
    );
  }

  // A helper function to make the buttons look nice and consistent
  Widget _buildMenuButton(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: 280,
      height: 70,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 5,
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 30),
        label: Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
    );
  }
}