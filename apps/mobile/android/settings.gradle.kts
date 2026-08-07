pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        // GitHub Actions (CI=true): use official repos — Aliyun often 502s from US runners
        // and Gradle then disables the mirror, cascading into classpath resolve failures.
        // Local China: prefer Aliyun first via SUNDAY_USE_ALIYUN_MAVEN=1 (default when not CI).
        val useAliyun =
            System.getenv("SUNDAY_USE_ALIYUN_MAVEN") == "1" ||
                (System.getenv("CI") == null && System.getenv("SUNDAY_USE_ALIYUN_MAVEN") != "0")
        if (useAliyun) {
            maven(url = "https://maven.aliyun.com/repository/google")
            maven(url = "https://maven.aliyun.com/repository/central")
            maven(url = "https://maven.aliyun.com/repository/gradle-plugin")
        }
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")
