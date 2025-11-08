plugins {
    id "com.android.application"
    id "kotlin-android"
    // ADD THIS LINE - Apply Google Services plugin
    id "com.google.gms.google-services"
    id "dev.flutter.flutter-gradle-plugin"
}

android {
    namespace = "com.example.sri_sankara_global_app"
    compileSdk = 34  // Update to at least 33
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.sri_sankara_global_app"
        minSdk = 23  // Update to at least 23 for FCM
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true  // ADD THIS if you have 64K+ methods
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.debug
        }
    }
}

flutter {
    source = "../.."
}

// ADD THESE DEPENDENCIES
dependencies {
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))

    // Firebase Cloud Messaging
    implementation("com.google.firebase:firebase-messaging")

    // Optional: Firebase Analytics
    implementation("com.google.firebase:firebase-analytics")
}