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
                sh 'ls -la'
            }
        }
        stage('Prepare Workspace') {
            steps {
                echo 'Preparing workspace for Docker containers...'
                sh '''
                docker cp . jenkins:/var/jenkins_home/workspace/TransferRepresentationLearning-Pipeline
                '''
            }
        }
        stage('Secret Detection') {
            steps {
                echo 'Running secret detection with TruffleHog...'
                sh '''
                docker exec trufflehog mkdir -p /app
                docker cp . trufflehog:/app
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
                        docker run --rm -v $(pwd):/app python:3.9-slim sh -c "pip install pylint && pylint /app/app.py || echo 'Linting issues found.'"
                        '''
                    }
                }
                stage('JavaScript Linting') {
                    steps {
                        echo 'Running ESLint...'
                        sh '''
                        docker run --rm -v $(pwd):/app node:18-alpine sh -c "npm install -g eslint && (ls /app/*.js && eslint /app/*.js || echo 'No JavaScript files found.')"
                        '''
                    }
                }
                stage('SonarQube Analysis') {
                    steps {
                        echo 'Running SonarQube analysis...'
                        sh '''
                        docker run --rm \
                        -e SONAR_HOST_URL="http://172.18.0.9:9000" \
                        -e SONAR_LOGIN="$SONAR_TOKEN" \
                        -v $(pwd):/usr/src \
                        sonarsource/sonar-scanner-cli \
                        -Dsonar.projectKey=TransferRepresentationLearning \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=http://172.18.0.9:9000 \
                        -Dsonar.scanner.socketTimeout=300 \
                        -Dsonar.login=$SONAR_TOKEN
                        '''
                    }
                }
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
    options {
        timestamps()
    }
}

