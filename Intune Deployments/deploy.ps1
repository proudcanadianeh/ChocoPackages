<#
.SYNOPSIS
A script to install, upgrade, or uninstall a Chocolatey package.

.DESCRIPTION
This script checks if a specified Chocolatey package is installed. If it is, the script upgrades the package if the DeploymentType is "Install". 
If it's not, the script installs the package if the DeploymentType is "Install". If the DeploymentType is "Uninstall", the script uninstalls the package. 
The script also supports specifying a version for the package to be installed or uninstalled.

.PARAMETER packageName
The name of the package to install, upgrade, or uninstall.

.PARAMETER DeploymentType
The type of deployment to perform. Valid values are "Install" and "Uninstall".

.PARAMETER Version
(Optional) The version of the package to install or uninstall. If not specified, the latest version will be installed or any version will be uninstalled.

.EXAMPLE
.\deploy.ps1 -packageName git -DeploymentType Install
This example installs or upgrades the git package.

.EXAMPLE
.\deploy.ps1 -packageName git -DeploymentType Uninstall
This example uninstalls the git package.

.EXAMPLE
.\deploy.ps1 -packageName git -DeploymentType Install -Version 2.32.0
This example installs or upgrades the git package to version 2.32.0.

.EXAMPLE
.\deploy.ps1 -packageName git -DeploymentType Uninstall -Version 2.32.0
This example uninstalls the git package version 2.32.0.

.NOTES
The script exits with a status of 1 if the Chocolatey command fails, and 0 otherwise.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$packageName,

    [Parameter(Mandatory=$true)]
    [ValidateSet("Install","Uninstall")]
    [string]$DeploymentType,

    [string]$Version
)

### SETUP
##check logging
# Check if the event source "CustomScript" already exists for the Application log, if not create it
try{
    if (-not [System.Diagnostics.EventLog]::SourceExists("CustomScript")) {
        New-EventLog -LogName Application -Source "CustomScript"
    }
}
catch{
    # Cannot create error log, exit with error code
    Exit 1
}

##check if chocolatey exists, if not, write to event log and exit with 1
$chocoPath = "$env:ProgramData\Chocolatey\choco.exe"
if(-not (Test-Path $chocoPath)){
    # Cannot find chocolatey, exit with error code
    Write-EventLog -LogName Application -Source "CustomScript" -EntryType Information -EventId 1001 -Message "Chocolatey not found, exiting."
    Exit 1
}

### MAIN
##  INSTALL
#if the deploymenttype is install, check if the package is installed, then upgrade or install, if version is specified, use that version
if ($DeploymentType -eq "Install") {
    # Check if package is already installed, if so, upgrade it
    $packageExists = choco list | Select-String $packageName
    if ($packageExists) {
        if ($Version) {
            choco upgrade $packageName -y --version=$Version
        } else {
            choco upgrade $packageName -y
        }
    } else {
        # package doesn't exist, install it
        if ($Version) {
            choco install $packageName -y --version=$Version
        } else {
            choco install $packageName -y
        }
    }
}

## UNINSTALL
# if the deploymenttype is uninstall, check if the package is installed, then uninstall, if version is specified, use that version
if ($DeploymentType -eq "Uninstall") {
    $packageExists = choco list | Select-String $packageName
    if ($packageExists) {
        if ($Version) {
            choco uninstall $packageName -y --version=$Version
        } else {
            choco uninstall $packageName -y
        }
    } else {
        Write-EventLog -LogName Application -Source "CustomScript" -EntryType Information -EventId 1001 -Message "Choco list could not identify $packageName. Nothing to uninstall. Exiting."
    }
}

## HANDLE ERRORS
# Check the exit code of the Chocolatey install command
if ($LASTEXITCODE -ne 0) {
    # Exit with an error code
    Write-EventLog -LogName Application -Source "CustomScript" -EntryType Information -EventId 1001 -Message "Choco $Deploymenttype $packageName failed, exiting with code $LASTEXITCODE."
    exit 1
}
else{
    Write-EventLog -LogName Application -Source "CustomScript" -EntryType Information -EventId 1000 -Message "Choco $Deploymenttype $packageName successful."
    exit 0
}
