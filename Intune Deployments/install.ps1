param(
    [string]$packageName
)

# Check if package is already installed
$packageExists = choco list | Select-String $packageName

if ($packageExists) {
    choco upgrade $packageName -y
    # Check the exit code of the Chocolatey upgrade command
    if ($LASTEXITCODE -ne 0) {
        # Exit with an error code
        exit 1
    }
} else {
    choco install $packageName -y
    # Check the exit code of the Chocolatey install command
    if ($LASTEXITCODE -ne 0) {
        # Exit with an error code
        exit 1
    }
}

# If we've made it here, it means everything was successful
exit 0
