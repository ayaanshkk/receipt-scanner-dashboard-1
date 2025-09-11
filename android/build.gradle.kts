// Do NOT apply Android plugins here
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional: move build directories
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Ensure :app module is evaluated first
subprojects {
    project.evaluationDependsOn(":app")
}

// Root clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
