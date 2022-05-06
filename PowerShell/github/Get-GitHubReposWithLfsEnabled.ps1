
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
    $PersonalAccessToken
)

begin {
    # TODO: Change repos to org after testing
    $orgReposApiEndpoint = "https://api.github.com/org/$Organization/repos"

    $headers = @{
        Accept = "application/vnd.github.v3+json"
        Authorization = "Token $PersonalAccessToken" 
    }
}

process {
    $reposWithGitLfs = New-Object System.Collections.ArrayList
    $repos = Invoke-RestMethod -Uri $orgReposApiEndpoint -Method Get -Headers $headers

    foreach ($repo in $repos){
        $repoContentsApiEndpoint = "https://api.github.com/repos/$Organization/$($repo.name)/contents/.gitattributes"
        
        try {
            $fileContent = Invoke-RestMethod -Uri $repoContentsApiEndpoint -Method Get -Headers $headers
            
            $webResponse = Invoke-WebRequest -Uri $fileContent.download_url -Headers $headers

            $gitAttributesFile = $webResponse.Content

            if($gitAttributesFile -match "filter=lfs") {
                $reposWithGitLfs.Add("$Organization/$($repo.name)") | Out-Null
            }
        } catch {
            if($_.Exception.Response.StatusCode.value__ -ne 404) {
                Write-Error "Unable to fetch contents for the repo $($repo.name)"
            }
        }
    }

    $reposWithGitLfs | Out-File -FilePath "git-lfs-repos.txt"
}

end {

}
