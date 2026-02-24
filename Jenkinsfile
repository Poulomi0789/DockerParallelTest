pipeline {
    agent {
        docker {
            image 'maven:3.9.9-eclipse-temurin-17'
            // Using a named volume 'maven-repo' is more reliable on Windows Docker
            args '-v maven-repo:/root/.m2'
        }
    }

    parameters {
        choice(
            name: 'TEST_ENV',
            choices: ['qa', 'stage', 'prod'],
            description: 'Select environment to run Karate tests'
        )
    }

    environment {
        GIT_URL = 'https://github.com/Poulomi0789/KarateAdvanced.git'
        GIT_BRANCH = 'main'
        EMAIL_RECIPIENTS = 'poulomidas89@gmail.com'
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

        stage('Run Karate Tests') {
            steps {
                // 'retry' helps with flaky network issues during maven downloads
                retry(2) {
                    sh """
                    mvn clean test \
                    -Dkarate.env=${params.TEST_ENV} \
                    -Dmaven.test.failure.ignore=true
                    """
                }
            }
        }

        stage('Generate & Zip Report') {
            steps {
                // 1. Generate the report site
                sh 'mvn io.qameta.allure:allure-maven:report'
                
                // 2. Use native Jenkins zip (requires Pipeline Utility Steps plugin)
                script {
                    if (fileExists('target/site/allure-maven-plugin')) {
                        zip zipFile: 'allure-report.zip', 
                            dir: 'target/site/allure-maven-plugin', 
                            archive: true
                    } else {
                        echo "Warning: Allure report directory not found, skipping zip."
                    }
                }
            }
        }

        stage('Publish to Jenkins') {
            steps {
                // Captures results from multiple possible locations to ensure the chart populates
                allure includeProperties: false, results: [
                    [path: 'target/allure-results'],
                    [path: 'target/karate-reports']
                ]
            }
        }
    }

    post {
        always {
           // This will look everywhere in the workspace for any .log files
            archiveArtifacts artifacts: '**/*.log', allowEmptyArchive: true
            junit testResults: '**/target/surefire-reports/*.xml', allowEmptyResults: true
        }

        success {
            emailext(
                subject: "✅ Karate Tests Passed | ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """<h2>Build Successful 🚀</h2>
                         <b>Environment:</b> ${params.TEST_ENV} <br>
                         <b>Allure Report:</b> <a href="${env.BUILD_URL}allure">View Online</a>""",
                attachmentsPattern: 'allure-report.zip',
                mimeType: 'text/html',
                to: "${EMAIL_RECIPIENTS}"
            )
        }

        unstable {
            // This triggers if tests fail but the pipeline finished
            emailext(
                subject: "⚠️ Karate Tests Unstable | ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """<h2>Tests Failed ⚠️</h2>
                         <b>Environment:</b> ${params.TEST_ENV} <br>
                         <b>Check Allure for details:</b> <a href="${env.BUILD_URL}allure">View Report</a>""",
                attachmentsPattern: 'allure-report.zip',
                mimeType: 'text/html',
                to: "${EMAIL_RECIPIENTS}"
            )
        }

        failure {
            emailext(
                subject: "❌ Karate Build Failed | ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """<h2>Pipeline Error ❌</h2>
                         <b>The build crashed before finishing.</b><br>
                         <a href="${env.BUILD_URL}console">Console Output</a>""",
                to: "${EMAIL_RECIPIENTS}"
            )
        }
    }
}


