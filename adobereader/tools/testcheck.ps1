$SoftwareKey = "HKLM:\Software" 
if ((Get-WmiObject Win32_OperatingSystem).OSArchitecture -match "64-bit") { $SoftwareKey = "HKLM:\Software\WOW6432Node" } 
$RegKey = "$SoftwareKey\Microsoft\Windows\CurrentVersion\Uninstall\{AC76BA86-7AD7-FFFF-7B44-AC0F074E4100}"
if (Test-Path "$RegKey") { 
echo "Key Detected. Checking version..."
 #$RegKey = Get-ChildItem "$SoftwareKey\Microsoft\Windows\CurrentVersion\Uninstall\{AC76BA86-7AD7-FFFF-7B44-AC0F074E4100}" -rec -ea SilentlyContinue | 
  #  Where-Object {(Get-ItemProperty -path $_.PSPath) -match "DisplayVersion"} | select -Property PSPath
  #echo $RegKey 
    $RegValue = Get-ItemPropertyValue -Path $RegKey -Name DisplayVersion
    echo $RegValue
#Nothing works below this point. 
$adobeversion = get-childitem "$SoftwareKey\Microsoft\Windows\CurrentVersion\Uninstall\{AC76BA86-7AD7-FFFF-7B44-AC0F074E4100}" 
echo $adobeversion
foreach ($version in ($adobeversion | Where-Object {$_.name = DisplayVersion})) { 
Write-Output "Found verstion $($version.PSChildName) of Adobe Reader" 
echo $version | Out-GridView
} 
}