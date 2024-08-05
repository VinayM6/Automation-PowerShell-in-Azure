# Function to log messages
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Output "$timestamp - $message"
}

# Connect to Azure with Tenant ID
try {
    $tenantId = "a0f489bb-c411-4b8a-b584-82be6dbae784"
    Connect-AzAccount -Tenant $tenantId
    Log-Message "Successfully connected to Azure."
} catch {
    Log-Message "Error connecting to Azure: $_"
    exit 1
}

# Variables
$resourceGroupName = "MyRG"
$location = "canadacentral"
$vmName = "MyVM"

# Create Resource Group
try {
    New-AzResourceGroup -Name $resourceGroupName -Location $location
    Log-Message "Successfully created resource group '$resourceGroupName'."
} catch {
    Log-Message "Error creating resource group '$resourceGroupName': $_"
    exit 1
}

# Create a Virtual Network
try {
    $vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location -Name "MyVNet" -AddressPrefix "10.0.0.0/16"
    Log-Message "Successfully created virtual network 'MyVNet'."
} catch {
    Log-Message "Error creating virtual network 'MyVNet': $_"
    exit 1
}

# Create a Subnet
try {
    Add-AzVirtualNetworkSubnetConfig -Name "MySubnet" -AddressPrefix "10.0.0.0/24" -VirtualNetwork $vnet
    $vnet | Set-AzVirtualNetwork
    Log-Message "Successfully created subnet 'MySubnet'."
} catch {
    Log-Message "Error creating subnet 'MySubnet': $_"
    exit 1
}

# Get the updated virtual network object with the subnet configuration
try {
    $vnet = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name "MyVNet"
    Log-Message "Successfully retrieved updated virtual network 'MyVNet'."
} catch {
    Log-Message "Error retrieving updated virtual network 'MyVNet': $_"
    exit 1
}

# Create a Public IP Address
try {
    $pip = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Location $location -Name "MyPublicIP" -AllocationMethod Static
    Log-Message "Successfully created public IP address 'MyPublicIP'."
} catch {
    Log-Message "Error creating public IP address 'MyPublicIP': $_"
    exit 1
}

# Create a Network Interface
try {
    $nic = New-AzNetworkInterface -ResourceGroupName $resourceGroupName -Location $location -Name "MyNIC" -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id
    Log-Message "Successfully created network interface 'MyNIC'."
} catch {
    Log-Message "Error creating network interface 'MyNIC': $_"
    exit 1
}

# Create a Virtual Machine Configuration
try {
    $vmConfig = New-AzVMConfig -VMName $vmName -VMSize "Standard_B1s" | `
      Set-AzVMOperatingSystem -Linux -ComputerName $vmName -Credential (Get-Credential) | `
      Set-AzVMSourceImage -PublisherName "Canonical" -Offer "ubuntu-24_04-lts" -Skus "server" -Version "latest" | `
      Add-AzVMNetworkInterface -Id $nic.Id
    Log-Message "Successfully created virtual machine configuration for '$vmName'."
} catch {
    Log-Message "Error creating virtual machine configuration for '$vmName': $_"
    exit 1
}

# Create the Virtual Machine
try {
    New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig
    Log-Message "Successfully created virtual machine '$vmName'."
} catch {
    Log-Message "Error creating virtual machine '$vmName': $_"
    exit 1
}

# Wait for VM to be fully provisioned with a countdown timer
$seconds = 120  # 2 minutes
while ($seconds -gt 0) {
    Write-Output "Waiting for VM to be fully provisioned... $seconds seconds remaining"
    Start-Sleep -Seconds 1
    $seconds--
}


Write-Output " Now Triggering the automation script "
# Trigger the second script for automation tasks
try {
    ./configurevm.ps1
    Log-Message "Successfully executed 'configurevm.ps1'."
} catch {
    Log-Message "Error executing 'configurevm.ps1': $_"
}
