group 'io.flutter.plugins.webview_cookie_manager'
version '1.0'

buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
    }
}

rootProject.allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url "https://storage.googleapis.com/download.flutter.io" }
    }
}

apply plugin: 'com.android.library'

android {
    namespace 'io.flutter.plugins.webview_cookie_manager'
    compileSdk 34

    namespace "io.flutter.plugins.webview_cookie_manager"

    defaultConfig {
        minSdkVersion 16
    }
    lintOptions {
        disable 'InvalidPackage'
    }

    sourceCompatibility = JavaVersion.VERSION_1_8
    targetCompatibility = JavaVersion.VERSION_1_8
}

dependencies {
    testImplementation 'junit:junit:4.13.1'
}