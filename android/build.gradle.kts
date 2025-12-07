buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // PERHATIKAN: Pakai Kurung () dan Petik Dua ""
        classpath("com.android.tools.build:gradle:7.3.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.7.10")
        
        // INI YANG SEBELUMNYA ERROR, SEKARANG SUDAH BENAR:
        classpath("com.google.gms:google-services:4.3.15")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = file("../build")
subprojects {
    project.buildDir = file("../build/${project.name}")
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}