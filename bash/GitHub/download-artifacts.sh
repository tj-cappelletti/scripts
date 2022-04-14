#!/bin/bash
artifactsUrl=$1
# Must have trailing slash
# Directory must exist ahead of time
outputPath=$2

artifacts=$(curl -s -X GET \
    -H "Authorization: token $GH_TOKEN"  \
    -H "Accept: application/vnd.github.v3+json" \
    $artifactsUrl | jq '.artifacts')

for index in $(jq 'keys | .[]' <<< "$artifacts"); do
    artifact=$(jq -r ".[$index]" <<< "$artifacts")
    
    downloadUrl=$(jq -r ".archive_download_url" <<< "$artifact")
    name=$(jq -r ".name" <<< "$artifact")
    fileName="${outputPath}${name}.zip"

    echo "Downloading artifact '${name}'..."
    curl -sL -H "Authorization: token $GH_TOKEN" --output $fileName $downloadUrl
done