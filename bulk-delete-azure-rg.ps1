
<#
.SYNOPSIS
This script is designed to manage Azure Resource Groups interactively.

.DESCRIPTION
The script provides a menu-driven approach to list all Azure Resource Groups within a selected subscription,
allows the user to select multiple groups for deletion, and handles multi-factor authentication.

.PREREQUISITES
- The user must have the Azure PowerShell module installed.
- The user must have permissions to manage resource groups and subscriptions in Azure.

.INSTRUCTIONS
1. Run the script in a PowerShell terminal.
2. When prompted, enter your Azure Tenant ID.
3. Select an Azure subscription by its corresponding number.
4. Select the resource groups you wish to delete by entering their corresponding numbers.
5. Confirm your choices when prompted.

.NOTES
Author: Walid Hocine
Last Updated: 12/12/2023
Please ensure that you have the necessary permissions to delete resource groups, as this action is irreversible.

.EXAMPLE
PS> .\ManageAzureResourceGroups.ps1



#>


# Ensure Azure PowerShell is installed
Install-Module -Name Az -AllowClobber -Scope CurrentUser

# Ensure the InteractiveMenu module is imported
Import-Module -Name InteractiveMenu

function Show-ResourceGroupMenu {
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.ObjectModel.ObservableCollection[Object]]$ResourceGroups
    )

    # Display resource groups with index numbers
    Write-Host "Available Resource Groups:"
    for ($i = 0; $i -lt $ResourceGroups.Count; $i++) {
        Write-Host "$($i + 1): $($ResourceGroups[$i].ResourceGroupName)"
    }

    # Ask the user to enter the numbers of the resource groups they wish to delete
    $selectedNumbers = Read-Host "Enter the numbers of the resource groups to select (separated by commas)"
    $selectedIndices = $selectedNumbers -split ',' | ForEach-Object { [int]$_ - 1 }

    $selectedResourceGroupNames = $ResourceGroups | Where-Object { $selectedIndices -contains $ResourceGroups.IndexOf($_) } | ForEach-Object { $_.ResourceGroupName }

    return $selectedResourceGroupNames
}

# Get all resource groups in the subscription
$resourceGroups = Get-AzResourceGroup | Sort-Object ResourceGroupName
$resourceGroupCollection = [System.Collections.ObjectModel.ObservableCollection[Object]]::new($resourceGroups)

# Show the menu to the user for selection
$selectedResourceGroupNames = Show-ResourceGroupMenu -ResourceGroups $resourceGroupCollection

# Continue with your script to confirm deletion and delete the selected resource groups...



# Function to delete the selected resource groups
function Delete-ResourceGroups {
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$ResourceGroupNames
    )

    foreach ($name in $ResourceGroupNames) {
        try {
            Write-Host "Attempting to delete resource group: $name..."
            # Initiating deletion without -AsJob to wait for the operation to complete synchronously
            $deletionResult = Remove-AzResourceGroup -Name $name -Force
            if ($deletionResult.ProvisioningState -eq 'Succeeded') {
                Write-Host "Successfully deleted resource group: $name" -ForegroundColor Green
            } else {
                Write-Host "Deletion initiated for resource group: $name, please verify in the Azure portal." -ForegroundColor Yellow
            }
        } catch {
            Write-Host "Failed to delete resource group: $name. Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Authenticate with Azure
# Ask the user for their Azure Tenant ID
$tenantId = Read-Host "Please enter your Azure Tenant ID"

# Attempt to authenticate with Azure
try {
    Connect-AzAccount -TenantId $tenantId
} catch {
    Write-Host "An error occurred while trying to authenticate: $($_.Exception.Message)"
    exit
}

# Get the list of subscriptions
$subscriptions = Get-AzSubscription | Sort-Object -Property Name

# Display subscriptions to the user
Write-Host "Please select a subscription to manage resource groups:"
for ($i = 0; $i -lt $subscriptions.Count; $i++) {
    Write-Host "$($i + 1): $($subscriptions[$i].Name) (ID: $($subscriptions[$i].Id))"
}

# Ask the user to choose a subscription by number
$selectedSubscriptionNumber = Read-Host "Enter the number of the subscription you want to manage"
$selectedSubscription = $subscriptions[$selectedSubscriptionNumber - 1]

if ($selectedSubscription -eq $null) {
    Write-Host "Invalid subscription number. Exiting script."
    exit
}

# Set the context to the selected subscription
Set-AzContext -SubscriptionId $selectedSubscription.Id



# Now that the user's context is set to the chosen subscription, continue with the resource group retrieval
$resourceGroups = Get-AzResourceGroup | Sort-Object ResourceGroupName
$resourceGroupCollection = [System.Collections.ObjectModel.ObservableCollection[Object]]::new($resourceGroups)

# If the collection is null or empty, exit the script
if (-not $resourceGroups) {
    Write-Host "Failed to retrieve resource groups or no resource groups exist in the selected subscription."
    exit
}

# Get all resource groups in the subscription
$resourceGroups = Get-AzResourceGroup | Sort-Object ResourceGroupName
$resourceGroupCollection = [System.Collections.ObjectModel.ObservableCollection[Object]]::new($resourceGroups)

# Show the menu to the user for selection
$selectedResourceGroupNames = Show-ResourceGroupMenu -ResourceGroups $resourceGroupCollection

# Confirm deletion with the user
if ($selectedResourceGroupNames.Count -gt 0) {
    $confirmation = Read-Host "You have selected the following resource groups for deletion: $($selectedResourceGroupNames -join ', '). Are you sure you want to delete? (yes/no)"
    if ($confirmation -eq 'yes') {
        Delete-ResourceGroups -ResourceGroupNames $selectedResourceGroupNames
    } else {
        Write-Host "Deletion cancelled by user."
    }
} else {
    Write-Host "No resource groups have been selected for deletion."
}
