import java.util.Properties

// Top-level build file where you can add configuration options common to all sub-projects/modules.
plugins {
    alias(libs.plugins.android.application) apply false
    alias(libs.plugins.kotlin.android) apply false
}

buildscript {
    repositories {
        // Repositories needed to find the plugin artifact itself
        google()
        mavenCentral() // The Readdle plugin artifact is here
    }
    dependencies {
        // Declare the plugin classpath dependency using its real coordinates
        // Use the actual artifact name 'gradle' and the correct version '1.4.5'
        classpath(libs.gradle)
        classpath(libs.hilt.android.gradle.plugin)
    }
}
