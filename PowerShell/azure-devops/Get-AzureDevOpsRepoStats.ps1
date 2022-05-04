
# TODO: Algin to best practices
# https://github.com/PoshCode/PowerShellPracticeAndStyle
[CmdletBinding()]
param
(
    [Parameter(Mandatory = $true)]
    [string]
    $Organization,

    [string[]]
    $Projects,

    [Parameter(Mandatory = $true)]
    [string]
    $PersonalAccessToken
)

begin {
    $rootApiUrl = "https://dev.azure.com/$Organization"

    $getAllRepos = $Projects.Count -eq 0

    if($null -eq $Projects || $Projects.Count -eq 0) {
        $Projects = New-Object System.Collections.ArrayList
    }

    $credentials = ":$PersonalAccessToken"
    $encodedCredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($credentials))
    $authorizationHeader = @{ Authorization = "Basic $encodedCredentials" }
}

process {
    if ($getAllRepos -eq $true) {
        $projectsApiUrl = "$rootApiUrl/_apis/projects?api-version=7.1-preview.1"

        $azureDevOpsProjectsResponse = Invoke-RestMethod -Uri $projectsApiUrl -Method Get -Headers $authorizationHeader

        foreach ($project in $azureDevOpsProjectsResponse.value) {
            $Projects += $project.name
        }
    }

    $repoStats = New-Object System.Collections.ArrayList

    foreach ($project in $Projects) {
        Write-Host "Fetching build definitions for the $project project"
        $buildDefinitionsApiUrl = "$rootApiUrl/$project/_apis/build/definitions?includeAllProperties=true&api-version=7.1-preview.7"
        
        $buildDefinitionsResponse = Invoke-RestMethod -Uri $buildDefinitionsApiUrl -Method Get -Headers $authorizationHeader

        Write-Host "Fetching repositories for the $project project"
        $reposApiUrl = "$rootApiUrl/$project/_apis/git/repositories?api-version=7.1-preview.1"

        $azureDevOpsReposResponse = Invoke-RestMethod -Uri $reposApiUrl -Method Get -Headers $authorizationHeader

        foreach ($repo in $azureDevOpsReposResponse.value) {
            if ($repo.size -eq 0) {
                Write-Host "Skipping empty repository $($repo.name) in the $project project"
                continue
            }

            $lastCommitDate = $null
            $lastCommitBranch = $null

            $repoStatsApiUrl = "$rootApiUrl/$project/_apis/git/repositories/$($repo.id)/stats/branches?api-version=7.1-preview.1"

            Write-Host "Fetching stats for the repository $($repo.name) in the $project project"
            $azureDevOpsRepoStatsResponse = Invoke-RestMethod -Uri $repoStatsApiUrl -Method Get -Headers $authorizationHeader

            foreach ($stat in $azureDevOpsRepoStatsResponse.value) {
                if($null -eq $lastCommitDate || $lastCommitDate -le $stat.commit.author.date) {
                    $lastCommitDate = $stat.commit.author.date
                    $lastCommitBranch = $stat.name
                }
            }

            $builds = New-Object System.Collections.ArrayList

            $buildDefinitions = $buildDefinitionsResponse.value | Where-Object { $_.repository.name -eq $repo.name }

            foreach ($buildDefinition in $buildDefinitions) {
                $builds.Add(@{
                    name = $buildDefinition.name
                    url = $buildDefinition._links.web.href
                }) | Out-Null
            }

            $repoStats.Add(@{
                name = $repo.name
                lastCommitBranch = $lastCommitBranch
                lastCommitDate = $lastCommitDate
                builds = $builds
            }) | Out-Null
        }
    }

    ConvertTo-Json $repoStats -Depth 10 | Out-File -FilePath "$Organization-repo-stats.json"
}

end {

}