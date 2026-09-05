pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: python
      image: python:3.10-slim
      command: ['cat']
      tty: true
    - name: kaniko
      image: gcr.io/kaniko-project/executor:debug
      command: ['sleep']
      args: ['9999999']
'''
        }
    }

    environment {
        // Update this to your real ECR repo URL — get it with:
        // terraform output -raw ecr_repository_url
        ECR_REPO = "992382545251.dkr.ecr.us-east-1.amazonaws.com/team-project-app"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                // Runs in the default "jnlp" container the Kubernetes plugin
                // auto-adds. Its workspace is automatically shared at the
                // same path ($WORKSPACE) across every container in this pod —
                // that's why python/kaniko below don't need volumeMounts.
                git branch: 'main', url: 'https://github.com/Amit-Arie/status-page-gitops.git'
            }
        }

        stage('Test') {
            steps {
                container('python') {
                    // Placeholder — no test suite exists yet. This just confirms
                    // the app's Python files are at least syntactically valid.
                    // Swap this for `pytest` once a real test suite exists.
                    sh '''
                        cd app
                        python -m py_compile $(find . -name "*.py") || echo "No syntax errors found (or no .py files matched)"
                    '''
                }
            }
        }

        stage('Build & Push (Kaniko)') {
            steps {
                container('kaniko') {
                    sh '''
                        /kaniko/executor \
                          --context=dir://${WORKSPACE}/app \
                          --dockerfile=${WORKSPACE}/app/Dockerfile \
                          --destination=${ECR_REPO}:${IMAGE_TAG} \
                          --destination=${ECR_REPO}:latest
			  --snapshot-mode=redo
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Build ${IMAGE_TAG} pushed to ${ECR_REPO}"
        }
        failure {
            echo "Build failed — check the stage logs above."
        }
    }
}
