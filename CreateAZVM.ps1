# Connect to Azure with Tenant ID
$tenantId = "a0f489bb-c411-4b8a-b584-82be6dbae784"
Connect-AzAccount -Tenant $tenantId

# Variables
$resourceGroupName = "MyRG"
$location = "canadacentral"
$vmName = "MyVM"

# Create Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create a Virtual Network
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location -Name "MyVNet" -AddressPrefix "10.0.0.0/16"

# Create a Subnet
$subnet = Add-AzVirtualNetworkSubnetConfig -Name "MySubnet" -AddressPrefix "10.0.0.0/24" -VirtualNetwork $vnet
$vnet | Set-AzVirtualNetwork

# Create a Public IP Address
$pip = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Location $location -Name "MyPublicIP" -AllocationMethod Static

# Create a Network Interface
$nic = New-AzNetworkInterface -ResourceGroupName $resourceGroupName -Location $location -Name "MyNIC" -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

# Create a Virtual Machine Configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize "Standard_B1s" | `
  Set-AzVMOperatingSystem -Linux -ComputerName $vmName -Credential (Get-Credential) | `
  Set-AzVMSourceImage -PublisherName "Canonical" -Offer "ubuntu-24_04-lts" -Skus "server" -Version "latest" | `
  Add-AzVMNetworkInterface -Id $nic.Id

# Create the Virtual Machine
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig

# Wait for VM to be fully provisioned with a countdown timer
$seconds = 300  # 5 minutes
while ($seconds -gt 0) {
    Write-Output "Waiting for VM to be fully provisioned... $seconds seconds remaining"
    Start-Sleep -Seconds 1
    $seconds--
}

# Trigger the second script for automation tasks
pwsh ./configure-vm.ps1
