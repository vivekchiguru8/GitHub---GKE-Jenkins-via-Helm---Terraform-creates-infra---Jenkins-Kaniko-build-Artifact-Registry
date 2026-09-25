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
    - name: gcloud
      image: google/cloud-sdk:alpine
      command:
        - cat
      tty: true
"""
    }
  }
  environment {
    PROJECT_ID = "project-10094705-9153-43d5-bb8"
    REGISTRY = "asia-south1-docker.pkg.dev/project-10094705-9153-43d5-bb8/my-app-repo-v2/go-app"
    CLUSTER = "my-go-cluster-v2"
    ZONE = "asia-south1-a"
  }
  stages {
    stage('Build and Push') {
      steps {
        container('kaniko') {
          sh "/kaniko/executor --context=`pwd` --dockerfile=`pwd`/Dockerfile --destination=${REGISTRY}:latest --cache=true --verbosity=info"
        }
      }
    }
    stage('Deploy') {
      steps {
        container('gcloud') {
          sh """
            gcloud container clusters get-credentials ${CLUSTER} --zone ${ZONE} --project ${PROJECT_ID}
            kubectl rollout restart deployment go-app -n go-app
          """
        }
      }
    }
  }
}