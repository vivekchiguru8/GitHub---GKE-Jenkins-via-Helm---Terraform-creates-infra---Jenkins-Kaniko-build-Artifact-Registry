pipeline {
  agent {
    kubernetes {
      yaml '''
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins
  containers:
    - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command: ["/busybox/cat"]
    tty: true
    - name: gcloud
    image: google/cloud-sdk:alpine
    command: ["cat"]
    tty: true
'''
    }
  }
  environment {
    PROJECT_ID = "project-10094705-9153-43d5-bb8"
    REGISTRY = "asia-south1-docker.pkg.dev/project-10094705-9153-43d5-bb8/my-app-repo-v2/go-app"
    CLUSTER = "my-go-cluster-v2"
    ZONE = "asia-south1-a"
  }
  stages {
    stage('Build & Push Kaniko') {
      steps {
        container('kaniko') {
          sh '/kaniko/executor --context=`pwd` --dockerfile=`pwd`/Dockerfile --destination=$REGISTRY:$BUILD_NUMBER --destination=$REGISTRY:latest --cache=true'
        }
      }
    }
    stage('Deploy to GKE') {
      steps {
        container('gcloud') {
          sh '''
            gcloud container clusters get-credentials $CLUSTER --zone $ZONE --project $PROJECT_ID
            kubectl create namespace go-app --dry-run=client -o yaml | kubectl apply -f -
            kubectl -n go-app set image deployment/go-app go-app=$REGISTRY:$BUILD_NUMBER --record 2>/dev/null || kubectl -n go-app create deployment go-app --image=$REGISTRY:$BUILD_NUMBER
            kubectl -n go-app expose deployment go-app --type=LoadBalancer --port=80 --target-port=8080 --name=go-app-service --dry-run=client -o yaml | kubectl apply -f -
            kubectl rollout status deployment/go-app -n go-app
          '''
        }
      }
    }
  }
}