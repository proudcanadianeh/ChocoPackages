Write-Debug ("Starting " + $MyInvocation.MyCommand.Definition)

$scriptDir = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
# Import function to test if JRE in the same version is already installed
Import-Module (Join-Path $scriptDir 'thisJreInstalled.ps1')

[string]$packageName="Javaruntime"
$version = '8.0.1010.13'
$thisJreInstalledHash = thisJreInstalled($version)

<#
Exit Codes:
    0: Java installed successfully.
    1605: Java is not installed.
    3010: A reboot is required to finish the install.
#>

if($thisJreInstalledHash[0]) 
  {
     Write-Warning "Uninstalling JRE version $Version 32bit"
     $32 = $thisJreInstalledHash[0].IdentifyingNumber
     Start-ChocolateyProcessAsAdmin "/qn /norestart /X$32" -exeToRun "msiexec.exe" -validExitCodes @(0,1605,3010)
  }
  if($thisJreInstalledHash[1])
  {
     Write-Warning "Uninstalling JRE version $Version 64bit"
     $64 = $thisJreInstalledHash[1].IdentifyingNumber
     Start-ChocolateyProcessAsAdmin "/qn /norestart /X$64" -exeToRun "msiexec.exe" -validExitCodes @(0,1605,3010)
  }

Write-Warning "$packageName may require a reboot to complete the uninstallation."