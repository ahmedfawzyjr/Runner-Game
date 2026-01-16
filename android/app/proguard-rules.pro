# Flutter-specific ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Fonts
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Audioplayers
-keep class xyz.luan.audioplayers.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
