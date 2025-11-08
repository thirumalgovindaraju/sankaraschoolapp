allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
buildscript {
    dependencies {
        // Google services Gradle plugin
        classpath 'com.android.tools.build:gradle:7.3.0' // or your version
        classpath 'com.google.gms:google-services:4.4.0' // ADD THIS LINE
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
