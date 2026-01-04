import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Configuration pour Mac (iOS Simulator ou développement local)
  static const String baseUrl = 'http://192.168.11.102:8000/api';
  
  // Si vous testez sur un appareil Android (émulateur), utilisez :
  // static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  // Si vous testez sur un appareil physique, trouvez votre IP avec 'ifconfig' et utilisez :
  // static const String baseUrl = 'http://VOTRE_IP:8000/api';

  // Récupérer tous les courses
  Future<List<CourseModel>> getCourses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/course/all'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => CourseModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching courses: $e');
    }
  }

  // Récupérer tous les workouts
  Future<List<WorkoutModel>> getWorkouts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/workout/all'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => WorkoutModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load workouts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching workouts: $e');
    }
  }

  // Insérer un nouveau course
  Future<CourseModel> insertCourse(CourseModel course) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/course/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(course.toJson()),
      );

      if (response.statusCode == 201) {
        return CourseModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to insert course: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error inserting course: $e');
    }
  }

  // Insérer un nouveau workout
  Future<WorkoutModel> insertWorkout(WorkoutModel workout) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/workout/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(workout.toJson()),
      );

      if (response.statusCode == 201) {
        return WorkoutModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to insert workout: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error inserting workout: $e');
    }
  }
}

// Modèle pour Course
class CourseModel {
  final int id;
  final double distance;
  final String activityDate;
  final String startTime;
  final String endTime;

  CourseModel({
    required this.id,
    required this.distance,
    required this.activityDate,
    required this.startTime,
    required this.endTime,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      distance: (json['distance'] as num).toDouble(),
      activityDate: json['activity_date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'distance': distance,
      'activity_date': activityDate,
      'start_time': startTime,
      'end_time': endTime,
    };
  }

  DateTime getDateTime() {
    try {
      // Parse "30-12-2025" format
      List<String> dateParts = activityDate.split('-');
      List<String> timeParts = startTime.split(':');
      
      return DateTime(
        int.parse(dateParts[2]), // year
        int.parse(dateParts[1]), // month
        int.parse(dateParts[0]), // day
        int.parse(timeParts[0]), // hour
        int.parse(timeParts[1]), // minute
      );
    } catch (e) {
      print('Error parsing date: $e');
      return DateTime.now();
    }
  }

  Duration getDuration() {
    try {
      List<String> startParts = startTime.split(':');
      List<String> endParts = endTime.split(':');
      
      int startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      int endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
      
      int durationMinutes = endMinutes - startMinutes;
      if (durationMinutes < 0) {
        durationMinutes += 24 * 60; // Si l'activité traverse minuit
      }
      
      return Duration(minutes: durationMinutes);
    } catch (e) {
      print('Error calculating duration: $e');
      return Duration.zero;
    }
  }

  int getCalories() {
    // Estimation: ~60 calories par km
    return (distance * 60).round();
  }
}

// Modèle pour Workout
class WorkoutModel {
  final int id;
  final int numberOfExercicesCompleted;
  final String activityDate;
  final String startTime;
  final String endTime;

  WorkoutModel({
    required this.id,
    required this.numberOfExercicesCompleted,
    required this.activityDate,
    required this.startTime,
    required this.endTime,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'],
      numberOfExercicesCompleted: (json['number_of_exercices_completed'] as num).toInt(),
      activityDate: json['activity_date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number_of_exercices_completed': numberOfExercicesCompleted,
      'activity_date': activityDate,
      'start_time': startTime,
      'end_time': endTime,
    };
  }

  DateTime getDateTime() {
    try {
      List<String> dateParts = activityDate.split('-');
      List<String> timeParts = startTime.split(':');
      
      return DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
    } catch (e) {
      print('Error parsing date: $e');
      return DateTime.now();
    }
  }

  Duration getDuration() {
    try {
      List<String> startParts = startTime.split(':');
      List<String> endParts = endTime.split(':');
      
      int startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      int endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
      
      int durationMinutes = endMinutes - startMinutes;
      if (durationMinutes < 0) {
        durationMinutes += 24 * 60;
      }
      
      return Duration(minutes: durationMinutes);
    } catch (e) {
      print('Error calculating duration: $e');
      return Duration.zero;
    }
  }

  int getCalories() {
    // Estimation: ~5 calories par exercice
    return numberOfExercicesCompleted * 5;
  }
}