// Jenkinsfile

pipeline {
    agent any

    // กำหนด Tools (ถ้าใช้ Global Tool Configuration)
    tools {
        terraform 'Terraform-Latest' 
    }

    // กำหนด Environment Variables และ Azure Credentials
    environment {
        // Azure Credentials (ใช้ ARM_ เพื่อให้ Azurerm Provider อ่านโดยตรง)
        ARM_CLIENT_ID       = credentials('AZURE_CLIENT_ID')
        ARM_CLIENT_SECRET   = credentials('AZURE_CLIENT_SECRET')
        ARM_TENANT_ID       = credentials('AZURE_TENANT_ID')
        ARM_SUBSCRIPTION_ID = credentials('AZURE_SUBSCRIPTION_ID')
        
        // บังคับให้ข้าม Azure CLI
        ARM_USE_AZURE_CLI   = 'false' 
        
        // กำหนด Path ของ Terrascan executable (ต้องแก้ไขให้ตรงกับ Path ของคุณ!)
        //TERRASCAN_PATH      = '"C:\\terrascan_1.19.9_Windows_x86_64\\terrascan.exe"' 
        TRIVY_PATH = 'C:\\trivy_0.67.2_windows-64bit\\trivy.exe'
        // กำหนด Default Action
        ACTION              = 'apply' 
    }

    stages {
        stage('Checkout Code') {
            steps {
                // โค้ดจะถูก Checkout มายัง Workspace
                git branch: 'master', url: 'https://github.com/kitthapat-j/iac-storage.git'
                echo "Code checked out."
            }
        }
        
        stage('terraform init') {
            steps {
                echo "Initializing Terraform..."
                bat 'terraform init' 
            }
        }
        
        stage('Security Scan (SAST)') {
            steps {
                echo "Starting IaC Security Scan with Terrascan..."
                // รัน Terrascan: ใช้ตัวแปร PATH ที่กำหนดไว้แล้ว
                // ใช้ --output cli เพื่อแสดง Policy Violation ใน Console Output
                //bat "${TERRASCAN_PATH} scan -i terraform -p . "
                bat "${TRIVY_PATH} config main.tf -f json -o trivy-results.json"

                echo "Checking JSON output for Azure Public Access Violation..."
                
                // ใช้ PowerShell เพื่อค้นหาคำที่เกี่ยวข้องกับช่องโหว่
                // (Policy ID สำหรับ Azure Storage Public Access ใน Trivy มักมีคำว่า 'public')
              try {
                    // findstr คืนค่า 0 เมื่อพบข้อความ (SUCCESS) และ 1 เมื่อไม่พบ (FAILURE)
                    // เราต้องการให้ Pipeline Fail เมื่อพบ (Exit Code 0) ดังนั้นเราต้องกลับ Logic 
                    
                    // ค้นหาคำที่เกี่ยวข้องกับ Policy Violation ใน Azure Storage
                    bat "findstr /C:\"azure-storage-account-public-access\" trivy-results.json"
                    
                    // ถ้า findstr คืนค่า 0 (พบข้อความ) เราจะมาถึงบรรทัดนี้
                    echo "--- VULNERABILITY FOUND: Public access is enabled! BLOCKING DEPLOYMENT ---"
                    error("Security Policy Violation detected: Public Access enabled on Storage Account.")
                    
                } catch (Exception e) {
                    // ถ้า findstr คืนค่า 1 (ไม่พบข้อความ) เราจะมาที่นี่
                    // เราจะให้ Pipeline ผ่านไป
                    echo "Security scan clean. Proceeding to deployment."
                }
            }
        }
        
        stage('terraform plan') {
            steps {
                // Stage นี้จะถูกข้ามหาก Security Scan Failed
                bat 'terraform plan -out=tfplan'
            }
        }
        
        stage('terraform Action') {
            when {
                expression { env.ACTION == 'apply' } // รัน apply เมื่อมี parameter 'apply'
            }
            steps {
                echo "Applying changes to Azure..."
                bat 'terraform apply -auto-approve tfplan'
            }
        }
    }
}