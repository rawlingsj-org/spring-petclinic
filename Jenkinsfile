#!/bin/env groovy

podTemplate {
    node('maven') {
        stage('Checkout code') {
          checkout scm
        }
        
        stage('Maven build and test') {
            container('maven'){
              
              sh 'mvn clean install'
            }
        }

        stage('Build image') {
            container('kaniko'){

              sh 'cp /secrets/docker/.dockerconfigjson /kaniko/.docker/config.json'
              sh '/kaniko/executor --context `pwd` --dockerfile `pwd`/Dockerfile --destination ghcr.io/rawlingsj/petclinic:$BUILD_NUMBER'
            }
        }
    }
}