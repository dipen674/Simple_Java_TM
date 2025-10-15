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

**Key Features:**
- User authentication and authorization
- Task creation, editing, and deletion
- Task categorization with custom colors
- Priority-based task management
- Due date tracking and notifications
- User profile management

---

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
| **Jenkins VM** | CI/CD Pipeline | Jenkins, Git | 8080 |
| **Production VM (Agent)** | Build & Scan | Docker, Trivy, Maven | 2375 |
| **Ansible VM** | Configuration Management | Ansible, Python venv |Prometheus| Grafana| 9090| 3000 |
| **Production VM (Target)** | Application Hosting | Docker, MySQL | 8080, 3306 |
| **Harbor VM** | Container Registry | Harbor | 443, 4443 |
| **Nexus VM** | Artifact Repository and code analysis | SonarQube | Nexus 3 | 9000 | 8081 |

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
│   │   │   ├── CategoryServlet.java
│   │   │   ├── DashboardServlet.java
│   │   │   ├── LoginServlet.java
│   │   │   ├── LogoutServlet.java
│   │   │   ├── ProfileServlet.java
│   │   │   ├── RegisterServlet.java
│   │   │   └── TaskServlet.java
│   │   ├── model/               # Data entities
│   │   │   ├── Category.java
│   │   │   ├── Task.java
│   │   │   └── User.java
│   │   ├── service/             # Business logic
│   │   │   ├── CategoryService.java
│   │   │   ├── TaskService.java
│   │   │   └── UserService.java
│   │   └── util/                # Utility classes
│   │       └── DatabaseUtil.java
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
│           │   ├── dashboard.jsp
│           │   ├── error.jsp
│           │   ├── login.jsp
│           │   ├── profile.jsp
│           │   ├── register.jsp
│           │   ├── task-form.jsp
│           │   └── task-list.jsp
│           └── web.xml          # Servlet mappings
├── docker-compose.yml           # Multi-container setup
├── Dockerfile                   # Application container definition
├── init.sql                     # Database initialization script
├── Jenkinsfile                  # CI/CD pipeline definition
├── pom.xml                      # Maven dependencies
└── README.md                    # This file
```

### Ansible Repository Structure
[![Repo URL](https://github.com/dipen674/Ansible_configs_project.git)](https://github.com/dipen674/Ansible_configs_project.git)

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

```bash
# Install Jenkins
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins -y

# Generate SSH key for Ansible VM access
sudo -u jenkins ssh-keygen -t rsa -b 4096 -f /var/lib/jenkins/.ssh/id_rsa -N ""
```
The key should be generated with jenkins user and copied to Ansible VMs authorized_keys. If Jenkins user cannot access the ansible 
machine then the jenkins pipeline cannot trigger ansible machine via ssh command.
'''
root@jenkins:/var/lib/jenkins/keys# ls -la
total 20
drwx------  2 jenkins jenkins 4096 Sep  7 16:21 .
drwxr-xr-x 20 jenkins jenkins 4096 Oct 15 03:10 ..
-rw-------  1 jenkins jenkins 3381 Sep  7 16:15 id_rsa
-rw-r--r--  1 jenkins jenkins  741 Sep  7 16:15 id_rsa.pub
-rw-r--r--  1 jenkins jenkins  284 Sep  7 16:21 known_hosts
'''
Copy the key to the ansible vm and make sure the user should be jenkins. 
'''
su jenkins
ssh-copy-id usernameofnode@ipadressofnode
 - ssh-copy-id vagrant@192.168.56.211
'''
Then try to access the machine from jenkins user

# Install required packages
**Jenkins Configuration:**
1. Install required plugins:
   - Pipeline
   - Git Plugin
   - Docker Pipeline
   - SonarQube Scanner
   - Nexus Artifact Uploader
   - Email Extension
2. Configure tools in Global Tool Configuration:
   - Maven: `maven-3.6`
   - SonarQube Scanner: `sonar7.2`
3. Add credentials:
   - `nexus-credentials`: Username/password for Nexus
   - `Harborregistrycredentials`: Username/password for Harbor
   - `ansible-ssh-key`: SSH private key for Ansible VM

### 2. Production VM (Build Agent) Setup

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Java
sudo apt install openjdk-11-jdk -y

# Install Maven
sudo apt install maven -y

# Install Trivy
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt update
sudo apt install trivy -y

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
sudo apt update
sudo apt install software-properties-common -y
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker vagrant

# Create Python virtual environment
python3 -m venv /home/vagrant/myenv
source /home/vagrant/myenv/bin/activate
pip install ansible docker docker-compose

# Install Ansible collections
ansible-galaxy collection install community.docker

# Configure SSH access
mkdir -p /home/vagrant/.ssh
# Copy Jenkins public key to /home/vagrant/.ssh/authorized_keys
chmod 700 /home/vagrant/.ssh
chmod 600 /home/vagrant/.ssh/authorized_keys
```

**Clone Ansible Repository:**
```bash
cd /home/vagrant
git clone https://github.com/dipen674/Ansible_configs_project.git
```

### 4. Production VM (Deployment Target) Setup

```bash
# Install Docker and Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Configure firewall
sudo ufw allow 8080/tcp
sudo ufw allow 3306/tcp
sudo ufw allow 22/tcp
sudo ufw enable

# Configure SSH for Ansible
mkdir -p /home/vagrant/.ssh
# Copy Ansible VM public key to /home/vagrant/.ssh/authorized_keys
```

---

## 🔄 CI/CD Pipeline

### Pipeline Trigger

The pipeline automatically triggers on push to the GitHub repository using webhooks.

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

### Ansible Playbook Breakdown

**Main Playbook (playbook.yaml):**
```yaml
- hosts: production
  become: yes
  roles:
    - deploy
```

**Role: deploy/tasks/main.yaml**
```yaml
- import_tasks: 01_setup.yaml
- import_tasks: 02_configs.yaml
- import_tasks: 03_deploy.yaml
- import_tasks: 04_cleanup.yaml
```

**Task Details:**

**01_setup.yaml:**
- Stop existing containers
- Remove old application files
- Create directory structure
- Install Docker and Docker Compose (if missing)

**02_configs.yaml:**
- Copy `docker-compose.yml` to target
- Copy `Dockerfile` to target
- Copy `init.sql` to target
- Set proper file permissions

**03_deploy.yaml:**
- Pull latest Docker image from Harbor
- Execute `docker-compose up -d`
- Wait for MySQL health check
- Verify application startup

**04_cleanup.yaml:**
- Remove dangling Docker images
- Clean up old containers
- Free disk space
- Archive old logs

---

## 🗄️ Database Schema

### Tables

#### users
```sql
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

#### categories
```sql
CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    color VARCHAR(7) DEFAULT '#3498db',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

#### tasks
```sql
CREATE TABLE tasks (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    category_id INT,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    priority ENUM('LOW', 'MEDIUM', 'HIGH') DEFAULT 'MEDIUM',
    status ENUM('TODO', 'IN_PROGRESS', 'COMPLETED') DEFAULT 'TODO',
    due_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);
```

---

## 🌐 API Endpoints

| Method | Endpoint | Description | Authentication |
|--------|----------|-------------|----------------|
| `GET` | `/` | Landing page | Public |
| `GET` | `/register` | Registration form | Public |
| `POST` | `/register` | Create new user | Public |
| `GET` | `/login` | Login form | Public |
| `POST` | `/login` | Authenticate user | Public |
| `GET` | `/dashboard` | User dashboard | Required |
| `GET` | `/tasks` | List all tasks | Required |
| `GET` | `/tasks?id={id}` | Get task details | Required |
| `POST` | `/tasks` | Create new task | Required |
| `PUT` | `/tasks` | Update task | Required |
| `DELETE` | `/tasks?id={id}` | Delete task | Required |
| `GET` | `/categories` | List categories | Required |
| `POST` | `/categories` | Create category | Required |
| `GET` | `/profile` | View profile | Required |
| `POST` | `/profile` | Update profile | Required |
| `GET` | `/logout` | End session | Required |

### Request/Response Examples

**Create Task:**
```http
POST /tasks HTTP/1.1
Content-Type: application/x-www-form-urlencoded

title=Complete+README&description=Finalize+documentation&priority=HIGH&category_id=1&due_date=2025-10-20
```

**Response:**
```http
HTTP/1.1 302 Found
Location: /tasks?success=Task+created+successfully
```

---

## 📊 Monitoring & Alerts

### Prometheus Configuration

**Scrape Config (prometheus/prometheus.yml):**
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'taskmanager-app'
    static_configs:
      - targets: ['production-vm:8080']
    metrics_path: '/metrics'
```

### Alertmanager Rules

**Critical Alerts (prometheus/rules.yml):**
```yaml
groups:
  - name: application_alerts
    interval: 30s
    rules:
      - alert: ApplicationDown
        expr: up{job="taskmanager-app"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Application is down"
          description: "Task Manager application on {{ $labels.instance }} is unreachable"

      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }} on {{ $labels.instance }}"
```

**Email Notifications (prometheus/alertmanager.yml):**
```yaml
route:
  receiver: 'email-team'
  group_by: ['alertname', 'severity']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h

receivers:
  - name: 'email-team'
    email_configs:
      - to: 'bhattadeependra05@gmail.com'
        from: 'alerts@taskmanager.local'
        smarthost: 'smtp.gmail.com:587'
        auth_username: 'bhattad625@gmail.com'
        auth_password: '${SMTP_PASSWORD}'
```

---

## 🚦 Getting Started

### Quick Start Guide

#### 1. Clone Repositories

```bash
# Application repository
git clone https://github.com/dipen674/Simple_Java_TM.git
cd Simple_Java_TM

# Ansible repository
git clone https://github.com/dipen674/Ansible_configs_project.git
```

#### 2. Configure Jenkins Pipeline

1. Create new Pipeline job in Jenkins
2. Configure GitHub repository URL
3. Set branch to `jenkins` or `harbor-feature`
4. Point to `Jenkinsfile` in repository root
5. Enable GitHub webhook trigger

#### 3. Verify VM Connectivity

```bash
# From Jenkins VM
ssh vagrant@192.168.56.210

# From Ansible VM
ssh vagrant@<production-vm-ip>
```

#### 4. Trigger First Build

```bash
# Push to trigger branch
git checkout jenkins
git commit --allow-empty -m "Trigger initial build"
git push origin jenkins
```

#### 5. Access Application

```
URL: http://<production-vm-ip>:8080/taskmanager
```

**Default Credentials:** (Create via registration form)

---

## 🔧 Troubleshooting

### Common Issues

#### Pipeline Fails at Build Stage

**Symptom:** Maven build fails with dependency errors

**Solution:**
```bash
# On Production VM (Build Agent)
rm -rf ~/.m2/repository
mvn clean install
```

---

#### Docker Image Pull Fails

**Symptom:** `Error response from daemon: Get "https://harbor.registry.local/v2/": unauthorized`

**Solution:**
```bash
# On Production VM
docker login harbor.registry.local
# Enter Harbor credentials
```

---

#### Ansible Connection Timeout

**Symptom:** `SSH Error: Connection timed out`

**Solution:**
```bash
# From Ansible VM
ssh-copy-id vagrant@<production-vm-ip>

# Verify connectivity
ansible -i inventory.ini production -m ping
```

---

#### Application Database Connection Error

**Symptom:** `Cannot connect to MySQL server`

**Solution:**
```bash
# Check MySQL container status
docker ps | grep mysql

# View MySQL logs
docker logs taskmanager-mysql-1

# Restart containers
docker-compose down && docker-compose up -d
```

---

#### Trivy Scan Fails with Critical Vulnerabilities

**Symptom:** Pipeline fails at security scanning stage

**Solution:**
```bash
# View detailed vulnerability report
cat trivy-reports/trivy-report-${BUILD_NUMBER}.txt

# Update base image in Dockerfile
FROM tomcat:9.0-jdk11-openjdk-slim  # Use slim variant

# Rebuild with updated dependencies
docker build --no-cache -t harbor.registry.local/java_app/taskmanager:V_${BUILD_NUMBER} .
```

---

#### Nexus Upload Fails

**Symptom:** `401 Unauthorized` during artifact upload

**Solution:**
1. Verify Nexus credentials in Jenkins
2. Check repository permissions in Nexus
3. Ensure repository `Javaapp_TM` exists

```bash
# Test Nexus connectivity
curl -u admin:password http://192.168.56.6:8081/service/rest/v1/repositories
```

---

### Viewing Logs

#### Jenkins Logs
```bash
# Jenkins master logs
sudo tail -f /var/log/jenkins/jenkins.log

# Pipeline console output
# Available in Jenkins UI: Job → Build #N → Console Output
```

#### Docker Container Logs
```bash
# Application container
docker logs -f taskmanager-app-1

# MySQL container
docker logs -f taskmanager-mysql-1

# Follow all containers
docker-compose logs -f
```

#### Ansible Logs
```bash
# On Ansible VM
tail -f /home/vagrant/ansible.log

# Verbose playbook execution
ansible-playbook playbook.yaml -vvv -e "build_number=${BUILD_NUMBER}"
```

---

## 🔐 Security Considerations

### Credentials Management

All sensitive credentials are stored in:
- **Jenkins Credentials Store** (encrypted at rest)
- **Ansible Vault** (for sensitive variables)
- **Environment Variables** (never hardcoded)

### Network Security

```
Firewall Rules:
- Jenkins VM: Allow 8080 (Jenkins UI), 22 (SSH)
- Production VM: Allow 8080 (App), 3306 (MySQL - internal only), 22 (SSH)
- Ansible VM: Allow 22 (SSH only)
```

### Image Security

- **Trivy Scanning:** Blocks critical vulnerabilities
- **Harbor Registry:** Role-based access control
- **Image Signing:** Verify image authenticity (optional)

---

## 📈 Performance Optimization

### Docker Build Cache
```dockerfile
# Leverage layer caching
FROM tomcat:9.0-jdk11
COPY pom.xml .
RUN mvn dependency:go-offline  # Cache dependencies
COPY src ./src
RUN mvn package
```

### Database Connection Pooling
```xml
<!-- context.xml -->
<Resource name="jdbc/TaskManagerDB"
          auth="Container"
          type="javax.sql.DataSource"
          maxTotal="20"
          maxIdle="10"
          maxWaitMillis="10000"
          username="taskmanager_user"
          password="secure_password"
          driverClassName="com.mysql.cj.jdbc.Driver"
          url="jdbc:mysql://mysql:3306/taskmanager"/>
```

---

## 🧪 Testing

### Manual Testing Checklist

- [ ] User registration and login
- [ ] Task creation with all priorities
- [ ] Task editing and deletion
- [ ] Category management
- [ ] Profile updates
- [ ] Session persistence
- [ ] Error handling
- [ ] Mobile responsiveness

### Automated Testing (Future Enhancement)

```bash
# Unit tests
mvn test

# Integration tests
mvn verify

# Code coverage report
mvn jacoco:report
```

---

## 📦 Backup & Recovery

### Database Backup

```bash
# Manual backup
docker exec taskmanager-mysql-1 mysqldump -u root -p taskmanager > backup_$(date +%F).sql

# Automated backup (add to cron)
0 2 * * * docker exec taskmanager-mysql-1 mysqldump -u root -ppassword taskmanager | gzip > /backup/taskmanager_$(date +\%F).sql.gz
```

### Restore from Backup

```bash
# Stop application
docker-compose down

# Restore database
docker exec -i taskmanager-mysql-1 mysql -u root -ppassword taskmanager < backup_2025-10-15.sql

# Start application
docker-compose up -d
```

### Rollback Strategy

```bash
# Rollback to previous build
ansible-playbook playbook.yaml -e "build_number=$((CURRENT_BUILD - 1))"

# Or manually
docker tag harbor.registry.local/java_app/taskmanager:V_122 harbor.registry.local/java_app/taskmanager:latest
docker-compose up -d
```

---

## 🤝 Contributing

### Development Workflow

1. **Fork the repository**
2. **Create feature branch**
   ```bash
   git checkout -b feature/new-feature
   ```
3. **Make changes and commit**
   ```bash
   git commit -m "Add: New feature description"
   ```
4. **Push to branch**
   ```bash
   git push origin feature/new-feature
   ```
5. **Create Pull Request**

### Coding Standards

- **Java:** Follow Oracle Java Code Conventions
- **SQL:** Use uppercase for keywords, snake_case for identifiers
- **JavaScript:** ESLint with Airbnb style guide
- **Documentation:** Update README for significant changes

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Authors & Acknowledgments

**Project Team:**
- **Deependrabhatta** - DevOps Engineer
- Email: bhattadeependra05@gmail.com
- Email: bhattad625@gmail.com
- Email: dipakbhatt363@gmail.com

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
- [ ] **v2.1:** User role-based access control
- [ ] **v2.2:** Task sharing and collaboration
- [ ] **v2.3:** REST API with Swagger documentation
- [ ] **v2.4:** Mobile application (React Native)
- [ ] **v2.5:** Real-time notifications (WebSockets)
- [ ] **v2.6:** Task analytics dashboard
- [ ] **v2.7:** Integration with Slack/Teams
- [ ] **v2.8:** Automated testing suite
- [ ] **v2.9:** Performance monitoring (APM)

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

---

## ⚡ Quick Commands Reference

### Jenkins
```bash
# Restart Jenkins
sudo systemctl restart jenkins

# View logs
sudo journalctl -u jenkins -f
```

### Docker
```bash
# Clean all
docker system prune -a -f

# View resource usage
docker stats

# Inspect container
docker inspect taskmanager-app-1
```

### Ansible
```bash
# Syntax check
ansible-playbook playbook.yaml --syntax-check

# Dry run
ansible-playbook playbook.yaml --check

# Run with tags
ansible-playbook playbook.yaml --tags "deploy"
```

### MySQL
```bash
# Connect to database
docker exec -it taskmanager-mysql-1 mysql -u root -p

# Show databases
SHOW DATABASES;

# Use taskmanager database
USE taskmanager;

# Show tables
SHOW TABLES;
```

---

**Last Updated:** October 15, 2025  
**Version:** 4.0  
**Status:** Production Ready ✅