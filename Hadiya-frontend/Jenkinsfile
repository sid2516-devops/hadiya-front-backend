pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPO_URI = '909325007152.dkr.ecr.us-east-1.amazonaws.com/hadiya-dev-frontend'
        TASK_DEFINITION_NAME = 'hadiya-frontend'
        CLUSTER_NAME = 'hadiya-dev-frontend-cluster'
        SERVICE_NAME = 'hadiya-frontend-service'
        CONTAINER_NAME = 'hadiya-dev-frontend'
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout from Git') {
            steps {
                git branch: 'main', url: 'https://github.com/Himanshu-0711/hadiya-front/'
            }
        }

        stage("Docker Build and Push to ECR") {
            steps {
                withCredentials([aws(credentialsId: 'Credentials')]) {
                    script {
                        // Build the Docker image
                        sh "docker build -t ${ECR_REPO_URI}:latest ."
                        
                        // Log in to ECR
                        sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO_URI}"
                        
                        // Push the Docker image to ECR
                        sh "docker push ${ECR_REPO_URI}:latest"
                    }
                }
            }
        }

        stage('Register Task Definition Revision') {
            steps {
                 withCredentials([aws(credentialsId: 'Credentials')]) {
                    script {
                        def taskDefinitionJson = """
                        {
                            "family": "${TASK_DEFINITION_NAME}",
                            "executionRoleArn": "arn:aws:iam::909325007152:role/ecsTaskExecutionRole",
                            "networkMode": "awsvpc",
                            "containerDefinitions": [
                                {
                                    "name": "${CONTAINER_NAME}",
                                    "image": "${ECR_REPO_URI}:latest",
                                    "cpu": 0,
                                    "portMappings": [
                                        {
                                            "containerPort": 80,
                                            "hostPort": 80,
                                            "protocol": "tcp",
                                            "name": "nginx",
                                            "appProtocol": "http"
                                        }
                                    ],
                                    "essential": true,
                                    "environment": [],
                                    "environmentFiles": [],
                                    "mountPoints": [],
                                    "volumesFrom": [],
                                    "ulimits": [],
                                    "logConfiguration": {
                                        "logDriver": "awslogs",
                                        "options": {
                                            "awslogs-group": "/ecs/${TASK_DEFINITION_NAME}",
                                            "awslogs-create-group": "true",
                                            "awslogs-region": "${AWS_REGION}",
                                            "awslogs-stream-prefix": "ecs"
                                        },
                                        "secretOptions": []
                                    },
                                    "systemControls": []
                                }
                            ],
                            "requiresCompatibilities": [
                                "FARGATE"
                            ],
                            "cpu": "2048",
                            "memory": "5120"
                        }
                        """
                        
                        // Register a new task definition revision
                        def registerTaskDefCmd = "aws ecs register-task-definition --cli-input-json '${taskDefinitionJson.replaceAll("'", "\\\\'")}' --region ${AWS_REGION}"
                        sh script: registerTaskDefCmd
                    }
                }
            }
        }

        stage('Update ECS Service') {
            steps {
                withCredentials([aws(credentialsId: 'Credentials')]) {
                    script {
                        // Get the new task definition ARN
                        def newTaskDefinitionArn = sh(script: "aws ecs describe-task-definition --task-definition ${TASK_DEFINITION_NAME} --region ${AWS_REGION} | jq -r '.taskDefinition.taskDefinitionArn'", returnStdout: true).trim()

                        // Update the ECS service to use the new task definition revision
                        sh """
                        aws ecs update-service --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} --task-definition ${newTaskDefinitionArn} --region ${AWS_REGION}
                        """
                    }
                }
            }
        }
    }
}
