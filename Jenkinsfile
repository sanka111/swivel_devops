pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "galappaththi111/devops-challenge-salesapi"
        SSH_KEY = credentials('SWIVEL_SSH')
        EC2_USER = 'ec2-user'
        SERVER_IP = '54.251.25.60'
        APPLICATION_NAME = 'salesapi'
        DOCKER_CREDENTIALS_ID = credentials('docker-credentials')
        DB_ACCESS = credentials('swivel_db_access')
        DOCKERHUB_USR = 'galappaththi111'
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Start Checkout"
                git url: 'https://github.com/sanka111/sw_test.git', branch: 'develop', credentialsId: 'github_jenkinapp-sanka'
                echo "End Checkout"
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t ${APPLICATION_NAME}:${BUILD_TAG} .'
                echo "End Build"
                
            }
        }

        stage('Login to Dokcer Hub') {
            steps {
                sh 'docker login -u ${DOCKER_CREDENTIALS_ID_USR} -p ${DOCKER_CREDENTIALS_ID_PSW}'
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    sh 'docker tag ${APPLICATION_NAME}:${BUILD_TAG} $DOCKER_IMAGE:${BUILD_TAG}'
                    sh 'docker push $DOCKER_IMAGE:${BUILD_TAG}'
                    echo "End dokcer login"
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    withCredentials(bindings: [sshUserPrivateKey(credentialsId: 'SWIVEL_SSH', \
                                             keyFileVariable: 'SSH_KEY_SWIVEL')]) {
                                                // SSH into EC2 and pull & run Docker image
                                                sh '''
                                                ssh -i ${SSH_KEY_SWIVEL} -o StrictHostKeyChecking=no ${EC2_USER}@${SERVER_IP} << EOF
                                                sudo docker pull ${DOCKER_IMAGE}:${BUILD_TAG}

                                                if [ -z "\$(sudo docker ps -aq -f name=${APPLICATION_NAME})" ]; then
                                                    echo "Stopping and removing the existing container..."
                                                    sudo docker stop ${APPLICATION_NAME}
                                                    sudo docker rm ${APPLICATION_NAME}
                                                else
                                                    echo "No running container found with the name ${APPLICATION_NAME}."
                                                fi
                                                #sudo docker run -d --name ${APPLICATION_NAME} -p 80:80 -e DB_USERNAME=${DB_ACCESS_USR} -e DB_PASSWORD=${DB_ACCESS_PSW} -e SERVER_IP=${SERVER_IP} ${DOCKER_IMAGE}:${BUILD_TAG}
                                                sudo docker run -d --name ${APPLICATION_NAME} -p 80:80 -e CONNECTIONSTRINGS__DATABASE="Server=${SERVER_IP},1433;Database=DevOpsChallenge.SalesApi;User Id=${DB_ACCESS_USR};Password=${DB_ACCESS_PSW};" ${DOCKER_IMAGE}:${BUILD_TAG}
                                                exit 0
                                                EOF
                                                '''
                                            }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}