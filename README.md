# Couple App ❤️

A comprehensive Flutter application designed for couples to strengthen their relationship through shared memories, fun games, and meaningful daily engagement.

## 🚀 Key Highlights

### 🔒 100% Offline & Private
- **Your Data, Your Device**: Built with a strictly **offline-first** architecture.
- **Privacy Guaranteed**: Your personal memories, timeline events, and game results **never leave your phone**. 
- **No Cloud, No Tracking**: Enjoy complete peace of mind knowing your relationship data stays safely on your device.

### 🎨 Fresh & Minimal Pastel UI
- **Beautiful Design**: Enjoy a clean, calming aesthetic with a fresh pastel color palette.
- **Distraction-Free**: A minimal interface that focuses entirely on your relationship and memories.

### 📱 Daily Counter Widget
- **Days Together**: A beautiful home screen widget that tracks exactly how long you've been together.
- **Cross-Platform**: Seamlessly available on both **iOS** and **Android** home screens.

## ✨ Features

### 📅 Shared Timeline
- **Track Your Journey**: Capture and cherish important milestones and memories.
- **Visual Diary**: Scroll through a beautiful timeline of your relationship.

### 🎮 Games & Activities
Engage in fun and interactive games designed to spark conversation and laughter:
- **Act It Out**: Charades-style game for couples.
- **Coin Flip**: Settle disputes or make decisions instantly.
- **Compliment Generator**: Brighten your partner's day with sweet words.
- **Daily Challenge**: Complete small tasks together to build intimacy.
- **Finish the Sentence**: Learn more about each other with prompted sentences.
- **Love Questions**: Deep dive into meaningful conversations.
- **Spin the Wheel**: Add an element of surprise to your date nights.
- **Truth or Dare**: Classic game with a romantic twist.

### 🔔 Smart Notifications & Reminders
- **Never Miss a Special Day**: Reliable notifications ensure you never miss a **birthday**, **anniversary**, or important milestone.
- **Custom Reminders**: Set personal reminders for date nights, gifts, or just to check in.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **State Management**: [Riverpod](https://riverpod.dev/)
- **Local Database**: [Hive](https://docs.hivedb.dev/) (Offline-first architecture)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
- **Styling**: Google Fonts, Flutter Animate, Cupertino Icons
- **Native Integration**:
  - `home_widget` (Widgets)
  - `flutter_local_notifications` (Notifications)
  - `in_app_update` & `upgrader` (App Updates)

## 📂 Project Structure

```
lib/
├── core/           # App-wide constants, themes, and utilities
├── data/           # Data models and Hive boxes
├── providers/      # Riverpod state providers
├── routes/         # Navigation configuration (GoRouter)
├── screens/        # UI Screens
│   ├── feelings/   # Mood tracking (Hidden/Disabled)
│   ├── home/       # Main dashboard
│   ├── play/       # Games hub
│   │   └── games/  # Individual game implementations
│   ├── timeline/   # Memory timeline
│   └── settings/   # App configuration
├── services/       # Background services (Notifications, Updates)
└── widgets/        # Reusable UI components
```

## 🏁 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- [Android Studio](https://developer.android.com/studio) or [Xcode](https://developer.apple.com/xcode/) (for iOS).

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Saajonsayrest/Couple-App.git
   cd couple_app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Setup Logic**:
   We have included a convenient setup script to clean and build the project.
   ```bash
   chmod +x setup.sh
   ./setup.sh all  # Runs setup for both Android and iOS
   ```

### 🍎 iOS Widget Setup
iOS widgets require additional manual configuration in Xcode. Please strictly follow the guide in [IOS_WIDGET_SETUP.md](IOS_WIDGET_SETUP.md) to ensure the widget functions correctly.

## ▶️ Running the App

Run the app on your connected device or emulator:
```bash
flutter run
```

## 🤝 Contributing
This is a private project. Contributions are not currently open to the public.

## 📄 License
All rights reserved.
