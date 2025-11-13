# Task Manager Web Application

A comprehensive, Dockerized task management web application built with Java Servlets, JSP, and MySQL. This application helps users organize their tasks with categories, priorities, and due dates.

# Branch Information

This repository contains multiple branches with different CI/CD pipeline configurations:

## Branches

- **`main`** - Contains the source code including Docker configurations and application code
- **`docker`** - Jenkins pipeline implementation using DockerHub registry
- **`harbor`** - Jenkins pipeline implementation using Harbor registry

## Getting Started

To explore different pipeline configurations:

```bash
# View DockerHub pipeline implementation
git checkout docker

# View Harbor registry pipeline implementation
git checkout harbor

# Return to main branch
git checkout main
```

Choose the appropriate branch based on your container registry preference.

## 🛠️ Technology Stack

- **Backend**: Java Servlets, JSP
- **Frontend**: HTML5, CSS3, JavaScript, JSTL
- **Database**: MySQL
- **Containerization**: Docker, Docker Compose
- **Web Server**: Apache Tomcat
- **Build Tool**: Maven

## 📁 Project Structure

```
taskmanager-webapp/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/example/taskmanager/
│       │       ├── controller/          # Servlets
│       │       ├── model/               # Data models
│       │       ├── service/             # Business logic
│       │       └── util/                # Utility classes
│       ├── resources/
│       └── webapp/
│           ├── css/
│           │   └── style.css            # Main stylesheet
│           ├── WEB-INF/
│           │   ├── views/               # JSP pages
│           │   └── web.xml              # Deployment descriptor
│           ├── META-INF/
│           │   └── context.xml          # Database configuration
│           └── index.jsp                # Home page
├── target/                              # Compiled output
├── docker-compose.yml                   # Multi-container setup
├── Dockerfile                           # App container definition
├── init.sql                             # Database initialization
├── pom.xml                              # Maven configuration
└── wait-for-it.sh                       # Database readiness script
```

### Architecture Diagram

<div align="center">
  <img src="architecture_diagram.png" alt="Task Manager Application Architecture" width="800"/>
</div>

## ⚠️ Important: Servlet API Compatibility

### The Problem

This application may encounter **404 errors** due to Servlet API version conflicts between different Tomcat versions:

- **Tomcat 10+**: Uses **Jakarta Servlet API** (package: `jakarta.servlet`)
- **Tomcat 9 and below**: Uses **Java EE Servlet API** (package: `javax.servlet`)

### How to Identify Which API to Use

1. **Check your Tomcat version**:
   ```bash
   # In your Tomcat directory
   ./bin/version.sh  # Linux/Mac
   version.bat       # Windows
   ```

2. **Version mapping**:
   - **Tomcat 11.x**: Jakarta Servlet API 6.0+ (`jakarta.servlet`)
   - **Tomcat 10.x**: Jakarta Servlet API 5.0+ (`jakarta.servlet`)
   - **Tomcat 9.x and below**: Java EE Servlet API (`javax.servlet`)

### In this code we are using jarkata.servlet and also using latest tomcat as a base image

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- Java JDK 11 or higher (for local development)
- Maven (for local development)

### Docker Setup (Recommended)

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd Simple_Java_TM
   ```

2. **Build the application**:
   ```bash
   mvn clean package
   ```

3. **Start the application**:
   ```bash
   docker-compose up --build
   ```

6. **Access the application**:
   - URL: http://localhost:8080
   - Register and you are ready to go

## 🗄️ Database Schema

The application uses the following MySQL tables:

- **users**: User accounts and authentication
- **tasks**: Task information (titles, descriptions, due dates, priorities)
- **categories**: Task categories with custom names and colors

## 🛡️ API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Home page |
| GET | `/login` | Login form |
| POST | `/login` | Authenticate user |
| GET | `/register` | Registration form |
| POST | `/register` | Create new user |
| GET | `/dashboard` | User dashboard |
| GET | `/tasks` | List all tasks |
| POST | `/tasks` | Create/update task |
| GET | `/profile` | User profile |
| POST | `/profile` | Update user password |
| GET | `/logout` | Logout user |
| POST | `/categories` | Create new category |

## 🎨 Customization

### Adding New Features

1. Create a new Servlet in `src/main/java/com/example/taskmanager/controller/`
2. Add the servlet mapping to `web.xml`
3. Create a JSP view in `src/main/webapp/WEB-INF/views/`
4. Update the navigation in the sidebar component

### Styling

The application uses CSS custom properties for easy theming. Modify the `:root` variables in `src/main/webapp/css/style.css`:

```css
:root {
  --primary: #4361ee;
  --secondary: #7209b7;
  --success: #06d6a0;
  --warning: #ffd60a;
  --danger: #ef476f;
  /* Add your custom colors */
}
```

## 🐛 Troubleshooting

### Common Issues

#### 1. 404 Errors / Servlet Not Found
**Symptoms**: Application loads but pages show 404 errors

**Solution**: Check Servlet API compatibility (see Servlet API section above)

#### 2. Database Connection Errors
**Symptoms**: Application starts but can't access data

**Troubleshooting steps**:
```bash
# Check if MySQL container is running
docker ps

# View database logs
docker compose logs db

# Verify database credentials in docker-compose.yml
```

#### 3. Application Won't Start
**Symptoms**: Container fails to start or crashes

**Troubleshooting steps**:
```bash
# Check application logs
docker compose logs app

# Verify Maven build succeeded
mvn clean package -X
```

### Viewing Logs

```bash
# Application logs
docker compose logs app

# Database logs
docker-compose logs db

# All services
docker-compose logs
```


## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.


## 🙏 Acknowledgments

- Apache Tomcat community for excellent documentation
- MySQL team for reliable database engine
- Docker community for containerization best practices

---

**Note**: This README is regularly updated. Please check for the latest version before starting development.
