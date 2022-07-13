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
    $orgMigrationEndpoint = "https://api.github.com/orgs/$Organization/migrations/$MigrationId"

    $headers = @{
        Accept = "application/vnd.github.v3+json"
        Authorization = "Token $PersonalAccessToken" 
    }
}

process {
    $migration = Invoke-RestMethod -Uri $orgMigrationEndpoint -Method Get -Headers $headers

    return $migration
}

end {

}