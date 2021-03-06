### This code snippet is used to connect to an Azure Storage Account and tier all the blobs to Azure Archive Storage Tier.
### This script will require PS version 7+

### You need PowerShell module 4.4.0 or newer in order to be able to tier blobs to archive storage
#   install-module Azure -requiredVersion 4.4.0

### Import Azure PowerShell module
#   Import-Module Azure

### Login to your Azure Account
    Connect-AzAccount

### Storage Account information

    ### In case you have several subscriptions select the proper one
    Select-AzSubscription (Get-AzSubscription | Out-GridView -Title "Select your Azure Subscription" -PassThru)

    ### Select the Azure Resource Group and Storage Account
    $ResourceGroupName = (Get-AzResourceGroup | Out-GridView -Title "Select your Resource Group" -PassThru).ResourceGroupName
    $StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName | Out-GridView -Title "Select your Storage Account" -PassThru 
    $StorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccount.StorageAccountName)[0].Value
    
    ### Create a storage context
    $context = New-AzStorageContext -StorageAccountName $StorageAccount.StorageAccountName -StorageAccountKey $StorageAccountKey
    $containername = (Get-AzStorageContainer -Context $context | Out-GridView -Title "Select your Storage Container" -PassThru).name
    $blobs = Get-AzStorageBlob -Container $containerName -Context $context

### Use the .Net client library API to change the access tier
    Foreach ($blob in $blobs) {
        $blob.ICloudBlob.SetStandardBlobTier("Archive")
    }
