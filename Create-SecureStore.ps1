Param(
    [Parameter(Mandatory = $True)]
    [string]
    $APIKey,
    [Parameter(Mandatory = $True)]
    [string]
    $Password,
    [Parameter()]
    [string]
    $SecretStoreName = "SecretStore"
)

function Check-Modules{
    Write-Host "Validating NuGet package installation"
    Install-PackageProvider -Name NuGet -Scope CurrentUser -Force
    
    # Check if Microsoft.PowerShell.SecretManagement and Microsoft.PowerShell.SecretStore are installed
    $SecretManagementInstalled = Get-Module -Name Microsoft.PowerShell.SecretManagement -ListAvailable
    $SecretStoreInstalled = Get-Module -Name Microsoft.PowerShell.SecretStore -ListAvailable

    # Install Microsoft.PowerShell.SecretManagement if not installed
    if (-not $SecretManagementInstalled) {
        Write-Host "Installing PowerShell Module Microsoft.PowerShell.SecretManagement"
        Install-Module -Name Microsoft.PowerShell.SecretManagement -Scope CurrentUser -Force
    }
    else {
        Write-Host "PowerShell Module Microsoft.PowerShell.SecretManagement already installed"
    }
    # Install Microsoft.PowerShell.SecretStore if not installed
    if (-not $SecretStoreInstalled) {
        Write-Host "Installing PowerShell Module Microsoft.PowerShell.SecretStore"
        Install-Module -Name Microsoft.PowerShell.SecretStore -Scope CurrentUser -Force
    }
    else {
        Write-Host "PowerShell Module Microsoft.PowerShell.SecretStore already installed"
    }
}
function Check-SecretStore {
    Param(
        [Parameter()]
        [string]
        $SecretStoreName = "SecretStore"
    )
    $SecretVault = Get-SecretVault -Name $SecretStoreName
    if (-not $SecretVault) {
        Write-Host "Creating a SecretStore"
        Register-SecretVault -Name $SecretStoreName -ModuleName Microsoft.Powershell.SecretStore -DefaultVault
    }
}
function Store-Secret {
    Param(
    [Parameter(Mandatory = $True)]
    [string]
    $APIKey,
    [Parameter()]
    [string]
    $SecretStoreName = "SecretStore"
    )
    Write-Host "Saving API Key"
    Set-Secret -Name $SecretStoreName -Secret $APIKey
}

$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force

Check-Modules

#need to check line below and secure string stuff all untested.

Set-SecretStoreConfiguration -Scope CurrentUser -Authentication Pasword -PasswordTimeout 3600 -Interaction None -Password $SecurePassword -Confirm:$false

Check-SecretStore -SecretStoreName $SecretStoreName
#Store-Secret  -SecretStoreName $SecretStoreName -APIKey $APIKey


