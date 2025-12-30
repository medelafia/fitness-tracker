import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:fitness_tracker/pages/exercices.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class RunningMapPage extends StatefulWidget {
  @override
  State<RunningMapPage> createState() => _RunningMapPageState();
}

class _RunningMapPageState extends State<RunningMapPage> with SingleTickerProviderStateMixin {
  final int totalStepsNeeded = 50;

  // Game State
  int stepsTaken = 0;
  int score = 0;
  double progress = 0.0; // 0.0 to 1.0 (0% to 100%)
  bool isFinished = false;

  // Stars Logic (at 20%, 50%, 80% of the path)
  List<double> starLocations = [0.2, 0.5, 0.8];
  List<bool> starCollected = [false, false, false];

  // Sensor
  StreamSubscription? _streamSubscription;
  bool _canStep = true; // Debounce to prevent double counting

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    // We use UserAccelerometer (ignores gravity) for better shake detection
    _streamSubscription = userAccelerometerEventStream().listen((event) {
      if (isFinished) return;

      // Simple Step Detection:
      // If the phone moves sharply up/down or forward (Magnitude > 2.0)
      double magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      if (magnitude > 2.0 && _canStep) {
        _onStepTaken();

        // Prevent counting one shake as 10 steps
        _canStep = false;
        Future.delayed(Duration(milliseconds: 400), () {
          if (mounted) _canStep = true;
        });
      }
    });
  }

  void _onStepTaken() {
    setState(() {
      stepsTaken++;
      progress = stepsTaken / totalStepsNeeded;

      if (progress >= 1.0) {
        progress = 1.0;
        isFinished = true;
        _streamSubscription?.cancel();
        _showWinDialog();
      }

      // Check Star Collisions
      for (int i = 0; i < starLocations.length; i++) {
        if (!starCollected[i] && progress >= starLocations[i]) {
          starCollected[i] = true;
          score += 10; // +10 points per star
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("⭐ Star Collected! +10 points"), duration: Duration(milliseconds: 500), backgroundColor: Colors.orange,)
          );
        }
      }
    });
  }

  // --- UPDATED DIALOG FUNCTION ---
  void _showWinDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text("🎉 Route Complete!"),
          content: Text("You finished the route in $stepsTaken steps.\nTotal Score: $score"),
          actions: [
            // Option 1: Go Home
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to Home Page
                },
                child: Text("Go Home", style: TextStyle(color: Colors.grey))
            ),

            // Option 2: Daily Exercises (Highlighted)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // Navigate to Exercises Page (Replacement ensures back button works logically)
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ExercicesPage())
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text("Daily Exercises", style: TextStyle(color: Colors.white)),
            )
          ],
        )
    );
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Virtual Run"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Header Stats
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(children: [
                  Text("STEPS", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text("$stepsTaken / $totalStepsNeeded", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                ]),
                Column(children: [
                  Text("SCORE", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text("$score", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.orange)),
                ]),
              ],
            ),
          ),

          // The Map Visualization
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: CustomPaint(
                    painter: RoutePainter(
                        progress: progress,
                        starLocations: starLocations,
                        starCollected: starCollected
                    ),
                  ),
                );
              },
            ),
          ),

          // Instruction / Debug
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              isFinished ? "Finished!" : "Run in place (or shake phone) to move!",
              style: TextStyle(color: Colors.grey),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.directions_run),
        onPressed: () {
          // Allow manual tapping for testing at desk without shaking
          _onStepTaken();
        },
      ),
    );
  }
}

// This class draws the curved line, the stars, and the player
class RoutePainter extends CustomPainter {
  final double progress;
  final List<double> starLocations;
  final List<bool> starCollected;

  RoutePainter({required this.progress, required this.starLocations, required this.starCollected});

  @override
  void paint(Canvas canvas, Size size) {
    Paint trackPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20.0
      ..strokeCap = StrokeCap.round;

    Paint activePaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20.0
      ..strokeCap = StrokeCap.round;

    // 1. Define the Path (A winding "S" shape)
    Path path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.9); // Start bottom left
    path.quadraticBezierTo(
        size.width * 0.1, size.height * 0.5, // Control point 1
        size.width * 0.5, size.height * 0.5  // Mid point
    );
    path.quadraticBezierTo(
        size.width * 0.9, size.height * 0.5, // Control point 2
        size.width * 0.8, size.height * 0.1  // End top right
    );

    // 2. Draw the grey background track
    canvas.drawPath(path, trackPaint);

    // 3. Draw the "Active" track (orange) following player
    // We use PathMetrics to extract a sub-path based on percentage
    PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric metric in pathMetrics) {
      Path extracted = metric.extractPath(0.0, metric.length * progress);
      canvas.drawPath(extracted, activePaint);
    }

    // 4. Draw Stars along the path
    for (int i = 0; i < starLocations.length; i++) {
      if (starCollected[i]) continue; // Don't draw collected stars

      for (PathMetric metric in pathMetrics) {
        Tangent? tangent = metric.getTangentForOffset(metric.length * starLocations[i]);
        if (tangent != null) {
          TextPainter textPainter = TextPainter(
            text: TextSpan(text: "⭐", style: TextStyle(fontSize: 24)),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(canvas, tangent.position - Offset(12, 12));
        }
      }
    }

    // 5. Draw Goal Flag at the end
    for (PathMetric metric in pathMetrics) {
      Tangent? endPos = metric.getTangentForOffset(metric.length);
      if (endPos != null) {
        TextPainter textPainter = TextPainter(
          text: TextSpan(text: "🏁", style: TextStyle(fontSize: 30)),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, endPos.position - Offset(15, 30));
      }
    }

    // 6. Draw Player (The Runner)
    // Find exact X,Y for current progress
    for (PathMetric metric in pathMetrics) {
      Tangent? pos = metric.getTangentForOffset(metric.length * progress);
      if (pos != null) {
        canvas.drawCircle(pos.position, 15, Paint()..color = Colors.blue);
        canvas.drawCircle(pos.position, 12, Paint()..color = Colors.white);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}