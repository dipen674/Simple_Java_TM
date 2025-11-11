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
                echo 'Compiling the code'
                sh 'mvn clean compile'
            }
        }
        
        stage('Run Unit Tests') {
            steps {
                echo 'Running unit tests'
                sh 'mvn test'
            }

        }
        
        stage('Package Application') {
            steps {
                echo 'Packaging the application'
                sh 'mvn package -DskipTests' // Skip tests since they already ran
            }
            post {
                success {
                    echo "Archiving the Artifacts...."
                    archiveArtifacts artifacts: '**/*.war'
                }
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
        
        stage('Build docker image') {
            steps {
                echo "Building docker image"
                sh 'docker image build --no-cache -t ${image}:V_${BUILD_NUMBER} .'
            }
        }
        
        stage('Image scanning with Trivy') {
            steps {
                echo "Scanning image for vulnerabilities"
                sh 'mkdir -p trivy-reports'
                sh "trivy image --exit-code 1 --severity CRITICAL --format template --template @/usr/local/share/trivy/templates/html.tpl --output trivy-reports/trivy-report-${BUILD_NUMBER}.html ${image}:V_${BUILD_NUMBER}"
            }
            post {
                always {
                    archiveArtifacts artifacts: 'trivy-reports/*', fingerprint: true
                    
                    // Cleanup old Trivy reports - keep only latest 3
                    sh '''
                        echo "Cleaning up old Trivy reports, keeping only latest 3..."
                        cd trivy-reports
                        
                        # Get all report files and sort by build number, remove all but last 3
                        ls trivy-report-*.html 2>/dev/null | \
                        sort -t- -k3 -n | \
                        head -n -3 | \
                        while read file; do
                            echo "Removing old report: $file"
                            rm -f "$file"
                        done
                        
                        echo "Current Trivy reports:"
                        ls -la trivy-report-*.html 2>/dev/null || echo "No Trivy reports found"
                    '''
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
                        set -e 
                        
                        echo "=== Activating Virtual Environment ==="
                        test -f /home/vagrant/myenv/bin/activate || { echo "Virtual environment not found"; exit 1; }
                        source /home/vagrant/myenv/bin/activate
                        
                        echo "=== Setting Up Directory Structure ==="
                        rm -rf /home/vagrant/{java_app_required_files,java_app_harbor}
                        mkdir -p /home/vagrant/java_app_required_files
                        
                        echo "=== Downloading Application Files ==="
                        cd /home/vagrant
                        git clone --single-branch --branch harbor https://github.com/dipen674/Simple_Java_TM.git java_app_harbor
                        cp java_app_harbor/{Dockerfile,docker-compose.yml,init.sql} java_app_required_files/
                        rm -rf java_app_harbor
                        
                        echo "=== Downloading Ansible Configurations ==="
                        cd /home/vagrant/java_app_required_files
                        git clone https://github.com/dipen674/Ansible_configs_project/
                        
                        echo "=== Running Ansible Deployment ==="
                        ansible-galaxy collection install community.docker
                        cd Ansible_configs_project
                        ansible-playbook playbook.yaml -e "build_number=${BUILD_NUMBER}"
                        
                        echo "=== Deployment Completed Successfully ==="
                    '
                    """
                }
            }
        }
    }
    
    post {
        always {
            node('production') {
                script {
                    sh "docker system prune -a -f || true"
            
                    sh "docker pull ${image}:V_${BUILD_NUMBER} || true"
                    
                    def previousBuildNumber = BUILD_NUMBER.toInteger() - 1
                    sh "docker pull ${image}:V_${previousBuildNumber} || true"
                    
                    echo "Cleanup completed on production node and images pulled"
                }
            }
        }

        success {
            node('master') {
                mail(
                    bcc: 'dipakbhatt363@gmail.com',
                    to: 'bhattadeependra05@gmail.com',
                    cc: 'bhattad625@gmail.com',
                    from: 'bhattad625@gmail.com',
                    replyTo: '',
                    subject: 'BUILD SUCCESS NOTIFICATION',
                    body: """Hi Team,

                        Build #$BUILD_NUMBER is successful. Please review the build details at:
                        $BUILD_URL

                        Regards,  
                        DevOps Team"""
                )
            }
        }

        failure {
            node('master') {
                mail(
                    to: 'bhattadeependra05@gmail.com',
                    cc: 'dipakbhatt363@gmail.com',
                    bcc: '',
                    from: 'bhattad625@gmail.com',
                    replyTo: 'bhattadeependra05@gmail.com',
                    subject: 'BUILD FAILED NOTIFICATION',
                    body: """Hi Team,

                        Build #$BUILD_NUMBER is unsuccessful.  
                        Please go through the following URL and verify the details:  
                        $BUILD_URL

                        Best Regards,  
                        DevOps Team"""
                )
            }
        }
    }
}
