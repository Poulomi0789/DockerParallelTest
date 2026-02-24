pipeline {

    agent any

    parameters {
        choice(
            name: 'TEST_ENV',
            choices: ['qa', 'stage', 'prod'],
            description: 'Select environment'
        )
    }

    environment {
        GIT_URL = 'https://github.com/Poulomi0789/DockerParallelTest.git'
        GIT_BRANCH = 'main'
        EMAIL_RECIPIENTS = 'poulomidas89@gmail.com'
        IMAGE_NAME = "api-tests:${env.BUILD_NUMBER}"
    }

    options {
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '20'))
        timeout(time: 60, unit: 'MINUTES')
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: "${GIT_BRANCH}", url: "${GIT_URL}"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${IMAGE_NAME}")
                }
            }
        }

        stage('Parallel Test Execution') {
            parallel {

                stage('Smoke Tests') {
                    steps {
                        script {
                            dockerImage.inside {
                                sh """
                                mvn clean test \
                                -Dcucumber.filter.tags="@smoke" \
                                -Denv=${params.TEST_ENV} \
                                -Dmaven.test.failure.ignore=true
                                """
                            }
                        }
                    }
                }

                stage('Regression Tests') {
                    steps {
                        script {
                            dockerImage.inside {
                                sh """
                                mvn clean test \
                                -Dcucumber.filter.tags="@regression" \
                                -Denv=${params.TEST_ENV} \
                                -Dmaven.test.failure.ignore=true
                                """
                            }
                        }
                    }
                }

                stage('Sanity Tests') {
                    steps {
                        script {
                            dockerImage.inside {
                                sh """
                                mvn clean test \
                                -Dcucumber.filter.tags="@sanity" \
                                -Denv=${params.TEST_ENV} \
                                -Dmaven.test.failure.ignore=true
                                """
                            }
                        }
                    }
                }
            }
        }

        stage('Generate Allure Report') {
            steps {
                sh 'mvn io.qameta.allure:allure-maven:report'
            }
        }

        stage('Zip Report') {
            steps {
                script {
                    if (fileExists('target/site/allure-maven-plugin')) {
                        zip zipFile: 'allure-report.zip',
                            dir: 'target/site/allure-maven-plugin',
                            archive: true
                    }
                }
            }
        }

        stage('Publish Allure') {
            steps {
                allure includeProperties: false, results: [
                    [path: 'target/allure-results']
                ]
            }
        }
    }

    post {

        always {
            archiveArtifacts artifacts: '**/*.log', allowEmptyArchive: true
            junit testResults: '**/target/surefire-reports/*.xml', allowEmptyResults: true
        }

        success {
            emailext(
                subject: "✅ API Tests Passed | ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """<h2>Build Successful 🚀</h2>
                         <b>Environment:</b> ${params.TEST_ENV}<br>
                         <b>Allure Report:</b> <a href="${env.BUILD_URL}allure">View Online</a>""",
                attachmentsPattern: 'allure-report.zip',
                mimeType: 'text/html',
                to: "${EMAIL_RECIPIENTS}"
            )
        }

        unstable {
            emailext(
                subject: "⚠️ API Tests Unstable | ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """<h2>Tests Failed ⚠️</h2>
                         <b>Environment:</b> ${params.TEST_ENV}<br>
                         <a href="${env.BUILD_URL}allure">View Report</a>""",
                attachmentsPattern: 'allure-report.zip',
                mimeType: 'text/html',
                to: "${EMAIL_RECIPIENTS}"
            )
        }

        failure {
            emailext(
                subject: "❌ Pipeline Failed | ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """<h2>Pipeline Error ❌</h2>
                         <a href="${env.BUILD_URL}console">Console Output</a>""",
                to: "${EMAIL_RECIPIENTS}"
            )
        }
    }
}
