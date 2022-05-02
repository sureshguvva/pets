pipeline {
    agent any 
       triggers {
        pollSCM "* * * * *"
       }
    stages {
        stage('Git SCM') {
            steps {
                git 'https://github.com/sureshguvva/pets.git'
            }
        }
        stage('Build Application') { 
            steps {
                echo '=== Building Petclinic Application ==='
                sh 'mvn -B -DskipTests clean package' 
            }
        }
        stage('Test Application') {
            steps {
                echo '=== Testing Petclinic Application ==='
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        stage('Build Docker Image') {
            
            steps {
                echo '=== Building Petclinic Docker Image ==='
                script {
                    app = docker.build("sureshguvva/pets")
                }
            }
        }
        stage('Push Docker Image') {
           
            steps {
                echo '=== Pushing Petclinic Docker Image ==='
                script {
                    GIT_COMMIT_HASH = sh (script: "git log -n 1 --pretty=format:'%H'", returnStdout: true)
                    SHORT_COMMIT = "${GIT_COMMIT_HASH[0..7]}"
                    docker.withRegistry('https://registry.hub.docker.com', 'Docker') {
                        app.push("$SHORT_COMMIT")
                        app.push("latest")
                    }
                }
            }
        }
        stage('K8S Deploy') {
            steps {
                kubernetesDeploy(
                    configs: 'kubernetes/petclinic.yaml',
                    kubeconfigId: 'kubernetes',
                    enableConfigSubstitution: true
                    ) 
            }
        }
        stage('Remove local images') {
            steps {
                echo '=== Delete the local docker images ==='
                sh("docker rmi -f sureshguvva/pets:latest || :")
                sh("docker rmi -f sureshguvva/pets:$SHORT_COMMIT || :")
            }
        }
    }
}
