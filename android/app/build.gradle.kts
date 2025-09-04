import java.util.Properties

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    id("kotlin-kapt")
    id("kotlin-parcelize")
    id("com.readdle.android.swift")
    id("dagger.hilt.android.plugin")
}

swift {
    useKapt = true
    cleanEnabled = false
    swiftLintEnabled = false
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
    }

    buildTypes {
        release {
            isDebuggable = false
            isJniDebuggable = false
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
    implementation(libs.androidx.constraintlayout)
    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)
}