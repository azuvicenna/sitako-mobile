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
        string(
            name: 'API_BASE_URL',
            defaultValue: '',
            description: 'URL API Backend SITAKO kustom (misal http://192.168.1.100:8080/api). Kosongkan jika ingin auto-detect dari VM Multipass.'
        )
        booleanParam(
            name: 'USE_MULTIPASS_IP',
            defaultValue: true,
            description: 'Deteksi otomatis IP dari VM Multipass jika API_BASE_URL kosong'
        )
        string(
            name: 'VM_NAME',
            defaultValue: 'sitako-vm',
            description: 'Nama VM Multipass tujuan backend SITAKO'
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

        stage('Resolve API Base URL') {
            steps {
                script {
                    def targetApiUrl = (params.API_BASE_URL ?: '').trim()
                    if (!targetApiUrl && params.USE_MULTIPASS_IP) {
                        try {
                            def vmIp = ""
                            if (isUnix()) {
                                vmIp = sh(script: "multipass info ${params.VM_NAME} | grep IPv4 | awk '{print \$2}'", returnStdout: true).trim()
                            } else {
                                vmIp = bat(script: "@echo off & for /f \"tokens=2\" %%i in ('multipass info ${params.VM_NAME} ^| findstr IPv4') do echo %%i", returnStdout: true).trim()
                            }
                            if (vmIp) {
                                targetApiUrl = "http://${vmIp}:8080/api"
                                echo "Auto-detected Multipass VM IP: ${vmIp} -> API Base URL: ${targetApiUrl}"
                            }
                        } catch (err) {
                            echo "Warning: Gagal mendeteksi IP Multipass: ${err.message}. Menggunakan default fallback."
                        }
                    }

                    if (targetApiUrl) {
                        env.DART_DEFINE_API = "--dart-define=API_BASE_URL=${targetApiUrl}"
                        echo "Build akan menggunakan: ${env.DART_DEFINE_API}"
                    } else {
                        env.DART_DEFINE_API = ""
                        echo "Build menggunakan default internal URL"
                    }
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
                    def dartDefine = env.DART_DEFINE_API ?: ''
                    executeCmd("flutter build apk --${params.BUILD_MODE} ${splitFlag} ${dartDefine}".trim())
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
                    def dartDefine = env.DART_DEFINE_API ?: ''
                    executeCmd("flutter build appbundle --${params.BUILD_MODE} ${dartDefine}".trim())
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
