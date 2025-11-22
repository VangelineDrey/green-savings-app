buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Versi plugin Google Services — bisa disesuaikan jika perlu
        classpath("com.google.gms:google-services:4.3.15")
    }
}

plugins {
    // Jika ada plugin project-level lain, biarkan tetap di sini
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
