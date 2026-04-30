# LiftLog Coach

A Flutter + Appwrite app for powerlifting coaches and remote athletes.

---

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Appwrite Cloud
- **State Management**: Riverpod
- **Navigation**: GoRouter

---

## Project Structure

```
lib/
├── main.dart
├── core/
│   ├── constants.dart       ← Appwrite config, routes, exercise list
│   ├── router.dart          ← GoRouter with role-based redirects
│   └── theme.dart           ← Dark theme (AppTheme)
├── models/
│   ├── user_model.dart
│   └── lift_model.dart
├── services/
│   ├── auth_service.dart    ← Register, login, logout, fetch clients
│   ├── lift_service.dart    ← Upload lift, fetch lifts, save feedback
│   └── storage_service.dart ← Compress + upload video to Appwrite Storage
├── providers/
│   └── app_providers.dart   ← Riverpod providers for all services + state
├── screens/
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── client/
│   │   ├── client_home_screen.dart
│   │   ├── upload_lift_screen.dart
│   │   └── lift_detail_screen.dart
│   └── coach/
│       ├── coach_home_screen.dart
│       ├── client_lift_list_screen.dart
│       └── coach_lift_detail_screen.dart
└── widgets/
    ├── lift_card.dart
    └── lift_stat_row.dart
```

---

## Appwrite Setup (Step by Step)

### 1. Create Appwrite Cloud Project
- Go to https://cloud.appwrite.io
- Create a new project
- Copy the **Project ID**

### 2. Add Flutter Platform
- In your project → **Add Platform** → **Flutter**
- Add your bundle ID (e.g. `com.yourname.liftlogcoach`)

### 3. Create Database
- Go to **Databases** → Create database
- Copy the **Database ID**

### 4. Create Collections

#### `users` collection
| Field       | Type     | Required |
|-------------|----------|----------|
| name        | String   | ✅       |
| email       | String   | ✅       |
| role        | String   | ✅       |
| coach_id    | String   | ❌       |
| created_at  | String   | ✅       |

**Permissions**: Any authenticated user can create. Users can read/update their own document.

#### `lifts` collection
| Field       | Type     | Required |
|-------------|----------|----------|
| client_id   | String   | ✅       |
| coach_id    | String   | ✅       |
| exercise    | String   | ✅       |
| weight      | Double   | ✅       |
| reps        | Integer  | ✅       |
| rpe         | Double   | ✅       |
| notes       | String   | ❌       |
| video_url   | String   | ✅       |
| feedback    | String   | ❌       |
| created_at  | String   | ✅       |

**Permissions**: Authenticated users can create. Read filtered by client_id or coach_id.

### 5. Create Storage Bucket
- Go to **Storage** → Create bucket
- Name: `lift_videos`
- Copy the **Bucket ID**
- Set max file size (e.g. 200MB)
- Allowed file extensions: `mp4, mov`

### 6. Update `constants.dart`

```dart
class AppwriteConstants {
  static const String projectId = 'YOUR_PROJECT_ID';
  static const String endpoint  = 'https://cloud.appwrite.io/v1';
  static const String databaseId = 'YOUR_DATABASE_ID';
  static const String usersCollectionId = 'users';
  static const String liftsCollectionId = 'lifts';
  static const String liftVideosBucketId = 'lift_videos';
}
```

---

## Running the App

```bash
# Install dependencies
flutter pub get

# Run on device or emulator
flutter run
```

---

## User Roles

| Role   | Can do                                              |
|--------|-----------------------------------------------------|
| Coach  | View clients, watch videos, write feedback          |
| Client | Upload lifts (video + metadata), view own feedback  |

### How clients link to coaches
When a client registers, they enter their **Coach ID** (which is the coach's Appwrite user ID). This gets saved as `coach_id` in the `users` collection.

Coaches can find their ID by checking the Appwrite console → Auth → their user entry.

> **Tip for MVP**: Expose the coach ID on the Coach Home screen so athletes can copy it easily.

---

## Notes

- Video is compressed before upload using `flutter_video_compress`
- Videos are streamed directly from Appwrite Storage via URL
- Role-based routing is handled in `router.dart` via GoRouter redirects
- Riverpod `FutureProvider.family` is used to cache lift lists per client ID
