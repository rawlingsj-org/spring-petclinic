#!/bin/env groovy

podTemplate {
    node('maven') {
      stage('Checkout code') {
        checkout scm
      }
      
      // should generate a proper release version using git tags, something like https://github.com/jenkins-x-plugins/jx-release-version
      def version = env.BUILD_NUMBER

      stage('Maven build and test') {
          container('maven'){
            sh 'mvn clean install --no-transfer-progress'
          }
      }

      stage('Build image') {
          container('kaniko'){
            sh 'cp /secrets/docker/.dockerconfigjson /kaniko/.docker/config.json'
            sh "/kaniko/executor --context `pwd` --dockerfile `pwd`/Dockerfile --destination ghcr.io/rawlingsj/petclinic:${version}"
          }
      }

      stage('Helm lint') {
          container('helm'){
            dir('charts/spring-petclinic'){
              sh 'helm lint'
            }
          }
      }

      if(env.BRANCH_NAME == 'main'){

        stage('Helm Package') {
            container('helm'){
              dir('charts/spring-petclinic'){
                sh "sed -i -e 's/version:.*/version: ${version}/' Chart.yaml"
                sh "sed -i -e 's/tag:.*/tag: ${version}/' values.yaml"
                sh 'cat Chart.yaml'
                sh 'helm package .'
                sh 'helm repo index --url https://rawlingsj.github.io/spring-petclinic/ --merge https://rawlingsj.github.io/spring-petclinic/index.yaml .'
              }
            }
        }

        stage('Helm Publish') {

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

        stage('Promote with Argo') {

          container('git'){

            sh 'git clone https://github.com/rawlingsj/demo-argo-applications.git ../argo'

            dir('../argo'){
              sh 'git config --global credential.helper store'
              sh 'git config --global user.email "rawlingsj80@gmail.com"'
              sh 'git config --global user.name "James Rawlings"'

              sh "sed -i -e 's/targetRevision:.*/targetRevision: \"${version}\"/' apps/petclinic-application.yaml"

              sh "git commit -a -m 'chore: promote petclinic v ${version}'"
              sh 'git push origin main'
            }
          }
        }
      }

    }
}
