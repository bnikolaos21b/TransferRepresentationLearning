pipeline {
    agent any
    stages {
        stage('Checkout Code') {
            steps {
                echo 'Checking out code...'
                checkout scm
            }
        }
        stage('Static Analysis') {
            steps {
                echo 'Running static analysis...'
                sh '''
                # Run Bandit and continue even if vulnerabilities are found
                bandit -r . || true
                '''
            }
        }
        stage('Dynamic Analysis') {
            steps {
                echo 'Running dynamic analysis...'
                sh '''
                # Example dynamic analysis using SQLmap
                sqlmap -u "http://mock_api:8080/example_endpoint?input=test" --batch
                '''
            }
        }
    }
    post {
        always {
            echo 'Pipeline completed. Review all results!'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}

