$scriptDir = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
#Import function to test if JRE in the same version is already installed
Import-Module (Join-Path $scriptDir 'Get-InstalledProgram.ps1')

$webclient = New-Object System.Net.WebClient
$installer = "AcrobatUpd11010.msp"
#The * checks for either standard or pro versions of acrobat
$program = 'Adobe Acrobat XI*'
$version = '11.0.10'
$url = 'http://ardownload.adobe.com/pub/adobe/acrobat/win/11.x/11.0.10/misc/AcrobatUpd11010.msp'
$destination = "C:\temp"
$installArgs = "/qn /norestart /update c:\temp\$installer"

#Checks the installed version of Adobe Acrobat and version
$result = (Get-InstalledProgram $program $version)
#Checks to see if Adobe Acrobat is installed on the computer
if($result -eq $false)
{
    throw "Adobe Acrobat is not installed on the computer terminating script"
}
elseif($result -eq 2)
{
    Write-Host "Adobe Acrobat is already installed with the latest version"
}
else
{
    #Checks to see if the $destination path exists. If not it creates the directory.
    if(!(Test-Path -Path $destination))
    {
        New-Item -Path $destination -ItemType Directory
    }

    #Downloads the update from the web and stores it in a temporary directory.
    Write-Verbose "Downloading the installer"
    $webclient.DownloadFile($url,"$destination\$installer")

    #Installs the update silently and waits for an exit code before removing the updater.
    $exitCode = (Start-Process msiexec.exe -ArgumentList "$installArgs" -Wait -PassThru).ExitCode
    if($exitCode -eq 0)
    {
        Write-Host "Upgrade to Acrobat $version was successful"
    }
    elseif($exitCode -eq 3010)
    {
        Write-Host "Reboot required to finished installation"
    }
    else
    {
        Write-Error "The upgrade was uncessfull error code: $exitCode"
        Remove-Item -Path $destination`\$installer
        throw $exitCode
    }
    Remove-Item -Path $destination`\$installer
}