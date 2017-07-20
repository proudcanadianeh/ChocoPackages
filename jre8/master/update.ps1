import-module au
$releases = 'https://www.java.com/en/download/manual.jsp'

function global:au_BeforeUpdate {
	Get-RemoteFiles -Purge -FileNameBase "$($Latest.PackageName)Installer"
	$file = Get-Item ".\tools\*.exe" | select -First 1
	$Latest.fileVersion = $file.VersionInfo.ProductVersion -replace '((\d+.\d+.\d+.\d+))*','$1'
	Remove-Item ".\tools\*.exe" -Force # Removal of downloaded files
}

function global:au_SearchReplace {
	@{
		".\tools\packageArgs.ps1" = @{
			"(?i)(^\s*url\s*=\s*)('.*')" = "`$1'$($Latest.URL32)'"
			"(?i)(^\s*url64bit\s*=\s*)('.*')"	= "`$1'$($Latest.URL64)'"
			"(?i)(^\s*checksum\s*=\s*)('.*')" = "`$1'$($Latest.Checksum32)'"
			"(?i)(^\s*checksum64\s*=\s*)('.*')" = "`$1'$($Latest.Checksum64)'"
			"(^\s*oldVersion\s*=\s*)('.*')" = "`$1'$($Latest.oldVersion)'"
			"(^\s*version\s*=\s*)('.*')" = "`$1'$($Latest.fileVersion)'"
		}
	}
}

function global:au_GetLatest {
  
	$regex = '(\d\sUpdate\s\d{1,3})'
	$download_page = Invoke-WebRequest -UseBasicParsing $releases
	$download_page | foreach { $_ -match $regex } | Select -First 1 -skip 1
	$version = $Matches[0]
	$version = $version -replace(' Update ','.0.')
	$url32 = $download_page.Links | where{ ($_ -match "Offline" ) } | Select -First 1
	$url64 = $download_page.Links | where{ ($_ -match "(64-bit)" ) } | Select -First 1
	(Get-Item ".\tools\packageArgs.ps1" | Select-String "(?i)(^\s*version\s*=\s*)('.*')") -split "=|'" | foreach { $_ -match '(\d+.\d+.\d+.\d+)' }
	$oldVersion = $Matches[0]
	@{
		fileType	= 'exe'
		Version		= $version
		URL32		= $url32.href
		URL64		= $url64.href
		oldVersion	= $oldVersion
    }
}

update -ChecksumFor none
