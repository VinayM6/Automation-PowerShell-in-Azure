# Connect to Azure with Tenant ID
$tenantId = "a0f489bb-c411-4b8a-b584-82be6dbae784"
Connect-AzAccount -Tenant $tenantId

# Variables
$resourceGroupName = "MyRG"
$vmName = "MyVM"
$location = "canadacentral"
$automationLocation = "eastus2"

try {
    # Install necessary software
    $script = @"
sudo apt update
sudo apt install -y nginx
"@
    $scriptEncoded = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($script))
    Set-AzVMCustomScriptExtension -ResourceGroupName $resourceGroupName -VMName $vmName -Name "InstallSoftware" `
      -Location $location -FileUri "https://autoscriptsa.blob.core.windows.net/scripts/install_software.sh" `
      -Run "install-software.sh" -Argument $scriptEncoded -StorageAccountName "autoscriptsa" `
      -StorageAccountKey "QUyWg+DIwCmcwRibgTPGhri9c1X4IlPwYAxqpTIS0GMqt33c6aBDRmeVOEU2qysvI9F6ZvhJ7B11+AStECClyg=="
    Write-Output "Software installation script executed successfully."
} catch {
    Write-Error "Failed to execute software installation script: $_"
}

try {
    # Enable Azure Monitor for the VM
    Enable-AzVMMonitoring -ResourceGroupName $resourceGroupName -VMName $vmName
    Write-Output "Azure Monitor enabled for the VM."
} catch {
    Write-Error "Failed to enable Azure Monitor: $_"
}

try {
    # Create Alert Rule for CPU Usage
    Add-AzMetricAlertRule -Name "HighCPUAlert" -ResourceGroup $resourceGroupName -Location $location `
      -TargetResourceId (Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName).Id -Condition "Percentage CPU > 80" -WindowSize 5 -TimeAggregation "Average" `
      -Description "Alert when CPU usage is over 80%" -ActionGroupId "/subscriptions/your-subscription-id/resourceGroups/your-resource-group/providers/microsoft.insights/actiongroups/your-action-group-name"
    Write-Output "CPU usage alert rule created successfully."
} catch {
    Write-Error "Failed to create CPU usage alert rule: $_"
}

try {
    # Automate NSG Configuration
    $nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Name "MyNSG"
    $rule = New-AzNetworkSecurityRuleConfig -Name "AllowHTTP" -Protocol "Tcp" -Direction "Inbound" -Priority 100 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange 80 -Access "Allow"
    $nsg | Add-AzNetworkSecurityRuleConfig -SecurityRule $rule
    $nsg | Set-AzNetworkSecurityGroup
    Write-Output "NSG configuration updated successfully."
} catch {
    Write-Error "Failed to update NSG configuration: $_"
}

try {
    # Automate VM Start/Stop
    $startVMScript = @"
Start-AzVM -ResourceGroupName $resourceGroupName -Name $vmName
"@
    $stopVMScript = @"
Stop-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -Force
"@
    $startVMEncoded = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($startVMScript))
    $stopVMEncoded = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($stopVMScript))

    # Create Automation Account
    New-AzAutomationAccount -ResourceGroupName $resourceGroupName -Name "MyAutomationAccount" -Location $automationLocation
    Write-Output "Automation Account created successfully."

    # Create Runbook for Start/Stop
    New-AzAutomationRunbook -ResourceGroupName $resourceGroupName -AutomationAccountName "MyAutomationAccount" -Name "StartVMRunbook" -Type PowerShell -ScriptContent $startVMScript
    New-AzAutomationRunbook -ResourceGroupName $resourceGroupName -AutomationAccountName "MyAutomationAccount" -Name "StopVMRunbook" -Type PowerShell -ScriptContent $stopVMScript
    Write-Output "Runbooks for Start/Stop created successfully."

    # Schedule Start/Stop Runbooks
    $startSchedule = New-AzAutomationSchedule -ResourceGroupName $resourceGroupName -AutomationAccountName "MyAutomationAccount" -Name "StartVMSchedule" -Description "Start VM every day at 7 AM" -StartTime (Get-Date).Date.AddHours(7) -DayInterval 1
    $stopSchedule = New-AzAutomationSchedule -ResourceGroupName $resourceGroupName -AutomationAccountName "MyAutomationAccount" -Name "StopVMSchedule" -Description "Stop VM every day at 7 PM" -StartTime (Get-Date).Date.AddHours(19) -DayInterval 1
    Write-Output "Schedules for Start/Stop runbooks created successfully."

    # Link schedules to runbooks
    Register-AzAutomationScheduledRunbook -ResourceGroupName $resourceGroupName -AutomationAccountName "MyAutomationAccount" -RunbookName "StartVMRunbook" -ScheduleName "StartVMSchedule"
    Register-AzAutomationScheduledRunbook -ResourceGroupName $resourceGroupName -AutomationAccountName "MyAutomationAccount" -RunbookName "StopVMRunbook" -ScheduleName "StopVMSchedule"
    Write-Output "Schedules linked to runbooks successfully."
} catch {
    Write-Error "Failed to automate VM Start/Stop: $_"
}
