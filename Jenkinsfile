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
        stage('Checkout & Clean') {
            steps {
                checkout scm
                // Clean once at the start
                sh "docker run --rm -v ${WORKSPACE}:/workspace -w /workspace ${MAVEN_IMAGE} mvn clean"
            }
        }

        stage('Parallel Test Execution') {
            // We put the agent here so one container handles all parallel threads
            agent {
                docker {
                    image "${MAVEN_IMAGE}"
                    reuseNode true
                    // Added --init to reap zombie processes that cause hangs
                    args "-v /var/run/docker.sock:/var/run/docker.sock --init"
                }
            }
            parallel {
                stage('Smoke Tests') {
                    steps {
                        sh "mvn test -Dcucumber.filter.tags=@smoke -Denv=qa -Dmaven.test.failure.ignore=true -Dsurefire.reportsDirectory=target/smoke-reports"
                    }
                }
                stage('Regression Tests') {
                    steps {
                        sh "mvn test -Dcucumber.filter.tags=@regression -Denv=qa -Dmaven.test.failure.ignore=true -Dsurefire.reportsDirectory=target/regression-reports"
                    }
                }
                stage('Sanity Tests') {
                    steps {
                        sh "mvn test -Dcucumber.filter.tags=@sanity -Denv=qa -Dmaven.test.failure.ignore=true -Dsurefire.reportsDirectory=target/sanity-reports"
                    }
                }
            }
        }

        stage('Generate Allure Report') {
            steps {
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
            junit 'target/**/*-reports/*.xml'
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
