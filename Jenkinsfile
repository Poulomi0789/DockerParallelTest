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
                        -v \$WORKSPACE:/workspace \
                        -w /workspace/\$PROJECT_DIR \
                        \$MAVEN_IMAGE \
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
                        -v \$WORKSPACE:/workspace \
                        -w /workspace/\$PROJECT_DIR \
                        \$MAVEN_IMAGE \
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
                        -v \$WORKSPACE:/workspace \
                        -w /workspace/\$PROJECT_DIR \
                        \$MAVEN_IMAGE \
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
                sh "ls -la ${PROJECT_DIR}/target"
            }
        }
    }

    post {
        always {
            junit '**/target/surefire-reports/*.xml'
        }
    }
}
