# TODO: Algin to best practices
# https://github.com/PoshCode/PowerShellPracticeAndStyle
[CmdletBinding()]
param
(
    [Parameter(Mandatory = $true)]
    [string]
    $Organization,

    [Parameter(Mandatory = $true)]
    [string]
    $Repository,

    [Parameter(Mandatory = $true)]
    [string]
    $PersonalAccessToken
)

begin {
    # TODO: Change repos to org after testing
    $deleteRepoEndpoint = "https://api.github.com/repos/$Organization/$Repository"

    $headers = @{
        Accept        = "application/vnd.github.v3+json"
        Authorization = "Token $PersonalAccessToken" 
    }
}

process {
    $response = Invoke-RestMethod -Uri $deleteRepoEndpoint -Method Delete -Headers $headers -Body $jsonPayload

    return $response
}

end {

}