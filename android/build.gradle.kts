buildscript {
    val kotlin_version by extra("1.9.23")
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Adjust build directories if needed
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// No need for duplicate evaluationDependsOn
// subprojects {
//     project.evaluationDependsOn(":app")
// }

// Clean task to delete build directories
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
