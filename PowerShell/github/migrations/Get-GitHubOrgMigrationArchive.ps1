# TODO: Algin to best practices
# https://github.com/PoshCode/PowerShellPracticeAndStyle
[CmdletBinding()]
param
(
    [Parameter(Mandatory = $true)]
    [string]
    $Organization,

    [Parameter(Mandatory = $true)]
    [long]
    $MigrationId,

    [Parameter(Mandatory = $true)]
    [System.IO.DirectoryInfo]
    $DownloadPath,

    [Parameter(Mandatory = $true)]
    [string]
    $PersonalAccessToken
)

begin {
    # TODO: Change repos to org after testing
    $orgMigrationArchiveEndpoint = "https://api.github.com/orgs/$Organization/migrations/$MigrationId/archive"

    $headers = @{
        Accept = "application/vnd.github.v3+json"
        Authorization = "Token $PersonalAccessToken" 
    }

    if($DownloadPath.Exists -eq $false) {
        Write-Host "Creating the download folder"
        Write-Debug $DownloadPath.FullName
        $DownloadPath.Create()
    }

    $downloadFile = Join-Path $DownloadPath.FullName "$Organization-$MigrationId.tar.gz"
}

process {
    Invoke-WebRequest -Uri $orgMigrationArchiveEndpoint -Headers $headers -OutFile $downloadFile
}

end {

}