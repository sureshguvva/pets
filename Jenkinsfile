pipeline {
    agent any {label 'slave-1'}
       triggers {
        pollSCM "* * * * *"
       }
    stages {
        stage('Git SCM') {
            steps {
                git 'https://github.com/sureshguvva/jenkins-iac-kubernetes.git'
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
            when {
                branch 'master'
            }
            steps {
                echo '=== Building Petclinic Docker Image ==='
                script {
                    app = docker.build("yellaiah225/demo")
                }
            }
        }
        stage('Push Docker Image') {
            when {
                branch 'master'
            }
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
                    kubeconfigId: 'K8s',
                    enableConfigSubstitution: true
                    ) 
            }
        }
        stage('Remove local images') {
            steps {
                echo '=== Delete the local docker images ==='
                sh("docker rmi -f yellaiah225/demo:latest || :")
                sh("docker rmi -f yellaiah225/demo:$SHORT_COMMIT || :")
            }
        }
    }
}
