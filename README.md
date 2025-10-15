# Task Manager Web Application

A production-grade Java web application demonstrating enterprise CI/CD practices with automated deployment, security scanning, and infrastructure as code.

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)]()
[![Docker](https://img.shields.io/badge/docker-ready-blue)]()
[![License](https://img.shields.io/badge/license-MIT-green)]()

The Task Manager is a full-stack Java web application that showcases modern DevOps practices including:

- ✅ Automated CI/CD with Jenkins
- ✅ Infrastructure as Code with Ansible
- ✅ Containerization with Docker
- ✅ Security scanning with Trivy
- ✅ Code quality analysis with SonarQube
- ✅ Artifact management with Nexus
- ✅ Container registry with Harbor
- ✅ Monitoring with Prometheus & Alertmanager


## 🛠️ Technology Stack
### Backend
- **Language:** Java 8+
- **Framework:** Java Servlets, JSP
- **Build Tool:** Apache Maven 3.6+
- **Web Server:** Apache Tomcat 9.0

### Frontend
- **Languages:** HTML5, CSS3, JavaScript

### Database
- **RDBMS:** MySQL 8.0

### DevOps & Infrastructure
- **CI/CD:** Jenkins (declarative pipeline)
- **Configuration Management:** Ansible 2.9+
- **Containerization:** Docker, Docker Compose
- **Image Registry:** Harbor (harbor.registry.local)
- **Artifact Repository:** Nexus 3
- **Security Scanning:** Trivy
- **Code Quality:** SonarQube 7.2
- **Monitoring:** Prometheus, Alertmanager

---

## 🏗️ Architecture


### VM Responsibilities
- **Jenkins VM** | CI/CD Pipeline | Jenkins, Git | 8080 |
- **Production VM (Agent)** | Build & Scan | Docker, Trivy, Maven | 2375 |
- **Ansible VM** | Configuration Management | Ansible, Python venv |Prometheus| Grafana| 9090| 3000 |
- **Production VM (Target)** | Application Hosting | Docker, MySQL | 8080, 3306 |
- **Harbor VM** | Container Registry | Harbor | 443, 4443 |
- **Nexus VM** | Artifact Repository and code analysis | SonarQube | Nexus 3 | 9000 | 8081 |

Node exporter installed on all VMs for monitoring and CAdvisor installed on Production VM, Deployment VM and Harbor VM for container monitoring.

### Application Architecture

The application follows the **MVC (Model-View-Controller)** pattern:

```
┌──────────────┐
│   Browser    │
└──────┬───────┘
       │ HTTP Request
       ▼
┌──────────────────────────────────────┐
│         Controller Layer             │
│  (Servlets: Login, Task, Category)   │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│          Service Layer               │
│  (Business Logic & Validation)       │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│           Model Layer                │
│     (User, Task, Category)           │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│       Database (MySQL)               │
│   (Persistent Storage)               │
└──────────────────────────────────────┘
```

---

## 📁 Project Structure

### Application Repository

```
taskmanager-webapp/
├── src/main/
│   ├── java/com/example/taskmanager/
│   │   ├── controller/          # HTTP request handlers
│   │   ├── model/               # Data entities
│   │   ├── service/             # Business logic
│   │   └── util/                # Utility classes
│   └── webapp/
│       ├── css/
│       │   └── style.css        # Application styles
│       ├── js/
│       │   └── script.js        # Client-side logic
│       ├── index.jsp            # Landing page
│       ├── META-INF/
│       │   └── context.xml      # Database configuration
│       └── WEB-INF/
│           ├── views/           # JSP templates
│           └── web.xml          # Servlet mappings
├── docker-compose.yml           # Multi-container setup
├── Dockerfile                   # Application container definition
├── init.sql                     # Database initialization script
├── Jenkinsfile                  # CI/CD pipeline definition
├── pom.xml                      # Maven dependencies
└── README.md                 
```

### Ansible Repository Structure
- Ansible Configs: https://github.com/dipen674/Ansible_configs_project

```
TM-javaapp_ansible/
├── ansible.cfg                  # Ansible configuration
├── inventory.ini                # Target hosts inventory
├── playbook.yaml                # Main orchestration playbook
├── prometheus/                  # Monitoring configurations
│   ├── alertmanager.yml         # Alert routing rules
│   ├── prometheus.yml           # Prometheus scrape config
│   └── rules.yml                # Alerting rules
└── roles/
    └── deploy/                  # Deployment role
        ├── tasks/
        │   ├── 01_setup.yaml       # Environment preparation
        │   ├── 02_configs.yaml     # Configuration management
        │   ├── 03_deploy.yaml      # Application deployment
        │   ├── 04_cleanup.yaml     # Resource cleanup
        │   └── main.yaml           # Task orchestration
        ├── templates/              # Jinja2 templates
        └── vars/
            └── main.yaml           # Role variables
```

---

## 🚀 Infrastructure Setup

### Prerequisites

- VirtualBox or VMware for VM management
- SSH access configured between VMs
- Git installed on all VMs
- Internet connectivity for package downloads

### 1. Jenkins VM Setup
- Install Jenkins
- Generate SSH key for Ansible VM access
```
sudo -u jenkins ssh-keygen -t rsa -b 4096 -f /var/lib/jenkins/.ssh/id_rsa -N ""
```

The key should be generated with jenkins user and copied to Ansible VMs authorized_keys. If Jenkins user cannot access the ansible 
machine then the jenkins pipeline cannot trigger ansible machine via ssh command.

```
root@jenkins:/var/lib/jenkins/keys# ls -la
total 20
drwx------  2 jenkins jenkins 4096 Sep  7 16:21 .
drwxr-xr-x 20 jenkins jenkins 4096 Oct 15 03:10 ..
-rw-------  1 jenkins jenkins 3381 Sep  7 16:15 id_rsa
-rw-r--r--  1 jenkins jenkins  741 Sep  7 16:15 id_rsa.pub
-rw-r--r--  1 jenkins jenkins  284 Sep  7 16:21 known_hosts
```

***Copy the key to the ansible vm and make sure the user should be jenkins.***

```
su jenkins
ssh-copy-id usernameofnode@ipadressofnode
 - ssh-copy-id vagrant@192.168.56.211
```
***Then try to access the machine from jenkins user***

# Install required packages
**Jenkins Configuration:**
1. Install required plugins:
   - Git Plugin
   - Docker Pipeline
   - SonarQube Scanner
   - Nexus Artifact Uploader
   - Email Extension
2. Configure tools in Global Tool Configuration:
   - SonarQube Scanner: `sonar7.2`
3. Add credentials:
   - `nexus-credentials`: Username/password for Nexus
   - `Harborregistrycredentials`: Username/password for Harbor
   - `ansible-ssh-key`: SSH private key for Ansible VM
   - `github tokken`: To trigger webhook

### 2. Production VM (Build Agent) Setup

```bash
# Install Docker
# Install Java
# Install Maven
# Install Trivy
# configure SSH to add node in jenkins master
ssh-copy-id usernameofnode@ipadressofnode
 - ssh-copy-id vagrant@192.168.56.211
Use this command to copy the public key of jenkins master to production vm
# Copy Jenkins VM public key to /home/jenkins/.ssh/authorized_keys
```

**Connect Agent to Jenkins:**
1. Navigate to Jenkins → Manage Jenkins → Manage Nodes
2. Add new node with label `production`
3. Configure launch method as "Launch agents via SSH"

### 3. Ansible VM Setup (192.168.56.210)

```bash
# Install Ansible
# Create Python virtual environment
# Install Ansible collections
Via pipeline
# Configure SSH access
copy ssh key of the ansible to the deployment_vm so tha the ansible_vm can access the deployment vm
```

### 4. Deployment VM (Deployment Target) Setup

```bash
# Install Docker and Docker Compose
# Configure SSH for Ansible
# Copy Ansible VM public key to /home/vagrant/.ssh/authorized_keys
and check the connection
```

---

## 🔄 CI/CD Pipeline

### Pipeline Trigger

The pipeline automatically triggers on push to the GitHub repository using webhooks.
For this i have installed ngrok and using the ngrok to trigger the webhook.

```groovy
triggers {
    githubPush()
}
```

### Pipeline Stages

#### Stage 1: Compile the Code
**Agent:** `production` (Build VM)

```bash
mvn clean package -DskipTests=true
```

**Actions:**
- Cleans previous build artifacts
- Compiles Java source code
- Packages application into WAR file
- Archives `taskmanager-webapp.war`

**Artifacts:** `target/*.war`

---

#### Stage 2: Upload Artifact to Nexus
**Agent:** `production`

```groovy
nexusArtifactUploader(
    nexusVersion: 'nexus3',
    protocol: 'http',
    nexusUrl: '192.168.56.6:8081',
    groupId: 'QA',
    version: "${BUILD_ID}-${BUILD_TIMESTAMP}",
    repository: 'Javaapp_TM',
    credentialsId: 'nexus-credentials',
    artifacts: [[
        artifactId: 'taskmanager-webapp',
        file: 'target/taskmanager-webapp.war',
        type: 'war'
    ]]
)
```

**Actions:**
- Authenticates with Nexus repository
- Uploads versioned WAR artifact
- Tags with build ID and timestamp

---

#### Stage 3: Sonar Analysis
**Agent:** `production`

```bash
sonar-scanner \
  -Dsonar.projectKey=taskmanager-webapp \
  -Dsonar.projectName=taskmanager-webapp \
  -Dsonar.projectVersion=4.0 \
  -Dsonar.sources=src/main/java,src/main/webapp \
  -Dsonar.java.binaries=target/classes
```

**Quality Gates:**
- Code coverage analysis
- Bug detection
- Code smell identification
- Security vulnerability scanning
- Technical debt assessment

---

#### Stage 4: Build Docker Image
**Agent:** `production`

```bash
docker image build --no-cache -t harbor.registry.local/java_app/taskmanager:V_${BUILD_NUMBER} .
```

**Dockerfile Layers:**
1. Base image: `tomcat:9.0-jdk11`
2. WAR deployment to `/usr/local/tomcat/webapps/`
3. Environment configuration
4. Port exposure: 8080

---

#### Stage 5: Image Scanning with Trivy
**Agent:** `production`

```bash
trivy image --exit-code 1 --severity CRITICAL \
  --output trivy-reports/trivy-report-${BUILD_NUMBER}.txt \
  harbor.registry.local/java_app/taskmanager:V_${BUILD_NUMBER}
```

**Security Checks:**
- CVE database scanning
- OS package vulnerabilities
- Application dependency vulnerabilities
- Critical severity threshold enforcement

**Outputs:**
- Text report: `trivy-reports/trivy-report-${BUILD_NUMBER}.txt`
- HTML report: `trivy-reports/trivy-report-${BUILD_NUMBER}.html`

**Pipeline Behavior:**
- ❌ Fails on CRITICAL vulnerabilities
- ✅ Proceeds if no critical issues found

---

#### Stage 6: Push to Harbor Registry
**Agent:** `production`

```bash
docker push harbor.registry.local/java_app/taskmanager:V_${BUILD_NUMBER}
```

**Registry Details:**
- **URL:** https://harbor.registry.local
- **Project:** java_app
- **Repository:** taskmanager
- **Tag Format:** V_${BUILD_NUMBER}

---

#### Stage 7: Deploy via Ansible
**Agent:** `master` (Jenkins Master)

**SSH Connection to Ansible VM:**
```bash
ssh -i "${ANSIBLE_KEY}" ${SSH_USERNAME}@192.168.56.210
```

**Remote Execution Steps:**

1. **Virtual Environment Activation**
```bash
source /home/vagrant/myenv/bin/activate
```

2. **Directory Preparation**
```bash
rm -rf /home/vagrant/{java_app_required_files,java_app_harbor}
mkdir -p /home/vagrant/java_app_required_files
```

3. **Application Files Download**
```bash
git clone --single-branch --branch harbor-feature \
  https://github.com/dipen674/Simple_Java_TM.git java_app_harbor
cp java_app_harbor/{Dockerfile,docker-compose.yml,init.sql} java_app_required_files/
```

4. **Ansible Configuration Download**
```bash
cd /home/vagrant/java_app_required_files
git clone https://github.com/dipen674/Ansible_configs_project.git
```

5. **Ansible Collection Installation**
```bash
ansible-galaxy collection install community.docker
```

6. **Playbook Execution**
```bash
cd Ansible_configs_project
ansible-playbook playbook.yaml -e "build_number=${BUILD_NUMBER}"
```

---

### Post-Build Actions

#### Always (Cleanup)
**Agent:** `production`

```bash
# System cleanup
docker system prune -a -f

# Pull current and previous images for rollback capability
docker pull harbor.registry.local/java_app/taskmanager:V_${BUILD_NUMBER}
docker pull harbor.registry.local/java_app/taskmanager:V_$((BUILD_NUMBER - 1))
```

#### Success (Email Notification)
**Agent:** `master`

```
To: bhattadeependra05@gmail.com
Cc: bhattad625@gmail.com
Bcc: dipakbhatt363@gmail.com
Subject: BUILD SUCCESS NOTIFICATION

Hi Team,

Build #123 is successful. Please review the build details at:
http://jenkins.example.com/job/taskmanager/123/

Regards,  
DevOps Team
```

#### Failure (Email Notification)
**Agent:** `master`

```
To: bhattadeependra05@gmail.com
Cc: dipakbhatt363@gmail.com
Subject: BUILD FAILED NOTIFICATION

Hi Team,

Build #123 is unsuccessful.  
Please go through the following URL and verify the details:  
http://jenkins.example.com/job/taskmanager/123/

Best Regards,  
DevOps Team
```

---

## 🔗 Deployment Flow

### End-to-End Data Flow

```
┌──────────────────────────────────────────────────────────────────┐
│ Step 1: Developer Push                                           │
│ Developer → GitHub (jenkins/harbor-feature branch)               │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────┐
│ Step 2: Webhook Trigger                                          │
│ GitHub Webhook → Jenkins VM (Port 8080)                          │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────┐
│ Step 3: Build Orchestration                                      │
│ Jenkins Master → Production VM Agent (label: 'production')       │
│ - Execute Maven build                                            │
│ - Build Docker image                                             │
│ - Run Trivy security scan                                        │
│ - Push to Harbor registry                                        │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────┐
│ Step 4: Configuration Management                                 │
│ Jenkins Master → Ansible VM (192.168.56.210)                     │
│ SSH Command: ansible-playbook playbook.yaml                      │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────┐
│ Step 5: Ansible Playbook Execution                               │
│ Ansible VM → Production VM (Target)                              │
│ - 01_setup.yaml: Prepare environment                             │
│ - 02_configs.yaml: Copy configurations                           │
│ - 03_deploy.yaml: Execute docker-compose                         │
│ - 04_cleanup.yaml: Remove old containers                         │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────┐
│ Step 6: Container Orchestration                                  │
│ Production VM Docker Engine                                      │
│ ┌──────────────────────────────────────────────────────────┐    │
│ │ docker-compose.yml                                       │    │
│ │ ┌────────────────────┐  ┌─────────────────────────┐     │    │
│ │ │   MySQL Container  │  │  Tomcat Container       │     │    │
│ │ │   Port: 3306       │◄─┤  Port: 8080             │     │    │
│ │ │   Volume: db_data  │  │  Image: harbor.../V_123 │     │    │
│ │ └────────────────────┘  └─────────────────────────┘     │    │
│ └──────────────────────────────────────────────────────────┘    │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────┐
│ Step 7: Application Ready                                        │
│ Production VM:8080 ← End Users                                   │
│ Health Check: http://production-vm:8080/taskmanager/             │
└──────────────────────────────────────────────────────────────────┘
```
## 📊 Monitoring & Alerts
- For monitoring and alerts i have use prometheus and grafana

### Prometheus Configuration
- Setup alertmanager to send alerts to the slack channel
- Configured rules in rules.yml and jobs in prometheus.yml file.

**Repository Links:**
- Application: https://github.com/dipen674/Simple_Java_TM
- Ansible Configs: https://github.com/dipen674/Ansible_configs_project

---

## 📞 Support

For issues and questions:
- **GitHub Issues:** [Create an issue](https://github.com/dipen674/Simple_Java_TM/issues)
- **Email:** bhattadeependra05@gmail.com

---

## 🗺️ Roadmap

### Planned Features

- [ ] **v2.0:** Kubernetes deployment
---

## 📚 Additional Resources

### Documentation
- [Jenkins Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Trivy Security Scanner](https://aquasecurity.github.io/trivy/)

### Related Projects
- [Java Servlet Tutorial](https://www.oracle.com/java/technologies/servlet-technology.html)
- [Apache Tomcat Documentation](https://tomcat.apache.org/tomcat-9.0-doc/)
- [MySQL Documentation](https://dev.mysql.com/doc/)

---

## 🎯 Key Takeaways

This project demonstrates:

✅ **Enterprise CI/CD:** Multi-stage Jenkins pipeline with quality gates  
✅ **Infrastructure as Code:** Ansible-based configuration management  
✅ **Security First:** Trivy scanning and Harbor registry integration  
✅ **Scalable Architecture:** Containerized microservices approach  
✅ **Monitoring:** Prometheus and Alertmanager integration  
✅ **Best Practices:** Clean separation of concerns across VMs  

To see whether the users are being registered or not for troubleshooting

```
docker exec -it deploy_app-db-1 mysql -u taskuser -ptaskpass taskmanager -e "SELECT * FROM users;"
```

---

**Last Updated:** October 15, 2025  
**Version:** 4.0  
**Status:** Production Ready ✅