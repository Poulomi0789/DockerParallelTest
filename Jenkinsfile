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
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

stage('Parallel Test Execution') {
            steps {
                // Outer timeout to prevent the whole stage from hanging
                timeout(time: 15, unit: 'MINUTES') {
                    parallel(
                        "Smoke Tests": {
                            node {
                                docker.image("${MAVEN_IMAGE}").inside("-v ${WORKSPACE}:/workspace") {
                                    sh "mvn test -Dcucumber.filter.tags=@smoke -Denv=qa -Dmaven.test.failure.ignore=true -Dsurefire.reportsDirectory=target/smoke-reports; exit 0"
                                }
                            }
                        },
                        "Regression Tests": {
                            node {
                                docker.image("${MAVEN_IMAGE}").inside("-v ${WORKSPACE}:/workspace") {
                                    sh "mvn test -Dcucumber.filter.tags=@regression -Denv=qa -Dmaven.test.failure.ignore=true -Dsurefire.reportsDirectory=target/regression-reports; exit 0"
                                }
                            }
                        },
                        "Sanity Tests": {
                            node {
                                docker.image("${MAVEN_IMAGE}").inside("-v ${WORKSPACE}:/workspace") {
                                    sh "mvn test -Dcucumber.filter.tags=@sanity -Denv=qa -Dmaven.test.failure.ignore=true -Dsurefire.reportsDirectory=target/sanity-reports; exit 0"
                                }
                            }
                        }
                    )
                }
            }
        }
        stage('Generate Allure Report') {
            steps {
                // Updated to pull from the three isolated directories
                allure includeProperties: false,
                       jdk: '',
                       results: [
                           [path: "target/smoke-reports"],
                           [path: "target/regression-reports"],
                           [path: "target/sanity-reports"]
                       ]
            }
        }
    }

    post {
        always {
            // Updated to scan all sub-folders so the final count is exactly 4
            junit 'target/**/*-reports/*.xml'
        }

       success {
            emailext(
                subject: "✅ SUCCESS: ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                body: """
                <h2>Build Successful 🎉</h2>
                <p><b>Job:</b> ${env.JOB_NAME}</p>
                <p><b>Build:</b> #${env.BUILD_NUMBER}</p>
                <p><b>Allure Report:</b> <a href="${env.BUILD_URL}allure/">View Test Report</a></p>
                <p><b>Console URL:</b> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                """,
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


