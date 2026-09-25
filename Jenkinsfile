podTemplate(serviceAccountName: 'jenkins', containers: [
  containerTemplate(name: 'kaniko', image: 'gcr.io/kaniko-project/executor:debug', command: '/busybox/cat', ttyEnabled: true),
  containerTemplate(name: 'gcloud', image: 'google/cloud-sdk:alpine', command: 'cat', ttyEnabled: true)
]) {
  node(POD_LABEL) {
    def PROJECT = "project-10094705-9153-43d5-bb8"
    def REGISTRY = "asia-south1-docker.pkg.dev/project-10094705-9153-43d5-bb8/my-app-repo-v2/go-app"
    def CLUSTER = "my-go-cluster-v2"
    def ZONE = "asia-south1-a"

    stage('Checkout') {
      git url: 'https://github.com/vivekchiguru8/GitHub---GKE-Jenkins-via-Helm---Terraform-creates-infra---Jenkins-Kaniko-build-Artifact-Registry.git', branch: 'main'
    }

    stage('Build and Push') {
      container('kaniko') {
        sh "/kaniko/executor --context=dir://${env.PWD} --dockerfile=Dockerfile --destination=${REGISTRY}:latest --cache=true --verbosity=info"
      }
    }

    stage('Deploy') {
      container('gcloud') {
        sh """
          gcloud container clusters get-credentials ${CLUSTER} --zone ${ZONE} --project ${PROJECT}
          kubectl set image deployment/go-app go-app=${REGISTRY}:latest -n go-app --record
          kubectl rollout status deployment/go-app -n go-app
        """
      }
    }
  }
}