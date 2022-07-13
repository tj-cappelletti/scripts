# TODO: Algin to best practices
# https://github.com/PoshCode/PowerShellPracticeAndStyle
[CmdletBinding()]
param
(
    [Parameter(Mandatory = $true)]
    [string]
    $Organization,

    [string[]]
    $Repositories,

    [Parameter(Mandatory = $true)]
    [string]
    $PersonalAccessToken
)

begin {
    # TODO: Change repos to org after testing
    $orgReposApiEndpoint = "https://api.github.com/orgs/$Organization/repos"

    $headers = @{
        Accept = "application/vnd.github.v3+json"
        Authorization = "Token $PersonalAccessToken" 
    }

    if($null -eq $Repositories -or $Repositories.Count -eq 0) {
        $orgReposResponse = Invoke-RestMethod -Uri $orgReposApiEndpoint -Method Get -Headers $headers
        $repos = $orgReposResponse | Select-Object -ExpandProperty name
    } else {
        $repos = $Repositories
    }
}

process {
    $reposWithGitLfs = New-Object System.Collections.ArrayList

    foreach ($repo in $repos){
        $repoContentsApiEndpoint = "https://api.github.com/repos/$Organization/$($repo)/contents/.gitattributes"
        
        try {
            Write-Host "Fetching .gitattributes file in $Organization/$($repo)..."
            Write-Debug "Getting file contents in $($repo)..."
            Write-Debug "REST Endpoint: $repoContentsApiEndpoint"
            $fileContent = Invoke-RestMethod -Uri $repoContentsApiEndpoint -Method Get -Headers $headers
            
            Write-Debug "Getting raw file contents in $($repo)..."
            Write-Debug "File URL: $($fileContent.download_url)..."
            $webResponse = Invoke-WebRequest -Uri $fileContent.download_url -Headers $headers

            Write-Debug "File contents:`r`n$($webResponse.Content)"

            $gitAttributesFile = $webResponse.Content

            Write-Debug "Checking file contents for match..."
            if($gitAttributesFile -match "filter=lfs") {
                Write-Debug "Match found, adding to array list..."
                $reposWithGitLfs.Add("$Organization/$($repo)") | Out-Null
            }
        } catch {
            if($_.Exception.Response.StatusCode.value__ -ne 404) {
                Write-Error "Error fetching file"
            }
            else {
                Write-Host "File not found" -ForegroundColor Yellow
            }
        }
    }

    $reposWithGitLfs | Out-File -FilePath "$Organization-lfs-repos.txt"
}

end {

}
