try {

$arguments = @{}

  # Now we can use the $env:chocolateyPackageParameters inside the Chocolatey package
  $packageParameters = $env:chocolateyPackageParameters

  # Default value
  $32dir = $null
  $64dir = $null

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

      if ($arguments.ContainsKey("32dir")) {
          Write-Host "32dir Argument Found"
          $32dir = $arguments["32dir"]
          $32dir = "INSTALLDIR=`"$32dir`""
      }

      if ($arguments.ContainsKey("64dir")) {
          Write-Host "64dir Argument Found"
          $64dir = $arguments["64dir"]
          $64dir = "INSTALLDIR=`"$64dir`""
      }

  } else {
      Write-Debug "No Package Parameters Passed in"
  }

  $scriptDir = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
  # Import function to test if JRE in the same version is already installed
  Import-Module (Join-Path $scriptDir 'thisJreInstalled.ps1')
  Import-Module (Join-Path $scriptDir 'uninstall-oldJre.ps1')

  $packageName = 'jre8'
  # Find download URLs at http://www.java.com/en/download/manual.jsp
  $url = 'http://javadl.sun.com/webapps/download/AutoDL?BundleId=106246'
  $url64 = 'http://javadl.sun.com/webapps/download/AutoDL?BundleId=106248'
  $oldVersion = '8.0.40'
  $version = '8.0.45'
  $homepath = $version -replace "(\d+\.\d+)\.(\d+)",'jre1.$1_$2'
  $installerType = 'exe'
  $installArgs = "/s REBOOT=Suppress SPONSORS=0 $32dir"
  $installArgs64 = "/s REBOOT=Suppress SPONSORS=0 $64dir"
  $osBitness = Get-ProcessorBits
  
  # If both 32- and 64-bit versions are installed, it adds only the folder
  # of the 64-bit version to the env variables  
    
  if ($osBitness -eq 64 -and $arguments["64dir"]) {
     $javaHome = $arguments["64dir"]

  }elseif ($osBitness -eq 32 -and $arguments["32dir"]) {

     $javaHome = $arguments["32dir"]

  }else{

     $javaHome = Join-Path $env:ProgramFiles "Java\$homepath"

  }

  # Create variable for environment path
  $jreForPathVariable = Join-Path $javaHome 'bin'

  $thisJreInstalledHash = thisJreInstalled($version)
  $oldJreInstalledHash = thisJreInstalled($oldVersion)

  # This is the code for both javaruntime and javaruntime-platformspecific packages.
  # If the package is javaruntime-platformspecific, only install the jre version
  # based on the OS bitness, otherwise install both 32- and 64-bit versions
  if ($packageName -match 'platformspecific') {

    if ($thisJreInstalledHash.x86_32 -or $thisJreInstalledHash.x86_64) {
      Write-Output "Java Runtime Environment $version is already installed. Skipping download and installation to avoid 1603 errors."
    } else {
      Install-ChocolateyPackage $packageName $installerType $installArgs $url $url64
    }

  } else {
    # Otherwise it is the javaruntime package which installs both 32- and 64-bit jre versions on 64-bit systems

    # Checks if JRE 32/64-bit in the same version is already installed,
    # otherwise it downloads and installs it.
    # This is to avoid unnecessary downloads and 1603 errors.
    if ($thisJreInstalledHash.x86_32) {
      Write-Output "Java Runtime Environment $version (32-bit) is already installed. Skipping download and installation"
    } else {
      Install-ChocolateyPackage $packageName $installerType $installArgs $url
    }

    # Only check for the 64-bit version if the system is 64-bit

    if ($osBitness -eq 64) {
      if ($thisJreInstalledHash.x86_64) {
        Write-Output "Java Runtime Environment $version (64-bit) is already installed. Skipping download and installation"
      } else {
        # Here $url64 is used twice to obtain the correct message from Chocolatey
        # that it installed the 64-bit version, otherwise it would display 32-bit,
        # regardless of the actual bitness of the software.
        Install-ChocolateyPackage $packageName $installerType $installArgs64 $url64 $url64
      }
    }
  }

  #Uninstalls the previous version of Java if either version exists
  if(($oldJreInstalledHash.x86_32) -or ($oldJreInstalledHash.x86_64)){
  #  uninstall-oldJre($oldVersion)
  echo "This would have been Tristans uninstall script"
  }
  # Only set the entry for the PATH variable and the JAVA_HOME env variable
  # if the same version of JRE was not already installed (32- or 64-bit separately)
  if (!($thisJreInstalledHash.x86_32) -or !($thisJreInstalledHash.x86_64)) {

    Install-ChocolateyPath $jreForPathVariable 'Machine'
    Start-ChocolateyProcessAsAdmin @"
[Environment]::SetEnvironmentVariable('JAVA_HOME', '$javaHome', 'Machine')
"@
  }

} catch {
  #Write-ChocolateyFailure $packageName $($_.Exception.Message)
  throw
}