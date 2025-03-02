    pipeline {
        agent any
        
        environment {
            AWS_REGION = 'us-east-1'
            AWS_ACCOUNT_ID = '727366105259'
            APP_NAME = 'react-app'
            GIT_REPO_URL = 'https://github.com/patturi-nvn/demo-project-1.git'
            
            // ECR repositories for different stages
            ECR_BASE = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
            DEV_ECR_REPO = "${ECR_BASE}/${APP_NAME}-dev"
            STAGING_ECR_REPO = "${ECR_BASE}/${APP_NAME}-staging"
            PROD_ECR_REPO = "${ECR_BASE}/${APP_NAME}-prod"
            
            // AWS credentials
            AWS_CREDS = credentials('AWS-Creds')
            // Git credentials
            GIT_CREDS = credentials('GIT-Creds')
        }
        
        parameters {
            choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Select deployment environment')
        }

        stages {
            stage('Configure AWS') {
                steps {
                    script {
                        // Verify AWS CLI configuration
                        sh 'aws sts get-caller-identity'
                    }
                }
            }

            stage('Setup ECR and Docker') {
                steps {
                    script {
                        // Verify Docker installation
                        sh 'docker --version'
                        
                        // Create ECR repositories for all environments if they don't exist
                        def environments = ['dev', 'staging', 'prod']
                        environments.each { env ->
                            def repoName = "${APP_NAME}-${env}"
                            sh """
                                if ! aws ecr describe-repositories --repository-names ${repoName} 2>/dev/null; then
                                    echo "Creating ECR repository: ${repoName}"
                                    aws ecr create-repository --repository-name ${repoName}
                                fi
                            """
                        }
                        
                        // Login to ECR
                        sh """
                            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_BASE}
                        """
                    }
                }
            }
            
            stage('Build and Test') {
                steps {
                    script {
                        // Clean workspace and clone repository with credentials
                        cleanWs()
                        git credentialsId: 'GIT-Creds', 
                            url: "${GIT_REPO_URL}",
                            branch: 'main'
                        
                        // List repository contents for debugging
                        sh '''
                            echo "Current directory contents:"
                            ls -la
                            
                            # Install Node.js if not present
                            if ! command -v node &> /dev/null; then
                                # Amazon Linux Node.js installation
                                curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
                                . ~/.nvm/nvm.sh
                                nvm install 18
                                nvm use 18
                            fi
                            
                            # Verify versions
                            node --version
                            npm --version
                            
                            # If the repository is empty or missing React files, create a new React app
                            if [ ! -f "package.json" ] || [ ! -d "public" ]; then
                                echo "Creating new React application..."
                                npx create-react-app .
                            fi
                            
                            # Install dependencies and build
                            if [ -f "package-lock.json" ]; then
                                echo "Using package-lock.json"
                                npm ci
                            else
                                echo "No package-lock.json found, using npm install"
                                npm install
                            fi
                            
                            npm run build
                            npm test
                        '''
                    }
                }
            }
            
            stage('Build and Push Docker Image') {
                steps {
                    script {
                        def envName = params.ENVIRONMENT ?: 'dev'
                        def ecrRepo = "${ECR_BASE}/${APP_NAME}-${envName}"
                        def imageTag = env.GIT_COMMIT ? env.GIT_COMMIT.take(8) : env.BUILD_NUMBER
                        
                        // Build and push Docker images with specific tag and latest
                        sh """
                            docker build -t ${ecrRepo}:${imageTag} .
                            docker tag ${ecrRepo}:${imageTag} ${ecrRepo}:latest
                            docker push ${ecrRepo}:${imageTag}
                            docker push ${ecrRepo}:latest
                        """
                    }
                }
            }

                // - TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition "$ECS_TASK_DEFINITION_NAME")
                // - NEW_CONTAINER_DEFINITION=$(echo $TASK_DEFINITION | jq --arg IMAGE "$ECR_URL:$IMAGE_TAG" '.taskDefinition.containerDefinitions[0].image = $IMAGE | .taskDefinition.containerDefinitions[0]')
                // - aws ecs register-task-definition --family "$ECS_TASK_DEFINITION_NAME" --container-definitions "$NEW_CONTAINER_DEFINITION"
                // - aws ecs update-service --cluster "$ECS_CLUSTER_NAME" --service "$ECS_SERVICE_NAME" --task-definition "$ECS_TASK_DEFINITION_NAME"
        }
    }