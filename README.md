Fitness Tracker

Overview

A mobile fitness tracking application developed using Flutter, with a FastAPI backend for storing workout history. The app utilizes the device's accelerometer and gyroscope to detect movements during workouts, such as squats, and tracks distance traveled during courses.

Features

- *Workout Tracking:* Detects movements during workouts, such as squats, using the device's accelerometer and gyroscope.
- *Course Tracking:* Tracks distance traveled during courses, using GPS and device sensors.
- *History:* Stores workout and course history, including date, time, and performance metrics.
- *Data Visualization:* Displays workout and course data in a user-friendly format.

Technologies Used

- *Frontend:* Flutter (Mobile App)
- *Backend:* FastAPI (Python)
- *Database:* SQLite
- *Sensors:* Accelerometer, Gyroscope, GPS

System Architecture

The system consists of two main components:

1. *Flutter Mobile App:* Handles user interactions, tracks workouts and courses, and sends data to the backend for storage.
2. *FastAPI Backend:* Receives data from the mobile app, stores it in the database, and provides API endpoints for data retrieval.

How it Works

1. *Workout Tracking:* The mobile app uses the device's accelerometer and gyroscope to detect movements during workouts.
2. *Course Tracking:* The mobile app uses GPS and device sensors to track distance traveled during courses.
3. *Data Storage:* The mobile app sends workout and course data to the backend for storage.
4. *Data Retrieval:* The mobile app retrieves workout and course history from the backend for display.


Contributions are welcome! If you'd like to contribute to this project, please fork the repository and submit a pull request.
