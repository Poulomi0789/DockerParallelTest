stage('Parallel Test Execution') {
            parallel {
                stage('Smoke Tests') {
                    steps {
                        sh """
                        docker run --rm \
                        -v ${WORKSPACE}:/workspace \
                        -w /workspace \
                        ${MAVEN_IMAGE} \
                        mvn test \
                        -Dcucumber.filter.tags=@smoke \
                        -Denv=qa \
                        -Dmaven.test.failure.ignore=true \
                        -DbuildDirectory=target/smoke
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
                        mvn test \
                        -Dcucumber.filter.tags=@regression \
                        -Denv=qa \
                        -Dmaven.test.failure.ignore=true \
                        -DbuildDirectory=target/regression
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
                        mvn test \
                        -Dcucumber.filter.tags=@sanity \
                        -Denv=qa \
                        -Dmaven.test.failure.ignore=true \
                        -DbuildDirectory=target/sanity
                        """
                    }
                }
            }
        }
