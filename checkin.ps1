param (
    [string]$tfsServer = "http://tfstest.rauland.com:8080/tfs/DefaultCollection",
    [string]$tfsLocation = "$\SoftwareEng\Enterprise\dev",
    [string]$remoteFolder
)
$clientDll = "C:\Program Files (x86)\Microsoft Team Foundation Server 2015 Power Tools\Microsoft.TeamFoundation.Client.dll"
$versionControlClientDll = "C:\Program Files (x86)\Microsoft Team Foundation Server 2015 Power Tools\Microsoft.TeamFoundation.VersionControl.Client.dll"
$versionControlCommonDll = "C:\Program Files (x86)\Microsoft Team Foundation Server 2015 Power Tools\Microsoft.TeamFoundation.VersionControl.Common.dll"

#Load the Assemblies
[Reflection.Assembly]::LoadFrom($clientDll)
[Reflection.Assembly]::LoadFrom($versionControlClientDll)
[Reflection.Assembly]::LoadFrom($versionControlCommonDll)

#Set up connection to TFS Server and get version control
$tfs = [Microsoft.TeamFoundation.Client.TeamFoundationServerFactory]::GetServer($tfsServer)
$versionControlType = [Microsoft.TeamFoundation.VersionControl.Client.VersionControlServer]
$versionControlServer = $tfs.GetService($versionControlType)

$temporaryWorkSpaceName = "PS workspace $(Get-Random)"

#Create a "workspace" and map a local folder to a TFS location
$workspace = $versionControlServer.CreateWorkspace($temporaryWorkSpaceName, $versionControlServer.AuthenticatedUser)

$localFolder = Get-Location

$workingfolder = New-Object Microsoft.TeamFoundation.VersionControl.Client.WorkingFolder($tfsLocation, $localFolder)
$workspace.CreateMapping($workingFolder)

#get latest
$workspace.Get()

#now copy recursively from the "new code directory"
copy-item $remoteFolder\* -Destination $localFolder -Force -Recurse -Verbose -Exclude '$tf'

$filestoadd = gci -recurse

foreach ($sfile in $filestoadd) { $workspace.PendAdd($sfile.FullName) }


#Submit file as a Pending Change and submit the change
#$workspace.PendAdd($filePath)
$pendingChanges = $workspace.GetPendingChanges()
$workspace.CheckIn($pendingChanges,$checkInComments)

#Delete the temp workspace
#$workspace.Delete()