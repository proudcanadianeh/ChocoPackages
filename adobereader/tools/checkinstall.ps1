# This function checks if the same version of reader is already installed on the computer.
# It returns a hash map with a 'x86_32' and 'x86_64'. These values are not empty if the
# same version and bitness of reader is already installed.
#This script has been modied from the JRE8 package

function checkversion($version) {
  $productSearch = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -match '^Adobe \d+ Reader \d+'}

  # The regexes for the name of the JRE registry entries (32- and 64 bit versions)
  $nameRegex = '^Adobe Acrobat Reader $'
  $versionRegex = $('^' + $version + '\d*$')
 

  return @{
    'checkinstall' = $productSearch | Where-Object {$_.Name -match $nameRegex -and $_.Version -match $version
   }
   
  }
}
