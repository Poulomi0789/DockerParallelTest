pipeline {
    agent any

    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
    }

    environment {
        MAVEN_IMAGE = "maven:3.9.6-eclipse-temurin-17"
    }

    stages {
        stage('Initialize & Clean') {
            steps {
                checkout scm
                // Run clean once at the start so parallel steps don't clash
                sh "docker run --rm -v ${WORKSPACE}:/workspace -w /workspace ${MAVEN_IMAGE} mvn clean"
            }
        }

        stage('Parallel Test Execution') {
            parallel {
                stage('Smoke Tests') {
                    steps {
                        sh "docker run --rm -v ${WORKSPACE}:/workspace -w /workspace ${MAVEN_IMAGE} mvn test -Dcucumber.filter.tags=@smoke -Denv=qa -Dmaven.test.failure.ignore=true -Dsurefire.reportsDirectory=target/smoke-reports"
                    }
                }

                stage('Regression Tests') {
                    steps {
                        sh "docker run --rm -v ${WORKSPACE}:/workspace -w /workspace ${MAVEN_IMAGE} mvn test -Dcucumber.filter.tags=@regression -Denv=qa -Dmaven.test.failure.ignore=true -Dsurefire.reportsDirectory=target/regression-reports"
                    }
                }

                stage('Sanity Tests') {
                    steps {
                        sh "docker run --rm -v ${WORKSPACE}:/workspace -w /workspace ${MAVEN_IMAGE} mvn test -Dcucumber.filter.tags=@sanity -Denv=qa -Dmaven.test.failure.ignore=true -Dsurefire.reportsDirectory=target/sanity-reports"
                    }
                }
            }
        }

        /* // Uncomment this stage ONLY after installing the Allure Jenkins Plugin
        stage('Generate Allure Report') {
            steps {
                script {
                    allure includeProperties: false, 
                           jdk: '', 
                           results: [
                               [path: 'target/smoke-reports'], 
                               [path: 'target/regression-reports'], 
                               [path: 'target/sanity-reports']
                           ]
                }
            }
        }
        */
    }

    post {
        always {
            // Scans all unique report directories to give you the correct count
            junit '**/target/**/*-reports/*.xml'
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
