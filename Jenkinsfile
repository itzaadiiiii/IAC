def COLOR_MAP = [
    SUCCESS: "good",
    FAILURE: "danger"
]



pipeline {
    agent any

    tools {
        MAVEN 'mvn 3.9'
        JDK 'JDK 17'

    }

    environment {}


    stages {
        stage("Git checkout"){
            steps {
                sh 'echo "Cloning code"'
                git  url: 'https://github.com/hkhcoder/vprofile-project.git', branch: "atom"
            }
        }

        stage("Compile Code"){
            steps {
                sh '''
                    mvn compile
                '''
            }
        }


        stage("Package"){
            steps {
                sh '''
                    mvn package
                '''
            }
        }


        stage ("Unit Test"){
            steps {
                sh '''
                    mvn test
                '''
            }
        }

        stage("Build and Deploy"){
            steps {
                sh '''
                    mvn install
                '''
            }
            post {
                success {
                    archiveArtifacts artifacts: '**/target/*.war'
                }
            }
        }


    }
}
