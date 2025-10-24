pipeline {
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '5', artifactNumToKeepStr: '5'))
    }
    tools {
        maven 'apache-maven-3.9.10'
        jdk 'java_21'
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
                  sh "docker build -t hemantpjry/hello-world:latest ."
                  echo 'Docker Image Build Completed!'
             }
        }
         stage('Docker Image Scanning') {
               steps {
                   echo 'Scanning Docker Image with Trivy...'
                   sh 'trivy image hemantpjry/hello-world:latest || echo "Scan Failed - Proceeding with Caution"'
                   echo 'Docker Image Scanning Completed!'
               }
         }

    }
}