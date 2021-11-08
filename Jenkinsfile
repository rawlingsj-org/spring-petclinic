#!/bin/env groovy

podTemplate {
    node('maven') {
        stage('Checkout code') {
          checkout scm
        }
        
        // stage('Maven build and test') {
        //     container('maven'){
        //       sh 'mvn clean install'
        //     }
        // }

        // stage('Build image') {
        //     container('kaniko'){
        //       sh 'cp /secrets/docker/.dockerconfigjson /kaniko/.docker/config.json'
        //       sh '/kaniko/executor --context `pwd` --dockerfile `pwd`/Dockerfile --destination ghcr.io/rawlingsj/petclinic:$BRANCH_NAME-$BUILD_NUMBER'
        //     }
        // }

        // stage('Helm lint') {
        //     container('helm'){
        //       dir('charts/spring-petclinic'){
        //         sh 'helm lint'
        //       }
        //     }
        // }

        stage('Helm Package') {
            container('helm'){
              dir('charts/spring-petclinic'){
                sh 'helm repo index --url https://rawlingsj.github.io/spring-petclinic/ .'
                sh 'helm package .'
              }
            }
        }

        stage('Helm Publish') {
          // environment {
          //   GIT_CREDS = credentials('git')
          // }
          container('git'){

            // sh 'sleep infinity'
            sh 'git config credential.helper store'
            sh 'git config --global user.email "rawlingsj80@gmail.com"'
            sh 'git config --global user.name "James Rawlings"'
            
            sh 'git checkout -b tmp'
            sh 'git add charts/spring-petclinic'
            sh "git commit -m 'chore: publish helm chart'"
            sh 'git push origin tmp:helm'
          }
        }
    }
}