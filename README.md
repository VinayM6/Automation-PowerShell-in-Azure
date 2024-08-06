# Automation-PowerShell-in-Azure
Automation and Version Control with Git, Linux, and PowerShell in Azure
Objective: Automate Azure resource management tasks using PowerShell scripting on Linux and maintain version control of scripts using Git and GitHub.

****Step 1:** Setup Azure Environment**
------------------------------------------------------
1.	Login to an Azure subscription
o	Login  to Azure .
2.	Provision a Linux-based virtual machine (VM) in Azure for executing PowerShell scripts.
o	Go to the Azure Portal.
o	Click on "Create a resource".
o	Select "Ubuntu Server" from the list of available VMs.
o	Fill in the necessary details (resource group, VM name, region, size, authentication type, username, password/SSH key).
o	Click "Review + create", then "Create".

****Step 2:** Install Git and PowerShell on Linux VM**
------------------------------------------------------
1.	SSH into the Linux VM using MobaXtrem or Putty:
2.	Install Git:
Run the following commands to update the package list and install Git:
sudo apt-get update
sudo apt-get install git -y
3.	Install PowerShell Core:
Run the following commands to update the package list and install PowerShell:

sudo snap install powershell --classic

Check Git and PowerShell version using following commands:
git  --version
pwsh --version

**Verify Dependencies**
sudo apt-get install xdg-utils
sudo apt-get update
sudo apt-get install firefox
xdg-open https://www.bing.com
pwsh
connect-AzAccount -Tenant <your tenantID>

**Step 3: Clone GitHub Repository**
------------------------------------------------------
    Clone a Git repository from GitHub containing sample PowerShell scripts for Azure automation tasks:
    Run the following command:

# git clone https://github.com/VinayM6/Automation-PowerShell-in-Azure.git
# cd Automation-PowerShell-in-Azure

**Step 4: Create PowerShell Scripts**
------------------------------------------------------
PowerShell scripts to Creating Linux VM: “CreateAZVM.ps1”

**Step 5: Test PowerShell Scripts**
------------------------------------------------------
1.	Test the PowerShell scripts on the Linux VM:
o	Run the following command to execute the script:
pwsh
 ./CreateAZVM.ps1
Authorizing Azure account:

**Step6: Linux VM Created successfully**
------------------------------------------------------
**Step 7: Version Control with Git**
------------------------------------------------------
1.	Add your PowerShell scripts to the Git repository on the Linux VM:
o	Run the following commands:
git add .
git commit -m "Add PowerShell scripts for Azure automation"
git push origin main

**Step 8: Execute Automation Tasks.**
------------------------------------------------------
Script 2: Configure VM and Automation Tasks (configurevm.ps1)

**Step 9: Test Automation script “configureVM.ps1”**
------------------------------------------------------
1.	Test the PowerShell scripts on the Linux VM:
o	Run the following command to execute the script:
pwsh
 ./configureVM.ps1

**Automation Account will be created.**
------------------------------------------------------
Script 3: Automating installing software on VM (install-software.sh)
This script will be executed on the VM using the Azure Custom Script Extension. It installs Nginx.

**Uploading and Referencing the Script**
To use this script with the Azure Custom Script Extension, follow these steps:
1.	Upload the Script to Azure Storage:

------------------------------------------------------
**Result of the Project:**
------------------------------------------------------
In this project, I created a Linux virtual machine (VM) in my Azure portal and accessed it using SSH in MobaXterm. Once inside the VM, I utilized a PowerShell script (CreateAZVM.ps1) which I have cloned from My GitHub repository to create a Linux-based VM. This script automated the creation of the resource group, virtual network (VNet), subnet, public IP, network interface, and VM configuration.

Subsequently, I executed another PowerShell script (configurevm.ps1) to perform the following automation tasks on newly created VM:

1.	Install necessary software on the newly created VM using install-software.sh, which is stored in my Azure Storage account.
2.	Enable Azure Monitor for the VM.
3.	Create an alert rule for CPU usage.
4.	Automated Network Security Group (NSG) configuration.
5.	Automated VM start/stop operations.
6.	Create an Automation Account.
7.	Create a runbook for start/stop operations.
8.	Schedule the start/stop runbooks: 
    a. Start the VM every day at 7 AM. 
    b. Stop the VM every day at 7 PM.
9.	Link schedules to runbooks.





