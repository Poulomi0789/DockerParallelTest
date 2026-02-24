pipeline {
    agent any

    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
    }

    environment {
        PROJECT_DIR = "DockerParallelTest"
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
                sh 'ls -la'
                sh "ls -la ${PROJECT_DIR}"
            }
        }

stage('Parallel Test Execution') {
            parallel {
                stage('Smoke Tests') {
                    steps {
                        sh """
                        docker run --rm \
                        -v ${WORKSPACE}:/workspace \
                        -w /workspace \
                        ${MAVEN_IMAGE} \
                        mvn clean test \
                        -Dcucumber.filter.tags=@smoke \
                        -Denv=qa \
                        -Dmaven.test.failure.ignore=true
                        """
                    }
                }

                stage('Regression Tests') {
                    steps {
                        sh """
                        docker run --rm \
                        -v ${WORKSPACE}:/workspace \
                        -w /workspace \
                        ${MAVEN_IMAGE} \
                        mvn clean test \
                        -Dcucumber.filter.tags=@regression \
                        -Denv=qa \
                        -Dmaven.test.failure.ignore=true
                        """
                    }
                }

                stage('Sanity Tests') {
                    steps {
                        sh """
                        docker run --rm \
                        -v ${WORKSPACE}:/workspace \
                        -w /workspace \
                        ${MAVEN_IMAGE} \
                        mvn clean test \
                        -Dcucumber.filter.tags=@sanity \
                        -Denv=qa \
                        -Dmaven.test.failure.ignore=true
                        """
                    }
                }
            }
        }
        stage('Generate Allure Report') {
            steps {
                allure includeProperties: false,
                       jdk: '',
                       results: [[path: "${PROJECT_DIR}/target/allure-results"]]
            }
        }
    }

    post {

        always {
            junit '**/target/surefire-reports/*.xml'
        }

        success {
            emailext(
                subject: "✅ SUCCESS: ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                body: """
                <h2>Build Successful 🎉</h2>
                <p><b>Job:</b> ${env.JOB_NAME}</p>
                <p><b>Build:</b> #${env.BUILD_NUMBER}</p>
                <p><b>URL:</b> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                """,
                to: "poulomidas89@gmail.com",
                mimeType: 'text/html'
            )
        }

        failure {
            emailext(
                subject: "❌ FAILURE: ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                body: """
                <h2>Build Failed ❌</h2>
                <p><b>Job:</b> ${env.JOB_NAME}</p>
                <p><b>Build:</b> #${env.BUILD_NUMBER}</p>
                <p><b>Check Console:</b> <a href="${env.BUILD_URL}console">${env.BUILD_URL}console</a></p>
                """,
                to: "poulomidas89@gmail.com",
                mimeType: 'text/html'
            )
        }
    }
}

