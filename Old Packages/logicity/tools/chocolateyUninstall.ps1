$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
Echo "Starting Crystal uninstall. This will take some time..."
Start-Process -filepath msiexec.exe -argumentlist "/x ""$scriptpath\CRRuntime_32bit_13_0_8.msi"" /qn /norestart /log ""$scriptpath\crystal.log""" -wait
echo "Crystal removed. Initiating Logicity uninstall..."
Start-Process -filepath msiexec.exe -argumentlist "/x ""$scriptpath\SaberLogic Logicity 1.7.0018 Setup.msi"" /qn /norestart /log ""$scriptpath\logicity.log""" -wait
