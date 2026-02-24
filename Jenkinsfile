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

        stage('Clean Old Reports') {
            steps {
                sh 'rm -rf target'
            }
        }

        stage('Parallel Test Execution') {
            parallel {

                stage('Smoke Tests') {
                    agent {
                        docker {
                            image "${MAVEN_IMAGE}"
                            reuseNode true
                        }
                    }
                    steps {
                        timeout(time: 10, unit: 'MINUTES') {
                            sh """
                            mvn clean test \
                            -Dcucumber.filter.tags=@smoke \
                            -Denv=qa \
                            -Dmaven.test.failure.ignore=true
                            """
                        }
                    }
                }

                stage('Regression Tests') {
                    agent {
                        docker {
                            image "${MAVEN_IMAGE}"
                            reuseNode true
                        }
                    }
                    steps {
                        timeout(time: 10, unit: 'MINUTES') {
                            sh """
                            mvn test \
                            -Dcucumber.filter.tags=@regression \
                            -Denv=qa \
                            -Dmaven.test.failure.ignore=true
                            """
                        }
                    }
                }

                stage('Sanity Tests') {
                    agent {
                        docker {
                            image "${MAVEN_IMAGE}"
                            reuseNode true
                        }
                    }
                    steps {
                        timeout(time: 10, unit: 'MINUTES') {
                            sh """
                            mvn test \
                            -Dcucumber.filter.tags=@sanity \
                            -Denv=qa \
                            -Dmaven.test.failure.ignore=true
                            """
                        }
                    }
                }
            }
        }

        stage('Generate Allure Report') {
            steps {
                allure includeProperties: false,
                       jdk: '',
                       results: [[path: "target/allure-results"]]
            }
        }
    }

    post {

        always {
            junit 'target/surefire-reports/*.xml'
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
