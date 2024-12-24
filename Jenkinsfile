pipeline {
    agent any
    environment {
        SONAR_TOKEN = credentials('sonarqube-token') // Προσθέστε το SonarQube token στα Jenkins credentials
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
                docker run --rm -v $(pwd):/app trufflesecurity/trufflehog:latest filesystem --json /app > trufflehog_results.json
                '''
                publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: '.', reportFiles: 'trufflehog_results.json', reportName: 'TruffleHog Report'])
            }
        }
        stage('Linting and Static Analysis') {
            parallel {
                stage('Python Linting') {
                    steps {
                        echo 'Running Pylint...'
                        sh '''
                        docker run --rm -v $(pwd):/app python:3.9-slim sh -c "pip install pylint && python -m pylint /app/**/*.py"
                        '''
                    }
                }
                stage('JavaScript Linting') {
                    steps {
                        echo 'Running ESLint...'
                        sh '''
                        docker run --rm -v $(pwd):/app node:18-alpine sh -c "npm install -g eslint && eslint /app/**/*.js"
                        '''
                    }
                }
                stage('SonarQube Analysis') {
                    steps {
                        echo 'Running SonarQube analysis...'
                        sh '''
                        docker run --rm \
                        -e SONAR_HOST_URL="http://sonarqube:9000" \
                        -e SONAR_LOGIN="$SONAR_TOKEN" \
                        -v $(pwd):/usr/src \
                        sonarsource/sonar-scanner-cli \
                        -Dsonar.projectKey=TransferRepresentationLearning \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=http://sonarqube:9000 \
                        -Dsonar.login=$SONAR_TOKEN
                        '''
                    }
                }
            }
        }
        stage('Nmap Vulnerability Scan') {
            steps {
                echo 'Running Nmap vulnerability scan...'
                sh '''
                docker exec nmap nmap -sV mock_api -oN nmap_scan_results.txt
                '''
                publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: '.', reportFiles: 'nmap_scan_results.txt', reportName: 'Nmap Scan Report'])
            }
        }
        stage('Docker Image Vulnerability Scan') {
            steps {
                echo 'Running Docker image vulnerability scan with Trivy...'
                sh '''
                docker exec trivy trivy image --no-progress jenkins:latest > trivy_scan_results.txt || true
                docker exec trivy trivy image --no-progress mock_api:latest >> trivy_scan_results.txt || true
                '''
                publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: '.', reportFiles: 'trivy_scan_results.txt', reportName: 'Trivy Scan Report'])
            }
        }
        stage('SQL Injection Scan') {
            steps {
                echo 'Running SQLmap for SQL injection vulnerabilities...'
                sh '''
                docker run --rm -v $(pwd):/app sqlmap/sqlmap -m /app/endpoints.txt --batch --output-dir=/app/sqlmap_results
                '''
                publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'sqlmap_results', reportFiles: 'report.html', reportName: 'SQLmap Report'])
            }
        }
        stage('OWASP ZAP Scan') {
            steps {
                echo 'Running OWASP ZAP scan...'
                sh '''
                docker run --rm -v $(pwd):/zap/wrk/:rw zaproxy/zap-stable zap-baseline.py -t http://mock_api:8080/example_endpoint -r zap_report.html
                '''
                publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: '.', reportFiles: 'zap_report.html', reportName: 'OWASP ZAP Report'])
            }
        }
    }
    post {
        always {
            echo 'Pipeline completed. Review all results!'
            // Μπορείς να προσθέσεις περισσότερα reports αν χρειάζεται
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}

