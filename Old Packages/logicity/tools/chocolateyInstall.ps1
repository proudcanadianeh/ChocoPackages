$packageName = 'Logicity'
$installerType = 'MSI'
$url = 'http://www.logicitysuite.com/docman-files/saberlogic-logicity-1-7-msi.zip'
$validExitCodes = @(0) 

Install-ChocolateyZipPackage "$packageName" "$url" "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
Echo "Starting Crystal install. This will take some time..."
Start-Process -filepath msiexec.exe -argumentlist "/i ""$scriptpath\CRRuntime_32bit_13_0_8.msi"" ALLUSERS=1 /qn /norestart /log ""$scriptpath\crystal.log"" UPGRADE=1" -wait
echo "Crystal installed. Initiating Logicity install..."
Start-Process -filepath msiexec.exe -argumentlist "/i ""$scriptpath\SaberLogic Logicity 1.7.0018 Setup.msi"" ALLUSERS=1 /qn /norestart /log ""$scriptpath\logicity.log""" -wait
echo "Finished Logicity!"