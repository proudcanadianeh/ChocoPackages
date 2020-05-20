$ErrorActionPreference = 'Stop'; 
$fullPackage = "3CXPhoneforWindows16.msi"
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url = 'https://downloads.3cx.com/downloads/' + $fullPackage 

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'msi' 
  url            = $url
  softwareName   = '3CX*'
  checksum       = 'cf20fab88aef95efd1c66a8de50a483999b67510b828b42eea0dcaa106d75527'
  checksumType   = 'sha256' 
  silentArgs     = "/qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`"" 
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs 