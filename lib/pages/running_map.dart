import 'dart:async';
import 'dart:math';
import 'dart:ui'; // For Path metrics
import 'package:fitness_tracker/pages/exercices.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

class RunningMapPage extends StatefulWidget {
  @override
  State<RunningMapPage> createState() => _RunningMapPageState();
}

class _RunningMapPageState extends State<RunningMapPage> with SingleTickerProviderStateMixin {
  // --- Configuration ---
  final double totalDistanceNeeded = 100.0; // The route is 100 meters long

  // --- Game State ---
  double distanceCovered = 0.0; // In meters
  int stepsTaken = 0;
  int score = 0;
  double progress = 0.0; // 0.0 to 1.0
  bool isFinished = false;
  String statusMessage = "Start walking!";

  // Stars Logic (at 20%, 50%, 80% of the path)
  List<double> starLocations = [0.2, 0.5, 0.8];
  List<bool> starCollected = [false, false, false];

  // --- Sensors ---
  StreamSubscription<Position>? _positionStream;
  StreamSubscription<UserAccelerometerEvent>? _accelStream;
  Position? _lastPosition;
  bool _canStep = true; // For debounce

  @override
  void initState() {
    super.initState();
    _initSensors();
  }

  Future<void> _initSensors() async {
    // 1. Setup GPS
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => statusMessage = "GPS Disabled");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    // Get initial position
    _lastPosition = await Geolocator.getCurrentPosition();

    // Start GPS Stream (Updates Distance)
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 2, // Update every 2 meters to reduce jitter
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      _onLocationUpdate(position);
    });

    // 2. Start Accelerometer Stream (Updates Steps)
    _accelStream = userAccelerometerEventStream().listen((event) {
      _onAccelerometerEvent(event);
    });
  }

  // --- Logic: GPS drives Progress ---
  void _onLocationUpdate(Position newPos) {
    if (isFinished || _lastPosition == null) return;

    // Calculate distance walked since last update
    double dist = Geolocator.distanceBetween(
        _lastPosition!.latitude, _lastPosition!.longitude,
        newPos.latitude, newPos.longitude
    );

    setState(() {
      _lastPosition = newPos;
      distanceCovered += dist;

      // Update Progress (0.0 to 1.0)
      progress = distanceCovered / totalDistanceNeeded;

      _checkGameLogic();
    });
  }

  // --- Logic: Accelerometer counts Steps ---
  void _onAccelerometerEvent(UserAccelerometerEvent event) {
    if (isFinished) return;

    // Detect Shake (Step)
    double magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    if (magnitude > 2.0 && _canStep) {
      setState(() {
        stepsTaken++;
      });
      _canStep = false;
      Future.delayed(Duration(milliseconds: 400), () {
        if (mounted) _canStep = true;
      });
    }
  }

  // --- Logic: Game Rules ---
  void _checkGameLogic() {
    if (progress >= 1.0) {
      progress = 1.0;
      isFinished = true;
      _positionStream?.cancel();
      _accelStream?.cancel();
      _showWinDialog();
    }

    // Check Star Collisions
    for (int i = 0; i < starLocations.length; i++) {
      if (!starCollected[i] && progress >= starLocations[i]) {
        starCollected[i] = true;
        score += 10;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("⭐ Star Collected!"),
                duration: Duration(milliseconds: 500),
                backgroundColor: Colors.orange
            )
        );
      }
    }
  }

  // --- Simulation for Testing at Desk ---
  void _simulateMovement() {
    setState(() {
      distanceCovered += 5.0; // Fake walking 5 meters
      progress = distanceCovered / totalDistanceNeeded;
      stepsTaken += 7; // Fake taking 7 steps
      _checkGameLogic();
    });
  }

  void _showWinDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text("🎉 Route Complete!"),
          content: Text("You walked ${distanceCovered.toStringAsFixed(1)}m.\nSteps: $stepsTaken\nScore: $score"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text("Go Home", style: TextStyle(color: Colors.grey))
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ExercicesPage()));
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
    _positionStream?.cancel();
    _accelStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Hybrid Run Tracker"),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(children: [
                  Text("DISTANCE", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text("${distanceCovered.toStringAsFixed(1)} m", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ]),
                Column(children: [
                  Text("STEPS", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text("$stepsTaken", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ]),
                Column(children: [
                  Text("SCORE", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text("$score", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.orange)),
                ]),
              ],
            ),
          ),

          // The Map Visualization (Same Visuals)
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

          // Simulation Button
          Container(
            padding: EdgeInsets.all(10),
            child: ElevatedButton.icon(
              icon: Icon(Icons.bug_report),
              label: Text("Simulate 5m Walk (Testing)"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800], foregroundColor: Colors.white),
              onPressed: _simulateMovement,
            ),
          )
        ],
      ),
    );
  }
}

// --- VISUALS: Kept exactly the same as before ---
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

    Path path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.9);
    path.quadraticBezierTo(size.width * 0.1, size.height * 0.5, size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.5, size.width * 0.8, size.height * 0.1);

    canvas.drawPath(path, trackPaint);

    PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric metric in pathMetrics) {
      Path extracted = metric.extractPath(0.0, metric.length * progress);
      canvas.drawPath(extracted, activePaint);
    }

    for (int i = 0; i < starLocations.length; i++) {
      if (starCollected[i]) continue;
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