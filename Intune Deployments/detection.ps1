# Define the name of the Chocolatey package you want to detect

$packageName = "notepadplusplus" 

# Replace 'packagename' with the name of the Chocolatey package you want to detect

# Check if Chocolatey is installed
$chocoPath = "$env:ProgramData\Chocolatey\choco.exe"
if (-not (Test-Path $chocoPath)) {
    # Exit with an error code if Chocolatey is not found
    Exit 1
}

# Check if the specific package is installed
$packageInstalled = & $chocoPath list $packageName

# If the package is found, it means it's installed
if ($packageInstalled -like "*$packageName*") {
    # Exit with success code 0
    Write-Host "Software detected"
    Exit 0
} else {
    # Exit with an error code if the package is not found
    Write-Host "Software not detected"
    Exit 1
}
