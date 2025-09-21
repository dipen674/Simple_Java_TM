pipeline {
    agent { label 'production' }

    triggers {
        githubPush()
    }

    environment {
        image = "harbor.registry.local/java_app/taskmanager"
        HARBOR_URL = 'https://harbor.registry.local'
        ANSIBLE_HOST = '192.168.56.210'
        NEXUS_URL = '192.168.56.6:8081'
    }

    stages {
        stage('Compile the code') {
            environment {
                scannerHome = tool 'sonar7.2'
            }
            steps {
                echo 'Packaging the code'
                sh 'mvn clean package -DskipTests=true'
            }
            post {
                success {
                    echo "Archiving the Artifacts...."
                    archiveArtifacts artifacts: '**/*.war'
                }
            }
        }
        
        stage('Upload Artifact to Nexus') {
            steps {
                echo "Uploading artifact to Nexus repository"
                nexusArtifactUploader(
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    nexusUrl: "${NEXUS_URL}",
                    groupId: 'QA',
                    version: "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}",
                    repository: 'Javaapp_TM',
                    credentialsId: 'nexus-credentials',
                    artifacts: [
                        [artifactId: 'taskmanager-webapp',
                         classifier: '',
                         file: 'target/taskmanager-webapp.war',
                         type: 'war']
                    ]
                )
            }
        }
        
        stage('Sonar Analysis') {
            environment {
                scannerHome = tool 'sonar7.2'
            }
            steps {
                withSonarQubeEnv('sonar') {
                    sh """${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=taskmanager-webapp \
                        -Dsonar.projectName=taskmanager-webapp \
                        -Dsonar.projectVersion=4.0 \
                        -Dsonar.sources=src/main/java,src/main/webapp \
                        -Dsonar.java.binaries=target/classes \
                        -Dsonar.java.libraries=**/*.jar \
                        -Dsonar.scm.provider=git"""
                }
            }
        }
                
        stage('Build docker image') {
            steps {
                echo "Building docker image"
                sh 'docker image build -t ${image}:V_${BUILD_NUMBER} .'
            }
        }
        
        stage('Image scanning with Trivy') {
            steps {
                echo "Scanning image for vulnerabilities"
                script {
                    sh 'mkdir -p trivy-reports'
                    def trivyExitCode = sh(
                        script: "trivy image --exit-code 1 --severity CRITICAL --output trivy-reports/trivy-report-${BUILD_NUMBER}.txt ${image}:V_${BUILD_NUMBER}",
                        returnStatus: true
                    )
                    if (trivyExitCode == 1) {
                        error "Critical vulnerabilities found! Check trivy-reports/trivy-report-${BUILD_NUMBER}.txt"
                    } else {
                        sh "trivy image --format json --output trivy-reports/trivy-report-all-${BUILD_NUMBER}.json ${image}:V_${BUILD_NUMBER}"
                    }
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'trivy-reports/*', fingerprint: true
                }
            }
        }
        
        stage('Pushing docker image to Harbor') {
            steps {
                echo "Pushing image to Harbor registry"
                withDockerRegistry([credentialsId: 'Harborregistrycredentials', url: "${HARBOR_URL}"]) {
                    sh 'docker push ${image}:V_${BUILD_NUMBER}'
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
                        ssh -i "${ANSIBLE_KEY}" ${SSH_USERNAME}@${ANSIBLE_HOST} '
                            test -f /home/vagrant/myenv/bin/activate || exit 1
                            source /home/vagrant/myenv/bin/activate
                            cd /home/vagrant/java_app_harbor || { mkdir -p /home/vagrant/java_app_harbor; git clone --single-branch --branch harbor https://github.com/dipen674/Simple_Java_TM.git /home/vagrant/java_app_harbor; }
                            cd /home/vagrant/java_app_harbor && git pull
                            ansible-galaxy collection install community.docker
                            cd ansible && ansible-playbook playbook.yaml -e "build_number=${BUILD_NUMBER}"
                        '
                    """
                }
            }
        }
    }
}