# Azure Resource Group Management Script

This PowerShell script is designed to help manage Azure Resource Groups. It allows for listing of all resource groups within a subscription, interactive selection for deletion, and handling of multi-factor authentication and multiple subscriptions.

## Prerequisites

- Azure PowerShell module
- PowerShell 5.1 or later
- An Azure account with permissions to manage resource groups and subscriptions

## Installation

Before running the script, ensure that the Azure PowerShell module is installed:

```powershell```
Install-Module -Name Az -AllowClobber -Scope CurrentUser

## Usage
Run the script in a PowerShell terminal. You will be prompted to:

Enter your Azure Tenant ID for authentication.
Choose a subscription from the listed Azure subscriptions.
Select resource groups by number that you wish to delete.
Confirm the deletion of the selected resource groups.
The script will handle deletion of the resource groups and provide feedback on the operations performed.

## Features
Tenant Authentication: Prompts for Azure Tenant ID and handles multi-factor authentication.
Subscription Selection: Lists all available subscriptions and allows you to select one by number.
Resource Group Selection: Lists all resource groups and allows interactive selection for deletion by number.
Deletion Confirmation: Requires confirmation before deleting selected resource groups.
Verbose Feedback: Provides detailed feedback on the deletion process.

#Author

Walid Hocine 
