pipeline {
    agent {
        label "linux"
    }
    tools {
        maven 'maven-3.3.3 [linux]'
    }
    stages {
        stage('Unit test') {
            when {
                not {
                    branch 'master'
                }
            }
            steps {
                sh 'export PATH=/jenkins/tools/play/activator-1.3.10-minimal/bin:/jenkins/tools/java/jdk-8u60/bin/:/opt/pb/bin:/opt/perf/bin:/usr/local/sbin:/usr/sbin:/sbin:.$PATH && export http_proxy=http://itcs.somecorp.net.net:8088 && export https_proxy=http://itcs.somecorp.net.net:8088 && activator test'
				        junit 'target/test-reports/*.xml'
            }
        }
        stage('Build') {
            steps {    
                sh 'export PATH=/jenkins/tools/play/activator-1.3.10-minimal/bin:/jenkins/tools/java/jdk-8u60/bin/:/opt/pb/bin:/opt/perf/bin:/usr/local/sbin:/usr/sbin:/sbin:.$PATH && export http_proxy=http://itcs.somecorp.net.net:8088 && export https_proxy=http://itcs.somecorp.net.net && activator clean compile dist'
            }
        }
        stage('Deliver for DEV') {
            when {
                branch 'PR-*'
            }
            steps {
                sh 'ansible-playbook ansible/ess_deploy_playbook.yml --inventory=ansible/hosts --private-key=/jenkins/.ssh/jenkins_key --extra-vars "host=DEV"'
		sh 'curl --key /jenkins/.ssh/jenkins_key -X POST -d message="Hello @team - A code deployment just completed in DEV! See Pipeline Activity here: http://jenkins/blue/organizations/jenkins/Pipeline_ALL/activity #ess_deployments" http://hubotserver:8080/hubot/notify/chat-room-ID'
            }
        }
        stage('SonarQube analysis') {
            when {
                branch 'PR-*'
            }
            steps {
                sh 'echo "Task started: SonarQube analysis"'
		withSonarQubeEnv('SonarQube') { 
          	  sh '/opt/cloudhost/sonarqube/sonar-runner-2.4/bin/sonar-runner ' + 
          	  '-Dsonar.sources=. ' +
                  '-Dsonar.projectKey=ESS_Admin_DevOps_PoC ' +
                  '-Dsonar.host.url=http://itcs.somecorp.net.net:9000 ' +
                  '-Dsonar.sourceEncoding=UTF-8 ' +
                  '-Dsonar.java.binaries=target/. '
            	}
            }
        }
        stage('SonarQube Quality Gate') {
            when {
                branch 'PR-*'
            }
            steps {
                sh 'echo "Task started: SonarQube Quality Gate"'
            }
        }
        stage('Deliver for ITG') {
            when {
                branch 'PR-*'
            }
            steps {
                sh 'ansible-playbook ansible/ess_deploy_playbook.yml --inventory=ansible/hosts --private-key=/jenkins/.ssh/jenkins_key --extra-vars "host=ITG"'
		sh 'curl --key /jenkins/.ssh/jenkins_key -X POST -d message="Hello @team - A code deployment just completed in ITG! See Pipeline Activity here: http://jenkins/blue/organizations/jenkins/Pipeline_ALL/activity #ess_deployments" http://hubotserver:8080/hubot/notify/chat-room-ID'
            }
        }
        stage('UI Testing') {
            when {
                branch 'PR-*'
            }
            steps {
                sh 'echo "UI Testing: Selenium, RESTAssure, WATiR, cucumber, etc.."'
                sh 'cd automation/ && mvn -PITG test'

                sh 'echo "Publish test reports - Step 1:"'
                step([$class: 'Publisher', reportFilenamePattern: 'automation/target/surefire-reports/testng-results.xml'])

                sh 'echo "Publish test reports - Step 2:"'
                publishHTML (target: [
                    reportDir: 'automation/target/surefire-reports',
                    reportFiles: 'index.html',
                    reportName: "UI test report"
                  ])
            }
        }
        stage('Distribute binaries') {
            when {
                branch 'PR-*'
            }
            steps {
                sh 'echo "Deploy to Artifactory: It will be GREAT if we can take the zip file from Artifactory before we deploy to PROD!"'
            }
        }
        stage('Deploy to PROD') {
            when {
                branch 'master'
            }
            steps {
                input message: 'Generate RFC? (Click "Proceed" to continue)'
                sh 'echo "Task started: Generate Change Record"'
                sh 'ssh -i /jenkins/.ssh/jenkins_key -o StrictHostKeyChecking=no user@itcs.somecorp.net.net ./git-release.sh'
                input message: 'Deploy to PROD? (Click "Proceed" to continue)'
                sh 'echo "Task started: Deploy to PROD"'
                sh 'ansible-playbook ansible/ess_deploy_playbook.yml --inventory=ansible/hosts --private-key=/jenkins/.ssh/jenkins_key --extra-vars "host=PROD"'
		sh 'curl --key /jenkins/.ssh/jenkins_key -X POST -d message="Hello @team - A code deployment just completed in PROD! See Pipeline Activity here: http://jenkins/blue/organizations/jenkins/Pipeline_ALL/activity #ess_deployments" http://hubotserver:8080/hubot/notify/chat-room-ID'
            }
        }
    }
}
