pipeline {
    agent any
    
    environment {
        ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
        ARM_CLIENT_ID       = credentials('azure-client-id')
        ARM_CLIENT_SECRET   = credentials('azure-client-secret')
        ARM_TENANT_ID       = credentials('azure-tenant-id')
        TF_STATE_RESOURCE_GROUP = "terraform-state-rg"
        TF_STATE_STORAGE_ACCOUNT = "tfstatestorageacc"
        TF_STATE_CONTAINER = "tfstate"
        TF_STATE_KEY = "terraform.tfstate"
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        
        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh '''
                    terraform init \
                        -backend-config="resource_group_name=${TF_STATE_RESOURCE_GROUP}" \
                        -backend-config="storage_account_name=${TF_STATE_STORAGE_ACCOUNT}" \
                        -backend-config="container_name=${TF_STATE_CONTAINER}" \
                        -backend-config="key=${TF_STATE_KEY}" \
                        -input=false
                    '''
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform plan -input=false -out=tfplan'
                    archiveArtifacts artifacts: 'terraform/tfplan', onlyIfSuccessful: true
                    
                    // Optional: Save plan output to file
                    sh 'terraform show -no-color tfplan > tfplan.txt'
                    archiveArtifacts artifacts: 'terraform/tfplan.txt', onlyIfSuccessful: true
                }
            }
        }
        
        stage('Manual Approval') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    input message: 'Proceed with Terraform Apply?', ok: 'Apply'
                }
            }
        }
        
        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -input=false tfplan'
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Terraform execution completed successfully'
        }
        failure {
            mail to: 'devops-team@example.com',
                 subject: "Failed Pipeline: ${currentBuild.fullDisplayName}",
                 body: "Azure Terraform pipeline failed. Check ${env.BUILD_URL}"
        }
    }
}