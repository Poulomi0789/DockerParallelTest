pipeline {
    agent any

    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
    }

    environment {
        // Corrected: Removed PROJECT_DIR as your POM is in the root
        MAVEN_IMAGE = "maven:3.9.6-eclipse-temurin-17"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Verify Workspace') {
            steps {
                // This will confirm pom.xml is in the root
                sh 'ls -la'
            }
        }

        stage('Parallel Test Execution') {
            parallel {
                stage('Smoke Tests') {
                    steps {
                        sh "docker run --rm -v ${WORKSPACE}:/workspace -w /workspace ${MAVEN_IMAGE} mvn clean test -Dcucumber.filter.tags=@smoke -Denv=qa -Dmaven.test.failure.ignore=true"
                    }
                }

                stage('Regression Tests') {
                    steps {
                        sh "docker run --rm -v ${WORKSPACE}:/workspace -w /workspace ${MAVEN_IMAGE} mvn clean test -Dcucumber.filter.tags=@regression -Denv=qa -Dmaven.test.failure.ignore=true"
                    }
                }

                stage('Sanity Tests') {
                    steps {
                        sh "docker run --rm -v ${WORKSPACE}:/workspace -w /workspace ${MAVEN_IMAGE} mvn clean test -Dcucumber.filter.tags=@sanity -Denv=qa -Dmaven.test.failure.ignore=true"
                    }
                }
            }
        }

        stage('Generate Allure Report') {
            steps {
                // Corrected: Path matches your pom.xml 'target/allure-results'
                allure includeProperties: false,
                       jdk: '',
                       results: [[path: "target/allure-results"]]
            }
        }
    }

    post {
        always {
            // Found in target/surefire-reports
            junit '**/target/surefire-reports/*.xml'
        }

        success {
            emailext(
                subject: "✅ SUCCESS: ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                body: "<h2>Build Successful 🎉</h2><p>URL: <a href='${env.BUILD_URL}'>${env.BUILD_URL}</a></p>",
                to: "poulomidas89@gmail.com",
                mimeType: 'text/html'
            )
        }

        failure {
            emailext(
                subject: "❌ FAILURE: ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                body: "<h2>Build Failed ❌</h2><p>Console: <a href='${env.BUILD_URL}console'>${env.BUILD_URL}console</a></p>",
                to: "poulomidas89@gmail.com",
                mimeType: 'text/html'
            )
        }
    }
}
