########### ML Kit ###########
# Keep ML Kit Text Recognition classes
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.devanagari.** { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }

# Keep all other ML Kit packages
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

########### Flutter ###########
# Keep Flutter generated classes
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }

########### AndroidX ###########
# Keep Android annotations
-keep class androidx.annotation.** { *; }

########### Google Play Core ###########
# Keep Play Core classes (SplitInstall, SplitCompat, etc.)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

########### Google Play Services Tasks ###########
# Keep GMS Tasks APIs (OnSuccessListener, OnFailureListener, Task)
-keep class com.google.android.gms.tasks.** { *; }
-dontwarn com.google.android.gms.tasks.**
