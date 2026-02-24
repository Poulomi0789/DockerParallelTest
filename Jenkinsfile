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
        EMAIL_RECIPIENTS = 'poulomidas89@gmail.com'
        MAVEN_IMAGE = 'maven:3.9.6-eclipse-temurin-17'
    }

    options {
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '20'))
        timeout(time: 60, unit: 'MINUTES')
    }

    stages {

        stage('Verify Workspace') {
            steps {
                sh 'ls -la'
            }
        }

        stage('Parallel Test Execution') {
            parallel {

                stage('Smoke Tests') {
                    steps {
                        sh """
                        docker run --rm \
                        -v ${WORKSPACE}:/app \
                        -w /app \
                        ${MAVEN_IMAGE} \
                        mvn clean test \
                        -Dcucumber.filter.tags="@smoke" \
                        -Denv=${params.TEST_ENV} \
                        -Dmaven.test.failure.ignore=true
                        """
                    }
                }

                stage('Regression Tests') {
                    steps {
                        sh """
                        docker run --rm \
                        -v ${WORKSPACE}:/app \
                        -w /app \
                        ${MAVEN_IMAGE} \
                        mvn clean test \
                        -Dcucumber.filter.tags="@regression" \
                        -Denv=${params.TEST_ENV} \
                        -Dmaven.test.failure.ignore=true
                        """
                    }
                }

                stage('Sanity Tests') {
                    steps {
                        sh """
                        docker run --rm \
                        -v ${WORKSPACE}:/app \
                        -w /app \
                        ${MAVEN_IMAGE} \
                        mvn clean test \
                        -Dcucumber.filter.tags="@sanity" \
                        -Denv=${params.TEST_ENV} \
                        -Dmaven.test.failure.ignore=true
                        """
                    }
                }
            }
        }

        stage('Generate Allure Report') {
            steps {
                sh """
                docker run --rm \
                -v ${WORKSPACE}:/app \
                -w /app \
                ${MAVEN_IMAGE} \
                mvn io.qameta.allure:allure-maven:report
                """
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
            junit testResults: '**/target/surefire-reports/*.xml', allowEmptyResults: true
        }

        success {
            emailext(
                subject: "✅ Tests Passed | ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                <h2>Build Successful 🚀</h2>
                <b>Environment:</b> ${params.TEST_ENV}<br><br>
                <a href="${env.BUILD_URL}allure">View Allure Report</a>
                """,
                mimeType: 'text/html',
                to: "${EMAIL_RECIPIENTS}"
            )
        }

        failure {
            emailext(
                subject: "❌ Pipeline Failed | ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                <h2>Pipeline Failed ❌</h2>
                <a href="${env.BUILD_URL}console">View Console Output</a>
                """,
                mimeType: 'text/html',
                to: "${EMAIL_RECIPIENTS}"
            )
        }
    }
}
