#!/bin/env groovy

pipeline {
    agent {
        kubernetes {
            label 'maven'
        }
    }
    environment {
        IMAGE_NAME = "ghcr.io/rawlingsj/petclinic"
        VERSION = "$env.BUILD_NUMBER"
        //NEXT_VERSION = nextVersion()
    }
    stages {
        stage('Checkout code') {
            steps {
                checkout scm
            }
        }

        stage('Maven build and test') {
            steps {
                container('maven') {
                    sh 'mvn clean install --no-transfer-progress'
                }
            }
        }

        stage('Build image') {
            steps {
                container('kaniko') {
                    sh 'cp /secrets/docker/.dockerconfigjson /kaniko/.docker/config.json'
                    sh "/kaniko/executor --context `pwd` --dockerfile `pwd`/Dockerfile --destination $env.IMAGE_NAME:$env.VERSION"
                }
            }
        }

        stage('Helm lint') {
            steps {
                container('helm'){
                    dir('charts/spring-petclinic'){
                        sh 'helm lint'
                    }
                }
            }
        }

        stage('Helm Package') {
            when {
                branch 'main'
            }
            steps {
                container('helm'){
                    dir('charts/spring-petclinic'){
                        sh "sed -i -e 's/version:.*/version: ${env.VERSION}/' Chart.yaml"
                        sh "sed -i -e 's/tag:.*/tag: ${env.VERSION}/' values.yaml"
                        sh 'cat Chart.yaml'
                        sh 'helm package .'
                        sh 'helm repo index --url https://rawlingsj.github.io/spring-petclinic/ --merge https://rawlingsj.github.io/spring-petclinic/index.yaml .'
                    }
                }
            }
        }

        stage('Helm Publish') {
            when {
                branch 'main'
            }
            steps {
                container('git'){

                    sh 'git clone --branch helm https://github.com/rawlingsj/spring-petclinic.git ../helm-repo'
            
                    sh "cp --force charts/spring-petclinic/spring-petclinic-*.tgz ../helm-repo/"
                    sh "cp --force charts/spring-petclinic/index.yaml ../helm-repo/"

                    dir('../helm-repo'){
                        sh 'git config --global credential.helper store'
                        sh 'git config --global user.email "rawlingsj80@gmail.com"'
                        sh 'git config --global user.name "James Rawlings"'

                        sh 'git add --all'
                        sh "git commit -m 'chore: publish helm chart'"
                        sh 'git push origin helm'
                    }
                }
            }
        }

        stage('Promote with Argo') {
            when {
                branch 'main'
            }
            steps {
                container('git'){
                    sh 'git clone https://github.com/rawlingsj/demo-argo-applications.git ../argo'
                
                    dir('../argo'){
                        sh 'git config --global credential.helper store'
                        sh 'git config --global user.email "rawlingsj80@gmail.com"'
                        sh 'git config --global user.name "James Rawlings"'

                        sh "sed -i -e 's/targetRevision:.*/targetRevision: \"${env.VERSION}\"/' apps/petclinic-application.yaml"

                        sh "git commit -a -m 'chore: promote petclinic v ${env.VERSION}'"
                        sh 'git push origin main'
                    }
                }
            }
        }
    }
}
