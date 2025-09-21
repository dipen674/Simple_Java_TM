pipeline {
    agent none

    triggers {
        // Trigger on push to 'jenkins' branch
        githubPush()
    }

    environment {
        image = "harbor.registry.local/java_app/taskmanager"
        HARBOR_URL = 'https://harbor.registry.local'
    }

    stages {
        stage('Compile the code') {
            agent { label "production" }
            environment {
                scannerHome = tool 'sonar7.2'
            }
            steps {
                echo 'Packaging the code'
                sh 'mvn clean verify'
            }
            post {
                success {
                    echo "Archiving the Artifacts...."
                    archiveArtifacts artifacts: '**/*.war'
                }
            }
        }
        
        stage('Sonar Analysis') {
            agent { label "production" }
            environment {
                scannerHome = tool 'sonar7.2'
            }
            steps {
                withSonarQubeEnv('sonar') {
                    sh """${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=taskmanager-webapp \
                        -Dsonar.projectName=taskmanager-webapp \
                        -Dsonar.projectVersion=4.0 \
                        -Dsonar.sources=. \
                        -Dsonar.junit.reportsPath=target/surefire-reports/ \
                        -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                        -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml"""
                }
            }
        }
        
        stage('Build docker image') {
            agent { label "production" }
            steps {
                echo "Building docker image"
                sh 'docker image build -t ${image}:V_${BUILD_NUMBER} .'
            }
        }
        
        stage('Image scanning with Trivy') {
            agent { label "production" }
            steps {
                echo "Scanning image for vulnerabilities"
                script {
                    // Fail on critical vulnerabilities, warn on others
                    def trivyExitCode = sh(
                        script: "trivy image --exit-code 1 --severity CRITICAL ${image}:V_${BUILD_NUMBER}",
                        returnStatus: true
                    )
                    
                    if (trivyExitCode == 1) {
                        error "Critical vulnerabilities found! Build failed."
                    } else {
                        sh "trivy image --exit-code 0 --severity HIGH,MEDIUM,LOW ${image}:V_${BUILD_NUMBER}"
                    }
                }
            }
        }
        
        stage('Pushing docker image to Harbor') {
            agent { label "production" }
            steps {
                echo "Pushing image to Harbor registry"
                withDockerRegistry([credentialsId: 'Harborregistrycredentials', url: "${HARBOR_URL}"]) {
                    sh '''
                    docker push ${image}:V_${BUILD_NUMBER}
                    '''
                }
            }
        }

        stage('Deploy via Ansible Node') {
            agent { label 'master' }
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'ansible-ssh-key',
                        keyFileVariable: 'ANSIBLE_KEY',
                        usernameVariable: 'SSH_USERNAME'
                    )
                ]) {
                    sh """
                        ssh -i "${ANSIBLE_KEY}" -o StrictHostKeyChecking=no ${SSH_USERNAME}@192.168.56.210 '
                            rm -rf /home/vagrant/java_app_harbor || true
                            mkdir -p /home/vagrant/java_app_harbor
                            git clone --single-branch --branch harbor \
                                https://github.com/dipen674/Simple_Java_TM.git /home/vagrant/java_app_harbor
                            source /home/vagrant/myenv/bin/activate
                            cd /home/vagrant/java_app_harbor &&
                            ansible-galaxy collection install community.docker
                            cd ansible &&
                            ansible-playbook playbook.yaml -e "build_number=${BUILD_NUMBER}"
                        '
                    """
                }
            }
        }
    }
}