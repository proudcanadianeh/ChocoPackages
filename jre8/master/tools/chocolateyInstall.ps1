try {

$arguments = @{}

  # Now we can use the $env:chocolateyPackageParameters inside the Chocolatey package
  $packageParameters = $env:chocolateyPackageParameters

  # Default value
  $exclude = $null

  # Now parse the packageParameters using good old regular expression
  if ($packageParameters) {
      $match_pattern = "\/(?<option>([a-zA-Z0-9]+)):(?<value>([`"'])?([a-zA-Z0-9- \(\)\s_\\:\.]+)([`"'])?)|\/(?<option>([a-zA-Z]+))"
      $option_name = 'option'
      $value_name = 'value'

      if ($packageParameters -match $match_pattern ){
          $results = $packageParameters | Select-String $match_pattern -AllMatches
          $results.matches | % {
            $arguments.Add(
                $_.Groups[$option_name].Value.Trim(),
                $_.Groups[$value_name].Value.Trim())
        }
      }
      else
      {
          Throw "Package Parameters were found but were invalid (REGEX Failure)"
      }

      if($arguments.ContainsKey("exclude")) {
          Write-Host "exclude Argument Found"
          $exclude = $arguments["exclude"]
      }

  } else {
      Write-Debug "No Package Parameters Passed in"
  }

  $scriptDir = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
  
  $packageName = 'jre8'
  # Modify these values -----------------------------------------------------
  # Find download URLs at http://www.java.com/en/download/manual.jsp
  $url = 'https://javadl.oracle.com/webapps/download/AutoDL?BundleId=238727_478a62b7d4e34b78b671c754eaaf38ab'
  $checksum32 = '47DE97325B8EA90EA9F93E1595CC7F843DA0C9C6E4C9532ABEA3A194CFB621D9'
  $url64 = 'https://javadl.oracle.com/webapps/download/AutoDL?BundleId=238729_478a62b7d4e34b78b671c754eaaf38ab'
  $checksum64 = 'C18CF8F2776B69DC838440AADFAAE36F50717636F38EEC5F1E4A27A8CB4F20FB'
  $oldVersion = '8.0.2010.9'
  $version = '8.0.2110.12'
  #--------------------------------------------------------------------------
  $homepath = $version -replace "(\d+\.\d+)\.(\d\d)(.*)",'jre1.$1_$2'
  $installerType = 'exe'
  $installArgs = "/s REBOOT=0 SPONSORS=0 AUTO_UPDATE=0 $32dir"
  $installArgs64 = "/s REBOOT=0 SPONSORS=0 AUTO_UPDATE=0 $64dir"
  $osBitness = Get-ProcessorBits
  $cachepath = "$env:temp\$packagename\$version"
  Write-Host "The software license has changed for Java and this software must be licensed for general business use. Please ensure your licensing is compliant before installing." -ForegroundColor white -BackgroundColor red
  #This checks to see if current version is already installed
  Write-Output "Checking to see if local install is already up to date..."
  try{
  $checkreg64 = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion | Where-Object { $_.DisplayName -like '*Java 8*' -and ([Version]$_.DisplayVersion) -eq $version} -ErrorAction SilentlyContinue
  $checkreg32 = Get-ItemProperty HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion | Where-Object { $_.DisplayName -like '*Java 8*' -and ([Version]$_.DisplayVersion) -eq $version} -ErrorAction SilentlyContinue
  }catch{
  Write-Output "Registry check failed. This is commonly caused by corrupt keys (Do you have netbeans installed?)"
  }

    # Checks if JRE 32/64-bit in the same version is already installed and if the user excluded 32-bit Java.
    # Otherwise it downloads and installs it.
    # This is to avoid unnecessary downloads and 1603 errors.
    if ($checkreg32 -ne $null) 
    {
      Write-Output "Java Runtime Environment $version (32-bit) is already installed. Skipping download and installation"
    } 
    elseif ($exclude -ne "32") 
    {
      Write-Output "Downloading 32-bit installer"
      Get-ChocolateyWebFile -packageName $packageName -fileFullPath "$cachepath\JRE8x86.exe" -url $url -checksum $checksum32 -checksumType 'SHA256'
      Write-Output "Installing JRE $version 32-bit"
      Install-ChocolateyInstallPackage -packageName JRE8 -fileType $installerType -silentArgs $installArgs -file "$cachepath\JRE8x86.exe"
      #Install-ChocolateyPackage $packageName $installerType $installArgs -url "$env:temp\chocolatey\$packagename\$version\JRE8x86.exe" -checksum $checksum32 -checksumtype 'sha256'
    } 
    else 
    {
      Write-Output "Java Runtime Environment $Version (32-bit) excluded for installation"
    }

    # Only check for the 64-bit version if the system is 64-bit

    if ($osBitness -eq 64) 
    {
      if ($checkreg64 -ne $null) 
      {
        Write-Output "Java Runtime Environment $version (64-bit) is already installed. Skipping download and installation"
      } 
      elseif ($exclude -ne "64") 
      {
        Write-Output "Downloading 64-bit installer"
        Get-ChocolateyWebFile -packageName $packageName -fileFullPath "$cachepath\JRE8x64.exe" -url64 $url64 -checksum64 $checksum64 -checksumType 'SHA256'
        Write-Output "Installing JRE $version 64-bit"
        Install-ChocolateyInstallPackage -packageName JRE8 -fileType $installerType -silentArgs $installArgs -file64 "$cachepath\JRE8x64.exe"

       # Install-ChocolateyPackage $packageName $installerType $installArgs64 -url64bit "$env:temp\chocolatey\$packagename\$version\JRE8x64.exe" -checksum64 $checksum64 -checksumtype64 'sha256'
      } 
      else 
      {
        Write-Output "Java Runtime Environment $Version (64-bit) excluded for installation"
      }
    }
  
  #Uninstalls the previous version of Java if either version exists
  Write-Output "Searching if the previous version exists..."
  $checkoldreg64 = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, PSChildName | Where-Object { $_.DisplayName -like '*Java 8*' -and ([Version]$_.DisplayVersion) -eq $oldversion} -ErrorAction SilentlyContinue
  $checkoldreg32 = Get-ItemProperty HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, PSChildName | Where-Object { $_.DisplayName -like '*Java 8*' -and ([Version]$_.DisplayVersion) -eq $oldversion} -ErrorAction SilentlyContinue
 
  if($checkoldreg32 -ne $null) 
  {
     Write-Warning "Uninstalling JRE version $oldVersion 32bit"
     $32 = $checkoldreg32.PSChildName
     Start-ChocolateyProcessAsAdmin "/qn /norestart /X$32" -exeToRun "msiexec.exe" -validExitCodes @(0,1605,3010)
  }
  if($checkoldreg64 -ne $null)
  {
     Write-Warning "Uninstalling JRE version $oldVersion $osBitness bit" #Formatted weird because this is used if run on a x86 install
     $64 = $checkoldreg64.PSChildName
     Start-ChocolateyProcessAsAdmin "/qn /norestart /X$64" -exeToRun "msiexec.exe" -validExitCodes @(0,1605,3010)
  }
} catch {
  #Write-ChocolateyFailure $packageName $($_.Exception.Message)
  throw
}
