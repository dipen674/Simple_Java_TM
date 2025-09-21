pipeline {
    agent none

    triggers {
        // Trigger on push to 'jenkins' branch
        githubPush()
    }
 environment {
                image = "harbor.registry.local/java_app/taskmanager"
                scannerHome = tool 'sonar7.2'
            }

    stages {
       

        stage('Compile the code') {
            agent {label "production"}
            steps {
                echo 'packaging the code'
                sh 'mvn clean verify'
            }
            post {
                success {
                    echo "Archiving the Artifacts...."
                    archiveArtifacts artifacts: '**/*.war'
                }
            }
        }
        
        stage('Build docker image') {
            agent {label "production"}
            steps {
                echo "Building docker images'"
                sh 'docker image build -t ${image}:V_${BUILD_NUMBER} .'
            }
        }
        
        stage('Image scanning with trivy') {
            agent {label "production"}
            steps {
                echo "Scanning image vulneriblity"
                sh 'trivy image ${image}:V_${BUILD_NUMBER}'
            }
        }
        
        stage('Pushing docker image to dockerhub') {
            agent {label "production"}
            steps {
                echo "pushing image"
                 withDockerRegistry([credentialsId: 'Harborregistrycredentials', url: 'https://harbor.registry.local'])
                 {
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
                        keyFileVariable: 'ANSIBLE_KEY'
                    )
                ]) {
                    sh """
                    ssh -i "/var/lib/jenkins/keys/id_rsa" -o StrictHostKeyChecking=no vagrant@192.168.56.210 '
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
            stage('Sonar Analysis') {
            agent { label "production" }
            steps {
                withSonarQubeEnv('sonar') {
                    sh '''${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=taskmanager-webapp \
                        -Dsonar.projectName=taskmanager-webapp \
                        -Dsonar.projectVersion=4.0 \
                        -Dsonar.sources=. \
                        -Dsonar.junit.reportsPath=target/surefire-reports/ \
                        -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                        -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
                }
            }
        }

    }
}
