plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.receipt_scanner"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.example.receipt_scanner"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ Core ML Kit
    implementation("com.google.mlkit:text-recognition:16.0.0")
    implementation("com.google.mlkit:vision-common:17.3.0")
    implementation("com.google.mlkit:common:17.3.0")

    // ✅ Google Play Services Tasks (for success/failure callbacks)
    implementation("com.google.android.gms:play-services-tasks:18.0.2")

    // ✅ Google Play Core (needed for SplitInstall + deferred components)
    implementation("com.google.android.play:core:1.10.3")

    // ✅ ML Kit optional language models (fixes missing *RecognizerOptions classes)
    implementation("com.google.mlkit:text-recognition-chinese:16.0.0")
    implementation("com.google.mlkit:text-recognition-devanagari:16.0.0")
    implementation("com.google.mlkit:text-recognition-japanese:16.0.0")
    implementation("com.google.mlkit:text-recognition-korean:16.0.0")
}

