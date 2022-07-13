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
    [string]
    $PersonalAccessToken
)

begin {
    # TODO: Change repos to org after testing
    $orgMigrationArchiveEndpoint = "https://api.github.com/orgs/$Organization/migrations/$MigrationId/archive"

    Write-Debug "API Endpoint: $orgMigrationArchiveEndpoint"

    $headers = @{
        Accept = "application/vnd.github.v3+json"
        Authorization = "Token $PersonalAccessToken" 
    }
}

process {
    $request = [System.Net.WebRequest]::Create($orgMigrationArchiveEndpoint)
    $request.AllowAutoRedirect = $false
    $request.Headers.Add("Accecpt", "application/vnd.github.v3+json")
    $request.Headers.Add("Authorization", "Bearer $PersonalAccessToken")
    $request.PreAuthenticate = $true

    Write-Host $request.Headers
    
    $request.GetResponse()
}

end {

}