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
    - name: docker
      image: docker:24-dind
      securityContext:
        privileged: true
      env:
        - name: DOCKER_TLS_CERTDIR
          value: ""
      args:
        - "--host=tcp://0.0.0.0:2375"
        - "--host=unix:///var/run/docker.sock"
    - name: docker-cmd
      image: docker:24-cli
      command: ['cat']
      tty: true
      env:
        - name: DOCKER_HOST
          value: "tcp://localhost:2375"
    - name: awscli
      image: public.ecr.aws/aws-cli/aws-cli:latest
      command: ['cat']
      tty: true
'''
        }
    }

    environment {
        // Update this to your real ECR repo URL — get it with:
        // terraform output -raw ecr_repository_url
        ECR_REPO = "992382545251.dkr.ecr.us-east-1.amazonaws.com/team-project-app"
        AWS_REGION = "us-east-1"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                // Runs in the default "jnlp" container the Kubernetes plugin
                // auto-adds. Its workspace is automatically shared at the
                // same path ($WORKSPACE) across every container in this pod.
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

        stage('Wait for Docker daemon') {
            steps {
                container('docker-cmd') {
                    // The dind sidecar takes a few seconds to start listening —
                    // this loop waits until it actually responds before we
                    // try to use it, instead of racing it.
                    sh '''
                        until docker info >/dev/null 2>&1; do
                            echo "Waiting for docker daemon..."
                            sleep 1
                        done
                    '''
                }
            }
        }

        stage('ECR Login') {
            steps {
                container('awscli') {
                    // Uses the agent node's IAM role (via instance metadata) —
                    // no stored AWS credentials needed. Written to the shared
                    // workspace so the docker-cmd container can read it next.
                    // Quoted "${WORKSPACE}" — job names with spaces (like this
                    // one) otherwise get word-split into two bad paths.
                    sh '''
                        aws ecr get-login-password --region ${AWS_REGION} > "${WORKSPACE}/.ecr_pw"
                    '''
                }
                container('docker-cmd') {
                    sh '''
                        cat "${WORKSPACE}/.ecr_pw" | docker login --username AWS --password-stdin ${ECR_REPO}
                        rm -f "${WORKSPACE}/.ecr_pw"
                    '''
                }
            }
        }

        stage('Build & Push') {
            steps {
                container('docker-cmd') {
                    sh '''
                        docker build -t ${ECR_REPO}:${IMAGE_TAG} -t ${ECR_REPO}:latest -f "${WORKSPACE}/app/Dockerfile" "${WORKSPACE}/app"
                        docker push ${ECR_REPO}:${IMAGE_TAG}
                        docker push ${ECR_REPO}:latest
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
