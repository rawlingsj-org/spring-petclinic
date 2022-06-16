#!/bin/env groovy

pipeline {
    agent {
        kubernetes {
            label 'maven'
        }
    }
    environment {
        IMAGE_NAME = "ghcr.io/rawlingsj/petclinic"
        USER_EMAIL = "rawlingsj80@gmail.com"
        USER_NAME = "James Rawlings"
    }
    stages {
        stage('Init') {
            steps {
                script {
                    if (changeRequest()) {
                        // BRANCH_NAME
                        env.VERSION = "${env.BRANCH_NAME}"
                    } else if (buildingTag()) {
                        // TAG_NAME
                        env.VERSION = "${env.TAG_NAME}"
                    } else {
                        // BRANCH_NAME.BUILD_NUMBER
                        env.VERSION = "${env.BRANCH_NAME}.${env.BUILD_NUMBER}"
                    }
                }
            }
	}

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

        stage('Helm lint') {
            steps {
                container('helm'){
                    dir('charts/spring-petclinic'){
                        sh 'helm lint'
                    }
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

        stage('Helm Package') {
            when {
                or {
                    branch 'main'
                    buildingTag()
                }
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
                or {
                    branch 'main'
                    buildingTag()
                }
            }
            steps {
                container('git'){

                    sh 'git clone --branch helm https://github.com/rawlingsj/spring-petclinic.git ../helm-repo'
            
                    sh "cp --force charts/spring-petclinic/spring-petclinic-*.tgz ../helm-repo/"
                    sh "cp --force charts/spring-petclinic/index.yaml ../helm-repo/"

                    dir('../helm-repo'){
                        sh 'git config --global credential.helper store'
                        sh "git config --global user.email '$env.USER_EMAIL'"
                        sh "git config --global user.name '$env.USER_NAME'"

                        sh 'git add --all'
                        sh "git commit -m 'chore: publish helm chart'"
                        sh 'git push origin helm'
                    }
                }
            }
        }

        stage('Promote with Argo') {
            when {
                or {
                    branch 'main'
                    buildingTag()
                }
            }
            steps {
                container('git'){
                    sh 'git clone https://github.com/rawlingsj/demo-argo-applications.git ../argo'
                
                    dir('../argo'){
                        sh 'git config --global credential.helper store'
                        sh "git config --global user.email '$env.USER_EMAIL'"
                        sh "git config --global user.name '$env.USER_NAME'"

                        sh "sed -i -e 's/targetRevision:.*/targetRevision: \"${env.VERSION}\"/' apps/petclinic-application.yaml"

                        sh "git commit -a -m 'chore: promote petclinic v ${env.VERSION}'"
                        sh 'git push origin main'
                    }
                }
            }
        }
    }
}
