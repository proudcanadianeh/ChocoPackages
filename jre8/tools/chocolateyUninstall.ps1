Write-Debug ("Starting " + $MyInvocation.MyCommand.Definition)

[string]$packageName="Javaruntime"

<#
Exit Codes:
    0: Java installed successfully.
    1605: Java is not installed.
    3010: A reboot is required to finish the install.
#>

Start-ChocolateyProcessAsAdmin "/qn /norestart /X{26A24AE4-039D-4CA4-87B4-2F83218045F0}" -exeToRun "msiexec.exe" -validExitCodes @(0,1605,3010) 
Start-ChocolateyProcessAsAdmin "/qn /norestart /X{26A24AE4-039D-4CA4-87B4-2F86418045F0}" -exeToRun "msiexec.exe" -validExitCodes @(0,1605,3010)

Write-Warning "$packageName may require a reboot to complete the uninstallation."