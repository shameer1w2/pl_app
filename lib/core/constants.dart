// lib/core/constants.dart

class AppwriteConstants {
  // ── Replace these with your actual Appwrite project values ──
  static const String projectId = '69ccb495002cd9cd86fc';
  static const String endpoint = 'https://cloud.appwrite.io/v1';

  static const String databaseId = '69ce25770021361609b5';
  static const String usersCollectionId = 'users';
  static const String liftsCollectionId = 'lifts';

  static const String liftVideosBucketId = '69ce28f2000a9b0e01d8';
}

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // Client
  static const String clientHome = '/client/home';
  static const String uploadLift = '/client/upload';
  static const String clientLiftHistory = '/client/history';
  static const String clientLiftDetail = '/client/lift/:id';

  // Coach
  static const String coachHome = '/coach/home';
  static const String clientLiftList = '/coach/client/:clientId';
  static const String coachLiftDetail = '/coach/lift/:id';
}

class Exercises {
  static const List<String> list = [
    'Squat',
    'Bench Press',
    'Deadlift',
    'Overhead Press',
    'Romanian Deadlift',
    'Front Squat',
    'Close Grip Bench',
    'Sumo Deadlift',
    'Pause Squat',
    'Pause Bench',
  ];
}

class UserRoles {
  static const String coach = 'coach';
  static const String client = 'client';
}
