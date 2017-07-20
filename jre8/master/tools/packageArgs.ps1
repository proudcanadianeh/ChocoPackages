# Due to a big in AU. This package requires that all package Arguments be in this hashtable

$packageArgs = @{
	oldVersion		= '8.0.1310.11'
	version			= '8.0.1410.15'
	packageName		= 'jre8'
	fileType		= 'exe'
	url				= 'http://javadl.oracle.com/webapps/download/AutoDL?BundleId=224927_336fa29ff2bb4ef291e347e091f7f4a7'
	url64bit		= 'http://javadl.oracle.com/webapps/download/AutoDL?BundleId=224929_336fa29ff2bb4ef291e347e091f7f4a7'
	silentArgs		= '/s REBOOT=0 SPONSORS=0 REMOVEOUTOFDATEJRES=1'
	validExitCodes	= @(0)
	softwareName  	= 'Java SE Runtime Environment'
	checksum		= 'D4AF33F78232898678488FF3747172209720A47460F4156032644D66A2B716CC'
	checksumType	= 'sha256'
	checksum64		= '5DD58AA25FA52DD3F35029F5C77CA9D94DE6CBCE89AB906008E0E3DD887C3F32'
	checksumType64	= 'sha256'
}
