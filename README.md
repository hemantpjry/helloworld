# ☁️ Hello World - Spring Boot on GKE (CI/CD with Jenkins, Docker, Helm & Artifact Registry)

A simple **Spring Boot "Hello World" application** deployed on **Google Kubernetes Engine (GKE)** using a complete **CI/CD pipeline** built with **Jenkins**, **Docker**, **Helm**, **Trivy**, and **Artifact Registry**.

This project demonstrates a **production-style DevOps workflow**, covering source build, image scanning, artifact publishing, and automated deployment to Kubernetes.

---

## 🚀 Tech Stack

| Category | Tool / Technology |
|-----------|-------------------|
| Language | Java 21 |
| Build Tool | Apache Maven |
| CI/CD | Jenkins Declarative Pipeline |
| Containerization | Docker |
| Image Scanning | Trivy |
| Artifact Storage | Google Artifact Registry |
| Deployment | Helm |
| Orchestration | Kubernetes (GKE) |
| Cloud Provider | Google Cloud Platform (GCP) |

---

## 🧩 CI/CD Pipeline Overview

The Jenkins pipeline automates the complete lifecycle:

| Stage | Description |
|--------|-------------|
| **1. Code Compilation** | Compiles the Java source using Maven. |
| **2. Code QA Execution** | Runs unit tests via JUnit. |
| **3. Code Packaging** | Packages the application into a JAR artifact. |
| **4. Build & Tag Docker Image** | Builds Docker image using the project’s Dockerfile and tags with the Jenkins build number. |
| **5. Docker Image Scanning** | Performs security scan on the image using Trivy. |
| **6. Push to Artifact Registry** | Authenticates to GCP and pushes the image to Artifact Registry. |
| **7. Deploy to GKE using Helm** | Deploys or upgrades the release in GKE using Helm. |

### ✅ Trigger
Pipeline runs automatically on every code push via Bitbucket → Jenkins webhook.

---

## 🐳 Dockerfile

```dockerfile
FROM eclipse-temurin:21-jdk
LABEL maintainer="hemanthpoojary27@gmail.com"
RUN useradd -m hello-world
WORKDIR /app
COPY target/helloworld*.jar app.jar
RUN chown -R hello-world:hello-world /app
USER hello-world
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]

Uses non-root user (hello-world) for security.
Packages Spring Boot JAR into lightweight JDK 21 base image.
Exposes port 8080 for application access.

🧠 Helm Deployment Structure
bash
Copy code
helm/
└── hello-world/
    ├── templates/
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   └── _helpers.tpl
    ├── Chart.yaml
    └── values.yaml

Example: values.yaml
replicaCount: 2
image:
  repository: us-central1-docker.pkg.dev/pollfish-assignment-1-476108/demo-repo/hello-world
  tag: ""
  pullPolicy: Always
service:
  type: LoadBalancer
  port: 80
  targetPort: 8080
resources: {}

☸️ Kubernetes Deployment Summary
Type: LoadBalancer
Replicas: 2
Namespace: default
Service Port: 80 → 8080

Access the app after deployment:
kubectl get svc hello-world-hello-world
Example output:
NAME                      TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)        AGE
hello-world-hello-world   LoadBalancer   10.0.75.213      34.63.93.9      80:31943/TCP   5m

Test in browser or curl:
curl http://34.63.93.9
# Output: Hello World!

⚙️ Jenkinsfile (Key Highlights)
Uses Maven for build/test/package
Scans Docker images with Trivy
Authenticates and pushes to Artifact Registry
Deploys with Helm upgrade/install to GKE

Environment variables:
environment {
    IMAGE_TAG = "${BUILD_NUMBER}"
    PROJECT_ID = 'pollfish-assignment-1-476108'
    REGION     = 'us-central1'
    REPO_NAME  = 'demo-repo'
    IMAGE_NAME = 'hello-world'
    CLUSTER_NAME = 'demo-gke-cluster'
    DEPLOY_REGION = 'us-central1'
}

🧪 Security
Docker image scanning integrated via Trivy
Non-root user used inside Docker container
Artifact hosted in private GCP Artifact Registry

📈 Project Highlights
✅ Fully automated CI/CD pipeline
✅ Secure image scanning before deployment
✅ Dynamic tagging via Jenkins build number
✅ Infrastructure-as-Code via Helm & Kubernetes
✅ End-to-end cloud-native deployment on GKE


🏗️ Future Enhancements
Integrate SonarQube for code quality analysis
Add Slack notification for build/deployment status
Implement Blue/Green or Canary deployments via Helm

📊 Architecture Overview 

Developer Commit → Jenkins CI/CD → Docker Build → Trivy Scan
           ↓
   Google Artifact Registry
           ↓
   Helm Deploy → GKE Cluster → LoadBalancer Service → Browser
