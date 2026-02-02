pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "pranil0712/housing-app"
    }
    stages {
        stage('Build') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE:latest .'
            }
        }
        stage('Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    sh "echo $PASS | docker login -u $USER --password-stdin"
                    sh 'docker push $DOCKER_IMAGE:latest'
                }
            }
        }
        stage('Deploy') {
            steps {
                sh 'kubectl apply -f deployment.yaml --kubeconfig=/etc/rancher/k3s/k3s.yaml'
            }
        }
    }
}