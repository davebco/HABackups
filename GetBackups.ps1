param (
    $localPath = "C:\Users\daveb\OneDrive\Documents\HomeAutomation\HA_Backups\",
    $remotePath = "/backup/"
)
 
try
{
    # Load WinSCP .NET assembly
    Add-Type -Path "WinSCPnet.dll"
 
    # Setup session options
    $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
        Protocol = [WinSCP.Protocol]::Sftp
        HostName = "192.168.20.6"
        SshPrivateKeyPath= "C:\Users\daveb\OneDrive\Documents\HomeAutomation\HA_Backups\configs\PrivHA.ppk"
		UserName = "root"
        #Password = "mypassword"
        SshHostKeyFingerprint = "ssh-ed25519 255 lVy3xi22m14IEprAWPmw6sJ+lF3rJtzSzmfPrlgFpT4="
		
    }
 
    $session = New-Object WinSCP.Session
 
    try
    {
        # Connect
        $session.Open($sessionOptions)
		# Write-Host "Connected"
        # Get list of files in the directory
        $directoryInfo = $session.ListDirectory($remotePath)
 
        # Select the most recent file
        $latest =
            $directoryInfo.Files |
            Where-Object { -Not $_.IsDirectory } |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1
 
        # Any file at all?
        if ($latest -eq $Null)
        {
            # Write-Host "No file found"
            exit 1
        }
 
        # Download the selected file
        $session.GetFiles(
            [WinSCP.RemotePath]::EscapeFileMask($latest.FullName), $localPath).Check()
		# Write-Host "Backup Collected"	
    }
    finally
    {
        # Disconnect, clean up
        $session.Dispose()
		# Write-Host "Session Closed"
    }
 
    exit 0
}
catch
{
    # Write-Host "Error: $($_.Exception.Message)"
    exit 1
}
