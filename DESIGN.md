# Couple App - Design Document

## 1. Core Principles
- **100% Offline-Only**: No internet connection required for core features. All data stored locally.
- **Privacy-First**: No login, no cloud syncing, no tracking. App Lock (PIN/Biometric).
- **Emotional Safety**: Warm, playful, non-cluttered UI.
- **Simplicity**: Usable in 1 minute.

## 2. Technology Stack & Architecture
- **Framework**: Flutter
- **State Management**: Flutter Riverpod (for reactive, testable state management).
- **Local Storage**: Hive (fast, secure, NoSQL key-value database for offline storage).
- **Navigation**: GoRouter (declarative routing).
- **Styling**: Custom Theme extensions for dynamic Male/Female themes.
- **Assets**: SVGs for icons, Lottie files for animations (if size permits), or code-based animations.

## 3. UI & Design Language
### Color Palette
*Dynamic Theme Strategy*:
- **Base Neutral**: Warm Off-White (`#FFF9F5`) background for paper-like feel.
- **Text**: Dark Soft Brown (`#4A4A4A`) instead of pure black for softness.
- **Male Theme (Sky Blue)**:
  - Primary: `#89CFF0` (Baby Blue)
  - Secondary: `#A0D8F1`
  - Accent: `#FFD700` (Soft Gold for awards/coins)
- **Female Theme (Baby Pink)**:
  - Primary: `#FFB7B2` (Pastel Pink)
  - Secondary: `#FFDAC1` (Peach)
  - Accent: `#FF6961` (Salmon for hearts)

### Typography
- **Headings**: rounded, friendly font (e.g., 'Nunito' or 'Varela Round').
- **Body**: Clean, legible sans-serif (e.g., 'Lato' or 'Quicksand').

### Visuals
- **Shapes**: High border radius (20px+) for cards and buttons.
- **Shadows**: Soft, diffused shadows (`BoxShadow(color: Colors.black.withOpacity(0.05), blur: 10, offset: 0, 4)`).
- **Gradients**: Very subtle usage on primary buttons.

## 4. Data Models (Offline - Hive Boxes)

### UserProfile
```dart
class UserProfile {
  String name;
  String nickname;
  String gender; // 'male' or 'female'
  DateTime birthday;
  String? avatarPath;
  DateTime relationshipStartDate;
}
```

### TimelineMemory
```dart
class TimelineMemory {
  String id;
  String title;
  String description;
  DateTime date;
  List<String> imagePaths;
  String coverImagePath;
}
```

### RelationshipLog
```dart
class RelationshipLog {
  String id;
  String type; // 'fight', 'moment', 'mood'
  DateTime timestamp;
  String? note;
  String moodEmoji;
  bool isResolved; // for fights
}
```

### Promise
```dart
class Promise {
  String id;
  String title;
  DateTime createdDate;
  String status; // 'in_progress', 'kept', 'broken'
}
```

## 5. UX Flow & Screen List

### Onboarding (First Run)
1.  **Welcome Screen**: Soft animation, "Welcome to your private space".
2.  **Profile Creation**:
    - Input Name & Nickname.
    - Select Gender (Triggers Theme Change immediately).
    - Select Birthday.
    - Upload Photo/Avatar.
3.  **Partner Setup**: Input Partner's info (Name, Nickname, Birthday, Photo).
4.  **Relationship Start**: Date picker for "When did it start?".
5.  **Home Screen**: Transition to main dashboard.

### Main Navigation (Bottom Bar)
1.  **Home**:
    - Widget: Avatars + Days Counter + Daily Quote.
    - Quick Actions: Feelings Log, Daily Mood.
    - Recent Memories preview.
2.  **Timeline**:
    - Vertical scrolling list of memories (Love Story).
    - FAB to add new Memory.
3.  **Play**:
    - Grid menu: Truth & Dare, Decide for Us, Games.
4.  **More/Menu**:
    - Calendar, Promises, Settings (App Lock, Backup, Notifications).

## 6. Component Design

### `CoupleCard`
- **Description**: Displays both avatars with a heart in between.
- **Props**: `User me`, `User partner`, `int daysTogether`.

### `MemoryCard`
- **Description**: Polaroid-style card for timeline.
- **Structure**: Image aspect ratio 3:4 or 1:1, Date badge, Title, small description snippet.

### `MoodSelector`
- **Description**: Horizontal scrollable row of animated emojis.
- **Interaction**: Tap to select, subtle scale animation on selection.

### `ThemeButton`
- **Description**: Large rounded button with soft gradient.
- **States**: Idle, Pressed (scale down 0.95), Disabled.

## 7. Folder Structure
```
lib/
  ├── core/             # Constants, Theme, Utilities
  ├── data/             # Hive Models, Repositories
  ├── providers/        # Riverpod Providers
  ├── routes/           # Navigation Map
  ├── screens/
  │   ├── onboarding/
  │   ├── home/
  │   ├── timeline/
  │   ├── play/
  │   └── more/
  ├── widgets/          # Reusable UI Components
  └── main.dart
```
