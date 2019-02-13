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
                sh 'export PATH=/jenkins/tools/play/activator-1.3.10-minimal/bin:/jenkins/tools/java/jdk-8u60/bin/:/opt/pb/bin:/opt/perf/bin:/usr/local/sbin:/usr/sbin:/sbin:.$PATH && export http_proxy=http://proxy.houston.somecorp.net:8088 && export https_proxy=http://proxy.houston.somecorp.net:8088 && activator test'
				        junit 'target/test-reports/*.xml'
            }
        }
        stage('Build') {
            steps {
                sh 'export PATH=/jenkins/tools/play/activator-1.3.10-minimal/bin:/jenkins/tools/java/jdk-8u60/bin/:/opt/pb/bin:/opt/perf/bin:/usr/local/sbin:/usr/sbin:/sbin:.$PATH && export http_proxy=http://proxy.houston.somecorp.net:8088 && export https_proxy=http://proxy.houston.somecorp.net:8088 && activator clean compile dist'
            }
        }
        stage('Deliver for DEV') {
            when {
                branch 'PR-*'
            }
            steps {
                sh 'ansible-playbook ansible/ess_deploy_playbook.yml --inventory=ansible/hosts --private-key=/jenkins/.ssh/jenkins_key --extra-vars "host=DEV"'
            }
        }
        stage('SonarQube analysis') {
            when {
                branch 'PR-*'
            }
            steps {
                sh 'echo "Task started: SonarQube analysis"'
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
                sh 'ansible-playbook ansible/ess_deploy_playbook.yml --inventory=ansible/hosts --private-key=/jenkins/.ssh/jenkins_key --extra-vars "host=DEV"'
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
                input message: 'Generate Request For Change? (Click "Proceed" to continue)'
                sh 'echo "Task started: Generate Change Record"'
                sh 'ssh -i /jenkins/.ssh/jenkins_key -o StrictHostKeyChecking=no search@c9t18606.itcs.somecorp.net ./git-release.sh'
                input message: 'Deploy to PROD? (Click "Proceed" to continue)'
                sh 'echo "Task started: Deploy to PROD"'
                sh 'ansible-playbook ansible/ess_deploy_playbook.yml --inventory=ansible/hosts --private-key=/jenkins/.ssh/jenkins_key --extra-vars "host=DEV"'
            }
        }
    }
}
