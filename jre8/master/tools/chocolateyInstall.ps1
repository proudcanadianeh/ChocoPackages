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
  # Import function to test if JRE in the same version is already installed. Legacy, phasing out. 
  # Import-Module (Join-Path $scriptDir 'thisJreInstalled.ps1')
  
  $packageName = 'jre8'
  # Modify these values -----------------------------------------------------
  # Find download URLs at http://www.java.com/en/download/manual.jsp
  $url = 'https://javadl.oracle.com/webapps/download/AutoDL?BundleId=234472_96a7b8442fe848ef90c96a2fad6ed6d1'
  $checksum32 = '9E5E6A1C5D26D93454751E65486F728233FDAC3B50FF763F6709FB87DD960CE5'
  $url64 = 'http://javadl.oracle.com/webapps/download/AutoDL?BundleId=234474_96a7b8442fe848ef90c96a2fad6ed6d1'
  $checksum64 = 'CD2F756133D59525869ACB605A54EFD132FCD7EAF53E2EC040D92EF40A2EA60A'
  $oldVersion = '8.0.1710.11'
  $version = '8.0.1810.13'
  #--------------------------------------------------------------------------
  $homepath = $version -replace "(\d+\.\d+)\.(\d\d)(.*)",'jre1.$1_$2'
  $installerType = 'exe'
  $installArgs = "/s REBOOT=0 SPONSORS=0 AUTO_UPDATE=0 $32dir"
  $installArgs64 = "/s REBOOT=0 SPONSORS=0 AUTO_UPDATE=0 $64dir"
  $osBitness = Get-ProcessorBits
   
  Write-Output "Searching if new version exists..."
  $checkreg64 = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion | Where-Object { $_.DisplayName -like '*Java 8*' -and ([Version]$_.DisplayVersion) -eq $version} -ErrorAction SilentlyContinue
  $checkreg32 = Get-ItemProperty HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion | Where-Object { $_.DisplayName -like '*Java 8*' -and ([Version]$_.DisplayVersion) -eq $version} -ErrorAction SilentlyContinue

  #$thisJreInstalledHash = thisJreInstalled($version)


    # Checks if JRE 32/64-bit in the same version is already installed and if the user excluded 32-bit Java.
    # Otherwise it downloads and installs it.
    # This is to avoid unnecessary downloads and 1603 errors.
    if ($checkreg32 -ne $null) 
    {
      Write-Output "Java Runtime Environment $version (32-bit) is already installed. Skipping download and installation"
    } 
    elseif ($exclude -ne "32") 
    {
      Install-ChocolateyPackage $packageName $installerType $installArgs $url -checksum $checksum32 -checksumtype 'sha256'
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
        Install-ChocolateyPackage $packageName $installerType $installArgs64 -url64bit $url64 -checksum64 $checksum64 -checksumtype64 'sha256'
      } 
      else 
      {
        Write-Output "Java Runtime Environment $Version (64-bit) excluded for installation"
      }
    }
  
  #Uninstalls the previous version of Java if either version exists
  Write-Output "Searching if the previous version exists..."
  #$oldJreInstalledHash = thisJreInstalled($oldVersion)
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
     Write-Warning "Uninstalling JRE version $oldVersion 64bit"
     $64 = $checkoldreg64.PSChildName
     Start-ChocolateyProcessAsAdmin "/qn /norestart /X$64" -exeToRun "msiexec.exe" -validExitCodes @(0,1605,3010)
  }
} catch {
  #Write-ChocolateyFailure $packageName $($_.Exception.Message)
  throw
}
