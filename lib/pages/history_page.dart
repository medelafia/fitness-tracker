import 'package:flutter/material.dart';
import 'package:fitness_tracker/services/api_service.dart';

class Activity {
  final String type;
  final DateTime date;
  final double distance;
  final Duration duration;
  final int calories;
  final String? exerciseName;
  final int? exerciseCount;

  Activity({
    required this.type,
    required this.date,
    this.distance = 0,
    required this.duration,
    required this.calories,
    this.exerciseName,
    this.exerciseCount,
  });
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ApiService _apiService = ApiService();
  List<Activity> activities = [];
  bool isLoading = true;
  String? errorMessage;

  String selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _apiService.getCourses(),
        _apiService.getWorkouts(),
      ]);

      List<CourseModel> courses = results[0] as List<CourseModel>;
      List<WorkoutModel> workouts = results[1] as List<WorkoutModel>;

      List<Activity> loadedActivities = [];

      for (var course in courses) {
        loadedActivities.add(Activity(
          type: "Run",
          date: course.getDateTime(),
          distance: course.distance,
          duration: course.getDuration(),
          calories: course.getCalories(),
        ));
      }

      for (var workout in workouts) {
        loadedActivities.add(Activity(
          type: "Exercise",
          date: workout.getDateTime(),
          duration: workout.getDuration(),
          calories: workout.getCalories(),
          exerciseName: "Workout",
          exerciseCount: workout.numberOfExercicesCompleted,
        ));
      }

      loadedActivities.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        activities = loadedActivities;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  List<Activity> get filteredActivities {
    if (selectedFilter == "Runs") {
      return activities.where((a) => a.type == "Run").toList();
    } else if (selectedFilter == "Exercises") {
      return activities.where((a) => a.type == "Exercise").toList();
    }
    return activities;
  }

  int get totalActivities => activities.length;
  double get totalDistance => activities
      .where((a) => a.type == "Run")
      .fold(0.0, (sum, a) => sum + a.distance);
  int get totalCalories => activities.fold(0, (sum, a) => sum + a.calories);

  String formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return '${months[date.month - 1]} ${date.day}, ${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("My History"),
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadActivities,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : errorMessage != null
          ? _buildErrorState()
          : Column(
        children: [
          _buildStatsSection(),
          _buildFilterChips(),
          Expanded(
            child: filteredActivities.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredActivities.length,
              itemBuilder: (context, index) {
                return _buildActivityCard(filteredActivities[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red),
          SizedBox(height: 16),
          Text(
            "Failed to load data",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage ?? "Unknown error",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadActivities,
            icon: Icon(Icons.refresh),
            label: Text("Retry"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: EdgeInsets.all(20),
      color: Colors.green,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Activities", totalActivities.toString(), Icons.timeline),
          _buildStatItem("Distance", "${totalDistance.toStringAsFixed(1)} km", Icons.straighten),
          _buildStatItem("Calories", totalCalories.toString(), Icons.local_fire_department),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFilterChip("All"),
          SizedBox(width: 10),
          _buildFilterChip("Runs"),
          SizedBox(width: 10),
          _buildFilterChip("Exercises"),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(Activity activity) {
    final durationStr = "${activity.duration.inMinutes}:${(activity.duration.inSeconds % 60).toString().padLeft(2, '0')}";

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: activity.type == "Run" ? Colors.blue : Colors.orange,
                  child: Icon(
                    activity.type == "Run" ? Icons.directions_run : Icons.fitness_center,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.type == "Run"
                            ? "Running"
                            : "${activity.exerciseName} (${activity.exerciseCount} exercises)",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatDate(activity.date),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (activity.type == "Run")
                  _buildDetailItem(Icons.straighten, "${activity.distance.toStringAsFixed(2)} km", "Distance"),
                _buildDetailItem(Icons.timer, durationStr, "Duration"),
                _buildDetailItem(Icons.local_fire_department, "${activity.calories} kcal", "Calories"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.green, size: 20),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No activities yet",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            "Start a run or workout to see your history!",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}