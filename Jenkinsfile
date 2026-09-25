pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:debug
      command:
        - /busybox/cat
      tty: true
      volumeMounts:
        - name: docker-config
          mountPath: /kaniko/.docker
    - name: gcloud
      image: google/cloud-sdk:alpine
      command:
        - cat
      tty: true
  volumes:
    - name: docker-config
      secret:
        secretName: regcred
        items:
          - key: .dockerconfigjson
            path: config.json
"""
    }
  }
  environment {
    PROJECT_ID = "project-10094705-9153-43d5-bb8"
    REGISTRY = "asia-south1-docker.pkg.dev/project-10094705-9153-43d5-bb8/my-app-repo-v2/go-app"
    CLUSTER = "my-gke-cluster-v2"
  }
  stages {
    stage('Build and Push') {
      steps {
        container('kaniko') {
          sh "/kaniko/executor --context=`pwd` --dockerfile=`pwd`/Dockerfile --destination=${REGISTRY}:latest --cache=true"
        }
      }
    }
    stage('Deploy') {
      steps {
        container('gcloud') {
          sh """
            gcloud container clusters get-credentials ${CLUSTER} --region asia-south1 --project ${PROJECT_ID}
            kubectl rollout restart deployment go-app -n go-app
          """
        }
      }
    }
  }
}