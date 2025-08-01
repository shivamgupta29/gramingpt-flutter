// Note: This file is located at android/app/build.gradle.kts
//
// IMPORTANT: Please replace the ENTIRE content of your file with this code.
// The error is caused by old lines like "compileSdk = flutter.compileSdkVersion".
// Those lines MUST be deleted and replaced with the specific numbers below (e.g., "compileSdk = 35").

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.gramingpt_new"
    // Use the specific SDK version required by the plugins.
    compileSdk = 35

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.gramingpt_new"
        minSdk = 21
        // Target SDK must also be updated to match the compile SDK.
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
