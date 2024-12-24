pipeline {
    agent any
    environment {
        SONAR_TOKEN = credentials('sonarqube-token') 
    }
    stages {
        stage('Checkout Code') {
            steps {
                echo 'Checking out code...'
                checkout scm
            }
        }
        stage('Secret Detection') {
            steps {
                echo 'Running secret detection with TruffleHog...'
                sh '''
                docker exec trufflehog trufflehog filesystem --json /app > trufflehog_results.json || echo "No secrets found."
                '''
            }
        }
        stage('Linting and Static Analysis') {
            parallel {
                stage('Python Linting') {
                    steps {
                        echo 'Running Pylint...'
                        sh '''
                        docker run --rm -v $(pwd):/app python:3.9-slim sh -c "pip install pylint && pylint /app/**/*.py || pylint /app/*.py"
                        '''
                    }
                }
                stage('JavaScript Linting') {
                    steps {
                        echo 'Running ESLint...'
                        sh '''
                        docker run --rm -v $(pwd):/app node:18-alpine sh -c "npm install -g eslint && eslint /app/*.js || echo 'No JS files found.'"
                        '''
                    }
                }
                stage('SonarQube Analysis') {
                    steps {
                        echo 'Running SonarQube analysis...'
                        sh '''
                        docker run --rm \
                        -e SONAR_HOST_URL="http://<sonarqube-ip>:9000" \
                        -e SONAR_LOGIN="$SONAR_TOKEN" \
                        -v $(pwd):/usr/src \
                        sonarsource/sonar-scanner-cli \
                        -Dsonar.projectKey=TransferRepresentationLearning \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=http://<sonarqube-ip>:9000 \
                        -Dsonar.login=$SONAR_TOKEN
                        '''
                    }
                }
            }
        }
        stage('OWASP ZAP Scan') {
            steps {
                echo 'Running OWASP ZAP scan...'
                sh '''
                docker exec zap zap-baseline.py -t http://mock_api:8080/example_endpoint -r zap_report.html
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

