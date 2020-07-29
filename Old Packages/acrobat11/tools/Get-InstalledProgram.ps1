# This function checks to see if Adobe Acrobat XI is already installed on the computer.
# The function returns 2 when the program is installed and the latest version.
# The function returns 1 when the program is installed but out of date.
# If it meets neither condition it returns false.
function Get-InstalledProgram
{
    param
    (
        [cmdletbinding()]
    [string]$program,
    [string]$version
    )
        $64bitcheck = Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | 
        where -Property DisplayName -like "$program" | select displayname, displayversion

        $32bitcheck = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | 
        where -Property DisplayName -like "$program" | select displayname, displayversion

        if(($64bitcheck.DisplayVersion -eq "$version") -or ($32bitcheck.DisplayVersion -eq "$version"))
        {
            return 2
        }
        elseif(($64bitcheck.DisplayName -like "$Program") -or ($32bitcheck.DisplayName -like "$program"))
        {
            return 1
        }
        else
        {
            return $false
        }
}