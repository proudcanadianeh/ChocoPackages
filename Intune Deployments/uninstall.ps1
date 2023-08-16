param(
    [string]$packageName
)

if (choco list | Select-String $packageName) {
    choco uninstall $packageName -y -x
    # Output a value that can be used by Intune for a detection rule
    Write-Output "Uninstalled"
} else {
    # Output a value that can be used by Intune for a detection rule
    Write-Output "NotInstalled"
}
