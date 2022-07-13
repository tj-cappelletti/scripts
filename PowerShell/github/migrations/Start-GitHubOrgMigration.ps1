# TODO: Algin to best practices
# https://github.com/PoshCode/PowerShellPracticeAndStyle
[CmdletBinding()]
param
(
    [Parameter(Mandatory = $true)]
    [string]
    $Organization,

    [Parameter(Mandatory = $true)]
    [string[]]
    $Repositories,

    [bool]$LockRepositories = $false,

    [Parameter(Mandatory = $true)]
    [string]
    $PersonalAccessToken
)

begin {
    # TODO: Change repos to org after testing
    $orgMigrationEndpoint = "https://api.github.com/orgs/$Organization/migrations"

    $headers = @{
        Accept = "application/vnd.github.v3+json"
        Authorization = "Token $PersonalAccessToken" 
    }
}

process {
    $repos = New-Object System.Collections.ArrayList

    foreach($repo in $Repositories) {
        $repos.Add("$Organization/$repo")
    }

    $payload = @{
        lock_repositories = $LockRepositories
        repositories = $repos
    }

    $jsonPayload = ConvertTo-Json $payload

    Write-Host $jsonPayload

    $migration = Invoke-RestMethod -Uri $orgMigrationEndpoint -Method Post -Headers $headers -Body $jsonPayload

    return $migration
}

end {

}