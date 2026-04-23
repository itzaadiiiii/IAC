def COLOR_MAP = (
    SUCCESS = "good",
    FAILURE = "danger"
    )



pipeline {
    agent any

    tools {
        MAVEN "mvn 3.9"
        JDK "JDK 17"

    }

    environment {}


    stages {
        stage("Git checkout"){
            steps {
                sh 'echo "Clonning code"'
                git  url: "https://github.com/hkhcoder/vprofile-project.git", branch: "atom"
            }
        }

        stage("Compile Code"){
            steps {
                sh 'mvn compile"
            }
        }


        stage("Build"){
            steps {
                sh 'mvn package'

            }
        }


        stage("Test'){
            steps {
                sh 'mvn test'
            }
        }

        stage("Build"){
            steps {
                sh 'mvn install -DskipTest=True'
            }
            post {
                success {
                    archieveArtifacts: "**/target/*.war"
                }
            }
        }


    }
}
