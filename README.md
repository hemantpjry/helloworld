# ☁️ Hello World - Spring Boot on GKE  
**End-to-End CI/CD with Jenkins, Docker, Helm, Artifact Registry, Prometheus & Grafana**

This project demonstrates the end-to-end DevOps implementation of a Spring Boot **“Hello World”** application deployed on **Google Kubernetes Engine (GKE)**.  
It covers the complete workflow — from source code build and security scanning to container deployment and real-time monitoring — using a production-grade CI/CD pipeline.

---

## 🚀 Tech Stack Overview

| Category | Tool / Technology |
|-----------|-------------------|
| **Language** | Java 21 |
| **Build Tool** | Apache Maven |
| **CI/CD** | Jenkins Declarative Pipeline |
| **Containerization** | Docker |
| **Image Scanning** | Trivy |
| **Artifact Storage** | Google Artifact Registry |
| **Deployment** | Helm |
| **Orchestration** | Kubernetes (GKE) |
| **Cloud Provider** | Google Cloud Platform (GCP) |
| **Monitoring** | Prometheus, Grafana |
| **Metrics Exporter** | Spring Boot Actuator |

---

## 🧩 CI/CD Pipeline Overview

The Jenkins pipeline automates the entire application lifecycle — from code commit to deployment on GKE.

| Stage | Description |
|--------|--------------|
| **1. Code Compilation** | Compiles Java source using Maven. |
| **2. Unit Testing** | Executes JUnit test cases. |
| **3. Packaging** | Packages the Spring Boot application into a JAR file. |
| **4. Docker Image Build & Tag** | Builds Docker image and tags it with Jenkins build number. |
| **5. Security Scan** | Scans Docker image using Trivy for vulnerabilities. |
| **6. Push to Artifact Registry** | Publishes the secure image to Google Artifact Registry. |
| **7. Deploy to GKE via Helm** | Performs Helm upgrade/install on the GKE cluster. |

---

## ⚙️ CI/CD Trigger Flow

1. Developer pushes code to Bitbucket.  
2. Webhook triggers Jenkins build.  
3. Jenkins executes the pipeline — build, scan, push, deploy.  
4. Application automatically updates in GKE.

---

## 🧱 Jenkinsfile (Key Highlights)

```groovy
pipeline {
    agent any
    environment {
        IMAGE_TAG     = "${BUILD_NUMBER}"
        PROJECT_ID    = 'pollfish-assignment-1-476108'
        REGION        = 'us-central1'
        REPO_NAME     = 'demo-repo'
        IMAGE_NAME    = 'hello-world'
        CLUSTER_NAME  = 'demo-gke-cluster'
        DEPLOY_REGION = 'us-central1'
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }
        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }
        stage('Trivy Scan') {
            steps {
                sh 'trivy image --exit-code 0 --severity HIGH,CRITICAL ${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}'
            }
        }
        stage('Build & Push Image') {
            steps {
                sh '''
                docker build -t us-central1-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG} .
                docker push us-central1-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }
        stage('Deploy to GKE') {
            steps {
                sh '''
                helm upgrade --install hello-world ./helm/hello-world \
                --set image.repository=us-central1-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME} \
                --set image.tag=${IMAGE_TAG}
                '''
            }
        }
    }
}

🐳 Dockerfile
FROM eclipse-temurin:21-jdk
LABEL maintainer="hemanthpoojary27@gmail.com"
RUN useradd -m hello-world
WORKDIR /app
COPY target/helloworld*.jar app.jar
RUN chown -R hello-world:hello-world /app
USER hello-world
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]

✅ Best Practices Followed:
Runs as a non-root user for enhanced security.
Uses a lightweight JDK base image.
Exposes port 8080 for the Spring Boot app.

🧠 Helm Deployment Structure
plaintext

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
Parameter	Value
Namespace	default
Replicas	2
Service Type	LoadBalancer
Service Port	80 → 8080

After deployment:
kubectl get svc hello-world-hello-world
Example Output:
NAME                      TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)        AGE
hello-world-hello-world   LoadBalancer   10.0.75.213      34.63.93.9      80:31943/TCP   5m
Access application:
curl http://34.63.93.9
# Output: Hello World!

🧪 Security Highlights
Integrated Trivy for container vulnerability scanning.
Images stored in private Google Artifact Registry.
Application runs as a non-root user.
Secure CI/CD pipeline using GCP service account authentication.

📈 Monitoring and Observability (Prometheus & Grafana)
To achieve end-to-end observability, Prometheus and Grafana were configured for monitoring both cluster and application-level metrics.

🧩 Monitoring Components
Component	Description
Prometheus Operator	Collects metrics from Kubernetes and the Hello World app.
Grafana	Visualizes real-time metrics and trends.
ServiceMonitor	Defines how Prometheus scrapes app metrics.
Spring Boot Actuator	Exposes /actuator/prometheus metrics endpoint.

🧠 Implementation Steps
1. Deploy Prometheus & Grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
2. Expose Services
Convert service type to LoadBalancer:
kubectl edit svc monitoring-kube-prometheus-prometheus -n monitoring
kubectl edit svc monitoring-grafana -n monitoring
Prometheus UI → http://<prometheus-external-ip>:9090
Grafana UI → http://<grafana-external-ip>:80
3. Create ServiceMonitor
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: hello-world-servicemonitor
  namespace: monitoring
  labels:
    release: monitoring
spec:
  selector:
    matchLabels:
      app: hello-world
  namespaceSelector:
    matchNames:
      - default
  endpoints:
    - port: http
      path: /actuator/prometheus
      interval: 15s
Apply:
kubectl apply -f hello-world-servicemonitor.yaml
4. Verify Metrics Collection
In Prometheus → Status → Targets → ensure hello-world target is UP.
Metrics include JVM, CPU, memory, and HTTP request data.

5. Grafana Visualization
Prometheus is configured as the data source.
Import dashboard from Grafana.com — e.g., Dashboard ID: 4701 (Spring Boot Statistics).
Visual panels include:
Application uptime
Request rate
JVM heap usage
CPU & memory metrics

✅ Outcome
Real-time visibility into application health and performance.
Prometheus scrapes /actuator/prometheus metrics successfully.
Grafana dashboards confirm end-to-end monitoring integration.

🧭 Architecture Flow


Developer Commit → Jenkins CI/CD → Maven Build → Trivy Scan
      ↓
Google Artifact Registry (Docker Image Storage)
      ↓
Helm Deploy → GKE Cluster → LoadBalancer Service (Hello World App)
      ↓
Prometheus (Metrics Scraping) → Grafana (Visualization Dashboard)

👨‍💻 Author
Hemanth Poojary
📧 hemanthpoojary27@gmail.com
