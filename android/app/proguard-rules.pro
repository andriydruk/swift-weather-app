# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.kts.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Swift JNI bridge - native code accesses fields and methods by name
-keep class com.readdle.weather.core.** { *; }

# Readdle Swift codegen annotations must survive R8
-keep class com.readdle.codegen.anotation.** { *; }

# Keep all Readdle Swift runtime classes used by the bridge
-keep class com.readdle.swift.** { *; }
