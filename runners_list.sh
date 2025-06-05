#!/bin/bash
organization="developmententity"
TOKEN=$(cat ~/GHTokenOrg.txt)

curl -sL -H "Authorization: Bearer ${TOKEN}" \
         -H "Accept: application/vnd.github+json" \
         "https://api.github.com/orgs/${organization}/actions/runners" | jq -r '.'
