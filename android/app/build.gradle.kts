plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val copyAdhanToRaw by tasks.registering(Copy::class) {
    val sourceFile = File(rootDir, "../assets/audio/adhan.mp3")
    val outDir = File(projectDir, "src/main/res/raw")

    from(sourceFile)
    into(outDir)
    rename { "adhan.mp3" }

    doFirst {
        if (!sourceFile.exists()) {
            logger.warn(
                "Adhan asset not found at ${sourceFile.absolutePath}. " +
                    "Expected assets/audio/adhan.mp3."
            )
        }
        outDir.mkdirs()
    }
}

android {
    namespace = "com.example.prayer"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.prayer"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

tasks.named("preBuild") {
    dependsOn(copyAdhanToRaw)
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
