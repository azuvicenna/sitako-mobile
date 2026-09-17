pipeline {
    agent any

    parameters {
        choice(
            name: 'BUILD_TARGET',
            choices: ['apk', 'appbundle', 'both'],
            description: 'Target build artifact (APK for direct install, AppBundle for Google Play Store)'
        )
        choice(
            name: 'BUILD_MODE',
            choices: ['release', 'debug', 'profile'],
            description: 'Build compilation mode'
        )
        booleanParam(
            name: 'SPLIT_PER_ABI',
            defaultValue: false,
            description: 'Generate separate smaller APKs per CPU architecture (ABI)'
        )
        booleanParam(
            name: 'RUN_TESTS',
            defaultValue: true,
            description: 'Run automated unit and widget tests before building'
        )
    }

    environment {
        APP_NAME     = "sitako-mobile"
        FLUTTER_HOME = "/opt/flutter"
        PATH         = "${env.FLUTTER_HOME}/bin:${env.PATH}"
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Environment Check') {
            steps {
                script {
                    executeCmd('flutter doctor -v')
                }
            }
        }

        stage('Dependencies') {
            steps {
                script {
                    executeCmd('flutter pub get')
                }
            }
        }

        stage('Analyze') {
            steps {
                script {
                    executeCmd('flutter analyze')
                }
            }
        }

        stage('Test') {
            when {
                expression { return params.RUN_TESTS }
            }
            steps {
                script {
                    executeCmd('flutter test --coverage')
                }
            }
        }

        stage('Build APK') {
            when {
                expression {
                    return params.BUILD_TARGET == 'apk' || params.BUILD_TARGET == 'both'
                }
            }
            steps {
                script {
                    def splitFlag = params.SPLIT_PER_ABI ? '--split-per-abi' : ''
                    executeCmd("flutter build apk --${params.BUILD_MODE} ${splitFlag}")
                }
            }
        }

        stage('Build AppBundle') {
            when {
                expression {
                    return params.BUILD_TARGET == 'appbundle' || params.BUILD_TARGET == 'both'
                }
            }
            steps {
                script {
                    executeCmd("flutter build appbundle --${params.BUILD_MODE}")
                }
            }
        }

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts(
                    artifacts: 'build/app/outputs/flutter-apk/*.apk, build/app/outputs/bundle/**/*.aab',
                    fingerprint: true,
                    allowEmptyArchive: true
                )
            }
        }
    }

    post {
        success {
            echo "Build successful for ${env.APP_NAME} #${env.BUILD_NUMBER} (${params.BUILD_TARGET} - ${params.BUILD_MODE})"
        }
        failure {
            echo "Build failed for ${env.APP_NAME} #${env.BUILD_NUMBER}"
        }
        always {
            cleanWs(deleteDirs: true, notFailBuild: true)
        }
    }
}

void executeCmd(String cmd) {
    if (isUnix()) {
        sh cmd
    } else {
        bat cmd
    }
}
