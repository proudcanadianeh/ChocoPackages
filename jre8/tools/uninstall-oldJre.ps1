function uninstall-oldJre ($oldVersion)
{
    Write-Debug ("Starting the uninstallation of JRE version $oldVersion")
    <#
    Exit Codes:
    0: Java installed successfully.
    1605: Java is not installed.
    3010: A reboot is required to finish the install.
    #>
    Write-Warning "Uninstalling JRE version $oldVersion"
    Start-ChocolateyProcessAsAdmin "/qn /norestart /X{26A24AE4-039D-4CA4-87B4-2F83218040F0}" -exeToRun "msiexec.exe" -validExitCodes @(0,1605,3010) 
    Start-ChocolateyProcessAsAdmin "/qn /norestart /X{26A24AE4-039D-4CA4-87B4-2F86418040F0}" -exeToRun "msiexec.exe" -validExitCodes @(0,1605,3010)
    Write-Warning "The computer may require a reboot to finish the uninstallation"
}