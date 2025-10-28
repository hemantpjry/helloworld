pipeline {
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '5', artifactNumToKeepStr: '5'))
    }
    tools {
        maven 'apache-maven-3.9.10'
        jdk 'java_21'
    }
        environment {
            IMAGE_TAG = "${BUILD_NUMBER}"
            PROJECT_ID = 'pollfish-assignment-1-476108'
            REGION     = 'us-central1'  // update if needed
            REPO_NAME  = 'demo-repo' // your Artifact Registry repo name
            IMAGE_NAME = 'hello-world'
            CLUSTER_NAME = 'demo-gke-cluster'
            DEPLOY_REGION = 'us-central1'
        }
    stages {
        stage('Code Compilation') {
            steps {
                echo 'Starting Code Compilation...'
                sh 'mvn clean compile'
                echo 'Code Compilation Completed Successfully!'
            }
        }
        stage('Code QA Execution') {
            steps {
                echo 'Running JUnit Test Cases...'
                sh 'mvn clean test'
                echo 'Hi.. JUnit Test Cases Completed Successfully!'
            }
        }
        stage('Code Package') {
            steps {
                echo 'Creating WAR Artifact...'
                sh 'mvn clean package'
                echo 'WAR Artifact Created Successfully!'
            }
        }
        stage('Build & Tag Docker Image') {
              steps {
                  echo 'Building Docker Image with Tags...'
                  sh '''
                       docker build -t $IMAGE_NAME:$IMAGE_TAG .
                  '''
             }
        }
         stage('Docker Image Scanning') {
               steps {
                   echo "Scanning Docker Image: $IMAGE_NAME:$IMAGE_TAG"
                   sh '''
                       trivy image $IMAGE_NAME:$IMAGE_TAG || echo "Scan Failed - Proceeding with Caution"
                   '''
                   echo 'Docker Image Scanning Completed!'
               }
         }
        stage('Authenticate & Push to Artifact Registry') {
                    steps {
                        withCredentials([file(credentialsId: 'gcp-sa-key', variable: 'GOOGLE_CREDENTIALS')]) {
                            sh '''
                                echo "Authenticating to GCP..."
                                gcloud auth activate-service-account --key-file=$GOOGLE_CREDENTIALS
                                gcloud config set project $PROJECT_ID
                                gcloud auth configure-docker $REGION-docker.pkg.dev -q

                                echo "Tagging and pushing image to Artifact Registry..."
                                docker tag $IMAGE_NAME:latest $REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$IMAGE_NAME:$IMAGE_TAG
                                docker push $REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$IMAGE_NAME:$IMAGE_TAG

                                echo "Image pushed successfully!"
                            '''
                        }
                    }
                }
                stage('Deploy to GKE using Helm') {
                            steps {
                                withCredentials([file(credentialsId: 'gcp-sa-key', variable: 'GOOGLE_CREDENTIALS')]) {
                                    sh '''
                                        echo "Authenticating to GCP..."
                                        gcloud auth activate-service-account --key-file=$GOOGLE_CREDENTIALS
                                        gcloud config set project $PROJECT_ID

                                        echo "Fetching GKE credentials..."
                                        gcloud container clusters get-credentials $CLUSTER_NAME --region $DEPLOY_REGION

                                        echo "Deploying to GKE with Helm..."
                                        helm upgrade --install hello-world ./helm/hello-world \
                                            --set image.repository=$REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$IMAGE_NAME \
                                            --set image.tag=$IMAGE_TAG \
                                            --set service.type=LoadBalancer \
                                            --namespace default \
                                            --create-namespace

                                        echo "Deployment Successful!"
                                    '''
                                }
                            }
                        }
    }
}