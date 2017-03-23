param (
    [string]$tfsServer = "http://tfstest.rauland.com:8080/tfs/DefaultCollection",
    [string]$tfsLocation = "$\SoftwareEng\Enterprise\dev",
    [string]$localFolder ="C:\temp\source\dev",
    [string]$file,
    [string]$checkInComments = "Checked in from PowerShell"
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

#Create a "workspace" and map a local folder to a TFS location
$workspace = $versionControlServer.CreateWorkspace("PowerShell Workspace",$versionControlServer.AuthenticatedUser)
$workingfolder = New-Object Microsoft.TeamFoundation.VersionControl.Client.WorkingFolder($tfsLocation,$localFolder)
$workspace.CreateMapping($workingFolder)
$filePath = $localFolder + "\" + $file

#Submit file as a Pending Change and submit the change
$workspace.PendAdd($filePath)
$pendingChanges = $workspace.GetPendingChanges()
$workspace.CheckIn($pendingChanges,$checkInComments)

#Delete the temp workspace
$workspace.Delete()
