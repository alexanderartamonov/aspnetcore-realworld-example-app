@Library('2c2p_jenkins_shared_libraries@develop') _
def CVER_DEFAULT='0.0.0'
def BUILD_NUMBER_UUID = Calendar.getInstance().getTime().format('YYYYMMddhhmmssSSS',TimeZone.getTimeZone('UTC+7:00'))

def getVars(project, env) {
  switch(project) {
    case "CARDRANGESERVICE":
      switch(env) {
        case "SIT":
          return [
                  aws_account_id: "${THREEDS_UAT_AWS_ACCOUNT_ID}", 
                  aws_iam_role_name: "eks_uat_2c2p-management-jenkins-emvacs-pod_PodRole", 
                  argocd_app_name: "emv3dscardrange", 
                  argocd_token: "${CLUSTER_A_INCUBATOR_CLUSTER_EMVHACS_THREEDS_API_PROJECT}", 
                  argocd_server: "${UAT_ARGOCD_SERVER}", 
                  argocd_cluster: "${UAT_DEST_CLUSTERURL}",
                  nexus_server: "${NEXUS_SERVER_URL}"  
          ] as java.lang.Object
          break
        case "QA":
          return [
                  aws_account_id: "${THREEDS_UAT_AWS_ACCOUNT_ID}", 
                  aws_iam_role_name: "eks_uat_2c2p-management-jenkins-emvacs-pod_PodRole", 
                  argocd_app_name: "qa-emv3dscardrange", 
                  argocd_token: "${CLUSTER_A_INCUBATOR_CLUSTER_QA_EMVHACS_THREEDS_API_PROJECT}", 
                  argocd_server: "${UAT_ARGOCD_SERVER}", 
                  argocd_cluster: "${UAT_DEST_CLUSTERURL}",
                  nexus_server: "${NEXUS_SERVER_URL}"  
          ] as java.lang.Object
          break
        case "LOADTEST":
          return [
                  aws_account_id: "${THREEDS_UAT_AWS_ACCOUNT_ID}", 
                  aws_iam_role_name: "eks_uat_2c2p-management-jenkins-emvacs-pod_PodRole", 
                  argocd_app_name: "loadtest-emv3dscardrange", 
                  argocd_token: "${CLUSTER_A_INCUBATOR_CLUSTER_LOADTEST_EMVHACS_THREEDS_API_PROJECT}", 
                  argocd_server: "${LOADTEST_ARGOCD_SERVER}", 
                  argocd_cluster: "${LOADTEST_DEST_CLUSTERURL}",
                  nexus_server: "${NEXUS_SERVER_URL}"  
          ] as java.lang.Object
          break
        case "DEMO":
          return [
                  aws_account_id: "${THREEDS_UAT_AWS_ACCOUNT_ID}", 
                  aws_iam_role_name: "eks_uat_2c2p-management-jenkins-emvacs-pod_PodRole", 
                  argocd_app_name: "demo-emv3dscardrange", 
                  argocd_token: "${CLUSTER_A_INCUBATOR_CLUSTER_DEMO_EMVHACS_THREEDS_API_PROJECT}", 
                  argocd_server: "${DEMO_ARGOCD_SERVER}", 
                  argocd_cluster: "${DEMO_DEST_CLUSTERURL}",
                  nexus_server: "${NEXUS_SERVER_URL}"  
          ] as java.lang.Object
          break
        case "KBANK":
          return [
                  aws_account_id: "${THREEDS_UAT_AWS_ACCOUNT_ID}", 
                  aws_iam_role_name: "eks_uat_2c2p-management-jenkins-emvacs-pod_PodRole", 
                  argocd_app_name: "threeds-cardranges-api", 
                  argocd_token: "${ARGOCD_KBANKEMVACS_SIT_A_THREEDSSERVICE_Password}", 
                  argocd_server: "${KBANK_SIT_ARGOCD_SERVER}", 
                  argocd_cluster: "${KBANK_SIT_DEST_CLUSTERURL}",
                  nexus_server: "${NEXUS_SERVER_URL}"  
          ] as java.lang.Object
          break
        }
    }
}

def getVars(project) {
  if (project == 'CARDRANGESERVICE') {
    return [
            project_dir: "./", 
            project_ecr: "3dssv2_card_range_service", 
    ] as java.lang.Object
  }
}

pipeline {
    agent {
      kubernetes {
        defaultContainer 'jnlp'
        yamlFile 'pod-buildx.yaml'
      }
    }

    parameters {
        choice(name: 'PROCESS', choices: ['Build', 'Deploy'], description: 'You can only deploy an existing image. To make an image, create a git tag in "v-0.0.0" format.')
        choice(name: 'PROJECT', choices: ['CARDRANGESERVICE'], description: '')
        choice(name: 'ENVIRONMENT', choices: ['SIT', 'QA', 'LOADTEST', 'DEMO', 'KBANK'], description: '')
        string(name: 'IMAGETAGS', description: 'If "Deploy" PROCESS selected, provide an image tag to deploy.')
    }

    environment {
        GIT_COMMIT          = sh(returnStdout: true, script: 'git config --global --add safe.directory "*"&&git rev-parse HEAD').trim()
        PROJECT_DIR         = "${getVars(params.PROJECT).project_dir}"
        PROJECT_ECR         = "${getVars(params.PROJECT).project_ecr}"
        AWS_ACCOUNT_ID      = "${getVars(params.PROJECT, params.ENVIRONMENT).aws_account_id}"
        AWS_IAM_ROLE_NAME   = "${getVars(params.PROJECT, params.ENVIRONMENT).aws_iam_role_name}"
        ARGOCD_APP_NAME     = "${getVars(params.PROJECT, params.ENVIRONMENT).argocd_app_name}"
        ARGOCD_TOKEN        = "${getVars(params.PROJECT, params.ENVIRONMENT).argocd_token}"
        ARGOCD_SERVER       = "${getVars(params.PROJECT, params.ENVIRONMENT).argocd_server}"
        ARGOCD_CLUSTER      = "${getVars(params.PROJECT, params.ENVIRONMENT).argocd_cluster}" 
        NUGET_SERVER_URL    = "${getVars(params.PROJECT, params.ENVIRONMENT).nexus_server}" 
        AWS_DEFAULT_REGION  = 'ap-southeast-1'
        ECR_URI             = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
        ECR_BUILD_TAG       = "jenkins-${BRANCH_NAME.replaceAll('/', '_')}.${GIT_COMMIT}.${BUILD_NUMBER}"
        ECR_IMAGE_TAG       = "${params.PROCESS == 'Deploy' ? params.IMAGETAGS : env.ECR_BUILD_TAG}"
        ECR_TAGGED_IMG      = "${ECR_URI}/${PROJECT_ECR}:${ECR_IMAGE_TAG}"
        NUGET_CREDS         = credentials('nexus-credentials')
        DINGTALKURL         = credentials('DINGTALKURL')
    }

    stages {
        stage('Info') {
            steps {
                //echo "---------- all env vars--------------"
                //sh "env"
                echo "----------- trace vars --------------"
                echo "BUILD_NUMBER_UUID: $BUILD_NUMBER_UUID"
                echo "BUILD_NUMBER: $BUILD_NUMBER"
                echo "BRANCH_NAME: $BRANCH_NAME"
                echo "ECR_BUILD_TAG: $ECR_BUILD_TAG"
                echo "ECR_IMAGE_TAG: $ECR_IMAGE_TAG"
                echo "ECR_TAGGED_IMG: $ECR_TAGGED_IMG"
                echo "----------- list params -------------"
                echo "params.PROCESS: ${params.PROCESS}"
                echo "params.PROJECT: ${params.PROJECT}"
                echo "params.ENVIRONMENT: ${params.ENVIRONMENT}"
                echo "params.IMAGETAGS: ${params.IMAGETAGS}"
                echo "------ list expected env vars -------"
                echo "env.TAG_NAME: ${env.TAG_NAME}"
                echo "----------- list dir ----------------"
                sh "ls -la"
            }
        }

        stage('Build trigger info') {
            steps {
                script {
                    if (env.TAG_NAME) {
                        echo "Triggered by the TAG: $TAG_NAME"
                    } else {
                        echo "Triggered by some branch, PR, etc."
                    }
                }
            }
        }

        stage('Set assembly version by git tag') {
            when {
                allOf {
                    expression { env.TAG_NAME != null }
                    expression { tag "v-*"  }
                }
            }
            steps {
                echo "Using tag $TAG_NAME"
                sh '''
                    CVER=$(echo $TAG_NAME | cut -d "-" -f2)
                    echo $CVER > .cver

                    echo "CVER: $CVER"
                    echo "Constructed assembly version (major.minor.build.revision): $CVER.$BUILD_NUMBER"
                '''
            }
        }

        // stage('Build and Test') {
        //     when {
        //         allOf {
        //             expression { env.TAG_NAME == null }
        //         }
        //     }
        //     steps {
        //         script {
        //             nexus_nuget_restore(NUGET_SERVER_URL, NUGET_CREDS_USR, NUGET_CREDS_PSW)
        //         }
        //         script {
        //                 sh '''
        //                     set +x
        //                     dotnet restore --configfile nuget.config ThreeDomainServer.CardRanges.sln
        //                     dotnet build ThreeDomainServer.CardRanges.sln --no-restore
        //                     dotnet test ThreeDomainServer.CardRanges.sln --no-build --logger "trx;logfilename=${WORKSPACE}/test/testResults.xml"
        //             '''
        //         }
        //     }
        //     post {
        //         always {
        //             xunit (
        //                 thresholds: [ skipped(failureThreshold: '5'), failed(failureThreshold: '5') ],
        //                 tools: [ MSTest(pattern: "test/*.xml") ]
        //             )   
        //         }
        //     }
        // }

        stage('Build an image') {

            when {
                allOf{
                    // expression { env.TAG_NAME != null }
                    // expression { tag "v-*"  }
                    expression { params.PROCESS != 'Deploy' }
                }
            }
            steps {
                container('jnlp') {
                    // script {
                    //     nexus_nuget_restore(NUGET_SERVER_URL, NUGET_CREDS_USR, NUGET_CREDS_PSW)
                    // }
                    script {
                        echo "Building from git branch $BRANCH_NAME"
                        sh '''
                            #docker buildx create --use --platform=linux/arm64,linux/amd64 --name multi-platform-builder
                            #docker buildx inspect --bootstrap
                            #docker buildx create --name container --driver=docker-container
                            #docker buildx create --use
                            #docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
                            docker buildx create --use --platform=linux/arm64,linux/amd64 --name multi-platform-builder --driver=docker-container
                        '''
                        sh '''
                            set +x
                            DD_AGENT_VERSION="$(curl -s https://api.github.com/repos/DataDog/dd-trace-dotnet/releases/latest | jq -r .name)"
                            #CVER=$(echo $TAG_NAME | cut -d "-" -f2)
                            #cat .cver
                            #echo ${CVER}
                            #if [ -f .cver ] && [ ${CVER}=$(cat .cver) ] ; then
                            #    echo "Using assembly version: $CVER.$BUILD_NUMBER"
                                # Assume iam role
                                eval $(aws sts assume-role --role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${AWS_IAM_ROLE_NAME} \
                                --role-session-name assumed | jq -r '.Credentials | "export \
                                AWS_ACCESS_KEY_ID=\\(.AccessKeyId)\\nexport AWS_SECRET_ACCESS_KEY=\\(.SecretAccessKey)\\nexport AWS_SESSION_TOKEN=\\(.SessionToken)\\n"')
                                # Login into ECR
                                aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_URI}
                
                                DOCKER_BUILDKIT=1 docker buildx build --progress=plain --no-cache \
                                --build-arg TRACER_VERSION=$DD_AGENT_VERSION \
                                -f ${PROJECT_DIR}/Dockerfile-test \
                                --platform linux/arm64 \
                                --builder multi-platform-builder \
                                -t ${ECR_TAGGED_IMG}-arm64 \
                                --load \
                                --push \
                                .
                                #docker push ${ECR_TAGGED_IMG}-arm64
                                
                                #buildah manifest create ${ECR_TAGGED_IMG}-arm64
                                #buildah build \
                                #--build-arg TRACER_VERSION=$DD_AGENT_VERSION \
                                #--platform linux/arm64 \
                                #--tag ${ECR_TAGGED_IMG}-arm64 \
                                #--manifest ${ECR_TAGGED_IMG}-arm64 \
                                #${PROJECT_DIR}/Dockerfile-test
                            
                            #fi
                    '''
                    }
                }
            }
        }

        // stage('Push to ECR') {
        //     when {
        //         allOf {
        //             expression { env.TAG_NAME != null }
        //             expression { tag "v-*"  }
        //             expression { params.PROCESS != 'Deploy' }
        //         }
        //     }
        //     steps {
        //         sh '''
        //             set +x

        //             # Assume iam role
        //             eval $(aws sts assume-role --role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${AWS_IAM_ROLE_NAME} \
        //             --role-session-name assumed | jq -r '.Credentials | "export \
        //             AWS_ACCESS_KEY_ID=\\(.AccessKeyId)\\nexport AWS_SECRET_ACCESS_KEY=\\(.SecretAccessKey)\\nexport AWS_SESSION_TOKEN=\\(.SessionToken)\\n"')
                    
        //             # Login into ECR
        //             aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | buildah login --username AWS --password-stdin ${ECR_URI}

        //             buildah push ${ECR_TAGGED_IMG}
        //         '''
        //     }
        // }

        stage ('Cancel manual deployment on missing image tag') {
            when {
                allOf {
                    expression { params.PROCESS == 'Deploy' }
                    expression { params.IMAGETAGS == null }
                }
            }
            steps {
                script {
                    currentBuild.result = 'ABORTED'
                    error('Please input image tag for deploiment')
                }
            }
        }

        stage('Deploy') {
            when {
                expression { params.PROCESS != 'Build' }
            }
            steps {
                echo "Deployment for $ECR_IMAGE_TAG"
                sh '''
                    argocd --auth-token ${ARGOCD_TOKEN} --insecure --grpc-web \
                    --server  ${ARGOCD_SERVER} app set ${ARGOCD_APP_NAME} \
                    --dest-server ${ARGOCD_CLUSTER} -p image.tag=${ECR_IMAGE_TAG} -p env.DD_VERSION=${ECR_IMAGE_TAG}
                '''
            }
        }
    }

    post {
        success {
            echo "========${params.PROCESS} executed successfully, image tag is ${ECR_IMAGE_TAG}========"
        }
        failure {
            echo "========${params.PROCESS} failed========"
        }
        always {
            echo "========always========"
            script {
                if(env.TAG_NAME == null) {
                    STATEMESSAGE = "on ${params.ENVIRONMENT} without tag"+"\n"
                    currentBuild.displayName    = "${params.PROCESS}-${params.PROJECT}-${params.ENVIRONMENT}"
                }
                else {
                    STATEMESSAGE = "on ${params.ENVIRONMENT} with tag: ${ECR_IMAGE_TAG}"+"\n"
                    currentBuild.displayName    = "${params.PROCESS}-${params.PROJECT}-${params.ENVIRONMENT}-${ECR_IMAGE_TAG}"
                }
                DINGTALKCUSTOMKEY           = "ACS3DS" 
                TRIGGERBYAUTHOR             = sh(returnStdout: true, script: 'git config --global --add safe.directory "*"&&git log --format="%ae" | head -1').trim()
                ARTIFACTMESSAGE1            = "Jenkins ${params.PROCESS} "+"of ${params.PROJECT}"+"\n"
                ARTIFACTMESSAGE2            = STATEMESSAGE
                ARTIFACTMESSAGE3            = "finished with status: "+currentBuild.currentResult+"\n"
                ARTIFACTMESSAGE=ARTIFACTMESSAGE1+ARTIFACTMESSAGE2+ARTIFACTMESSAGE3
                send_notification_dingtalk_customkey(DINGTALKCUSTOMKEY,env.BUILD_URL,env.BRANCH_NAME,TRIGGERBYAUTHOR,ARTIFACTMESSAGE,DINGTALKURL)
            }
        }
    }
}
