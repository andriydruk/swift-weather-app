import java.util.Properties

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
    id("kotlin-kapt")
    id("kotlin-parcelize")
    id("com.readdle.android.swift")
    id("dagger.hilt.android.plugin")
}

swift {
    useKapt = true
    cleanEnabled = false
    apiLevel = 29
}

val props = Properties()
val localPropertiesFile = rootProject.file("local.properties") // Or just file("local.properties") if in the same module's build script
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { props.load(it) }
}
val openWeatherAPIKey: String = props.getProperty("API_KEY") ?: ""

android {
    namespace = "com.readdle.weather"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.readdle.weather"
        minSdk = 29
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"

        buildConfigField("String", "WEATHER_API_KEY", "\"${openWeatherAPIKey}\"")

        packaging {
            jniLibs.excludes += "lib/**/libswift_Differentiation.so"
            jniLibs.excludes += "lib/**/libswift_Volatile.so"
            jniLibs.excludes += "lib/**/libswiftDifferentiationUnittest.so"
            jniLibs.excludes += "lib/**/libswiftDistributed.so"
            jniLibs.excludes += "lib/**/libswiftObservation.so"
            jniLibs.excludes += "lib/**/libswiftRegexBuilder.so"
            jniLibs.excludes += "lib/**/libswiftRemoteMirror.so"
            jniLibs.excludes += "lib/**/libswiftRuntimeUnittest.so"
            jniLibs.excludes += "lib/**/libswiftStdlibUnittest.so"
            jniLibs.excludes += "lib/**/libswiftSwiftPrivate.so"
            jniLibs.excludes += "lib/**/libswiftSwiftPrivateLibcExtras.so"
            jniLibs.excludes += "lib/**/libswiftSwiftPrivateThreadExtras.so"
            jniLibs.excludes += "lib/**/libswiftSwiftReflectionTest.so"
            jniLibs.excludes += "lib/**/libXCTest.so"
        }
    }

    ndkVersion = "27.3.13750724"

    signingConfigs {
        create("ciRelease") {
            // Default debug keystore location on CI and local
            storeFile = file(System.getProperty("user.home") + "/.android/debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("ciRelease")
            isDebuggable = false
            isJniDebuggable = false
            isMinifyEnabled = true
            isShrinkResources = true
            ndk {
                // Optimize for fast build times by not building all ABIs for debuggable variants.
                //noinspection ChromeOsAbiSupport
                abiFilters += listOf("arm64-v8a")
            }
        }
        debug {
            isDebuggable = true
            isJniDebuggable = true
            ndk {
                // Optimize for fast build times by not building all ABIs for debuggable variants.
                //noinspection ChromeOsAbiSupport
                abiFilters += listOf("arm64-v8a")
            }
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildFeatures {
        buildConfig = true
        compose = true
    }
}

kapt {
    arguments {
        arg("com.readdle.codegen.package", """{
            "moduleName": "WeatherCoreBridgeGenerated",
            "importPackages": ["AnyCodable", "JavaCoder", "WeatherCore", "WeatherCoreBridge"]
        }""")
    }
}

dependencies {
    kapt(libs.hilt.compiler)
    kapt(libs.swift.codegen)

    implementation(libs.hilt.android)
    implementation(libs.swift.codegen.annotations)
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.appcompat)
    implementation(libs.material)
    implementation(libs.androidx.activity)
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.constraintlayout)

    // Compose
    implementation(platform(libs.compose.bom))
    implementation(libs.compose.ui)
    implementation(libs.compose.ui.graphics)
    implementation(libs.compose.ui.tooling.preview)
    implementation(libs.compose.material3)
    implementation(libs.compose.material.icons)
    implementation(libs.compose.foundation)
    debugImplementation(libs.compose.ui.tooling)

    // Lifecycle + ViewModel Compose
    implementation(libs.lifecycle.runtime.compose)
    implementation(libs.lifecycle.viewmodel.compose)

    // Navigation Compose
    implementation(libs.navigation.compose)
    implementation(libs.hilt.navigation.compose)

    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)
}