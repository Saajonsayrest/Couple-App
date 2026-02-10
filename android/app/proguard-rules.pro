# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Home Widget
-keep class es.antonborri.home_widget.** { *; }
-keep class com.example.couple_app.CoupleWidget { *; }

# Keep the R file (mostly for resource IDs used in RemoteViews)
-keep class com.example.couple_app.R { *; }
-keep class com.example.couple_app.R$* { *; }

# Suppress warnings for Google Play Core (deferred components not used)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Hive
-keep class io.hive.** { *; }
-keep class * extends io.hive.TypeAdapter { *; }

# Keep data models and Hive generated adapters
-keep class com.example.couple_app.data.models.** { *; }
-keep @com.hive.HiveType class * { *; }
-keep class * extends com.hive.HiveObject { *; }
-keep class * implements com.hive.TypeAdapter { *; }

# Keep timezone data
-keep class com.flutter_timezone.** { *; }
-keep class com.timezone.** { *; }
