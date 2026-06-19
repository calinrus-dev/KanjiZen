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
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
