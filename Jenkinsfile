pipeline {
    agent any
 
    parameters {
        string(name: 'WORKSPACE', defaultValue: 'development', description:'worspace to use in Terraform')
        password (name: 'AWS_ACCESS_KEY_ID', defaultValue: 'AKIATQ2TQYVE3KQ65B43')
        password (name: 'AWS_SECRET_ACCESS_KEY', defaultValue: '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')

    }
    environment {
        TF_IN_AUTOMATION = "true"
        APPLICATION_ACCESS_KEY = "${params.AWS_ACCESS_KEY_ID}"
        APPLICATION_SECRET_KEY = "${params.AWS_SECRET_ACCESS_KEY}"
    }
    stages {
        stage('GitClone') {
          steps {
            git url: 'https://github.com/alanzha0598/JenkinsPipelineApplicationPublic.git', branch: 'main'
            sh "echo \$PWD"
          }
        }
        stage('ApplicationInit'){
            steps {
                dir('/var/lib/jenkins/workspace/JenkinsPipelineApplication_main'){
                    sh "terraform init -input=false --backend-config='access_key=$APPLICATION_ACCESS_KEY' --backend-config='secret_key=$APPLICATION_SECRET_KEY' "                    
                    sh "echo \$PWD"
                    sh "whoami"
                }
            }
        }
        stage('ApplicationPlan'){
            steps {
                dir('/var/lib/jenkins/workspace/JenkinsPipelineApplication_main'){
                    script {
                        try {
                            sh "terraform workspace new ${params.WORKSPACE}"
                        } catch (err) {
                            sh "terraform workspace select ${params.WORKSPACE}"
                        }
                        sh "terraform plan -input=false -var 'aws_access_key=$APPLICATION_ACCESS_KEY' -var 'aws_secret_key=$APPLICATION_SECRET_KEY' -out terraform-application.tfplan;echo \$? > status"
                        stash name: "terraform-application-plan", includes: "terraform-application.tfplan"
                    }
                }
            }
        }
        stage('ApplicationApply'){
            steps {
                script{
                    def apply = false
                    try {
                        input message: 'confirm apply', ok: 'Apply Config'
                        apply = true
                    } catch (err) {
                        apply = false
                        dir('/var/lib/jenkins/workspace/JenkinsPipelineApplication_main'){
                            sh "terraform destroy -var 'aws_access_key=$APPLICATION_ACCESS_KEY'  -var 'aws_secret_key=$APPLICATION_SECRET_KEY' -force"
                        }
                         currentBuild.result = 'UNSTABLE'
                    }
                    if(apply){
                        dir('/var/lib/jenkins/workspace/JenkinsPipelineApplication_main'){
                            unstash "terraform-application-plan"
                            sh 'terraform apply -input=false terraform-application.tfplan'
                        }
                    }
                }
            }
        }
    }
}