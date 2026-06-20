allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    afterEvaluate {
        project.extensions.findByName("android")?.let { androidExt ->
            val namespaceMethod = androidExt.javaClass.methods.find { it.name == "getNamespace" }
            if (namespaceMethod != null) {
                val namespace = namespaceMethod.invoke(androidExt)
                if (namespace == null) {
                    val setNamespaceMethod = androidExt.javaClass.methods.find { it.name == "setNamespace" }
                    setNamespaceMethod?.invoke(androidExt, project.group.toString())
                }
            }
            if (project.name != "app") {
                val compileSdkVersionMethod = androidExt.javaClass.methods.find { 
                    it.name == "compileSdkVersion" && it.parameterCount == 1 
                }
                compileSdkVersionMethod?.let { method ->
                    try {
                        method.invoke(androidExt, 34)
                    } catch (e: Exception) {
                        try {
                            method.invoke(androidExt, "android-34")
                        } catch (e2: Exception) {}
                    }
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
