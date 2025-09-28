# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Network and connectivity related classes
-keep class java.net.** { *; }
-keep class javax.net.ssl.** { *; }
-keep class org.apache.http.** { *; }
-keep class android.net.** { *; }

# HTTP client classes
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }
-keep class com.google.gson.** { *; }

# JSON serialization
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keepattributes Signature

# Keep all model classes for JSON serialization
-keep class com.example.cric_live.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Don't obfuscate anything with @Keep annotation
-keep @androidx.annotation.Keep class *
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}

# Internet connectivity and SSL
-keep class java.security.cert.** { *; }
-keep class javax.security.auth.x500.** { *; }
-keep class java.security.** { *; }

# Network security config
-keep class android.security.** { *; }