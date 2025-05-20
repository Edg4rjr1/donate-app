plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // ✅ Plugin do Firebase
    id("dev.flutter.flutter-gradle-plugin") // Deve vir por último
}

android {
    namespace = "com.example.meu_app"
    compileSdk = flutter.compileSdkVersion
      ndkVersion = "27.0.12077973"
      
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11" // ✅ Corrigido
    }

    defaultConfig {
        applicationId = "com.example.meu_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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