#This packaged based off one creatd by Doc for the adblockplus install. Thanks Doc!

$packageName = 'ublockorigin-firefox'
$url = 'https://addons.cdn.mozilla.net/user-media/addons/607454/ublock_origin-1.18.2-an+fx.xpi?filehash=sha256%3Ae16599bd915ffa6827c5cff8cb22037b13f5a2ff534ead1e50d4e283d526b784'
$extensionName = "uBlock0@raymondhill.net.xpi" #Filename based off extension ID


#Find Firefox install location
if(test-path 'hklm:\SOFTWARE\Mozilla\Firefox\TaskBarIDs'){
	$installDir = Get-Item -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Mozilla\Firefox\TaskBarIDs | Select-Object -ExpandProperty Property
    echo "Install Path located via Registry"
}elseif(test-path 'hklm:\SOFTWARE\Wow6432Node\Mozilla\Firefox\TaskBarIDs'){
	$installDir = Get-Item -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Mozilla\Firefox\TaskBarIDs | Select-Object -ExpandProperty Property
    echo "Install path found via Wow6432Node in the registry"
}else{
throw "Firefox install not detected"
}

#Generate path for copy
$browserFolder = Join-Path $installDir "browser"
$extensionsFolder = Join-Path $browserFolder "extensions"
$extFile = Join-Path $extensionsFolder "$extensionName"


#Check to see if process running
$isrunning = Get-Process -Name firefox -ErrorAction SilentlyContinue
if ($isrunning){
    throw "Firefox running"
}


#Copy to Firefox system extensions folder
echo "Preparing to install to path $extFile"
try {
    Get-ChocolateyWebFile -PackageName 'uBlockOrigin-Firefox' -FileFullPath "$extFile" -url $url -ForceDownload
 }catch{
    echo "Error occured, fail to copy file."
 }
