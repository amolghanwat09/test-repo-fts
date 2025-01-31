#!/bin/bash

# Set your GitHub repository details
REPO_OWNER="amolghanwat09"
REPO_NAME="test-repo-fts"

# Set your Personal Access Token (PAT)
GITHUB_TOKEN=""

# Trigger the workflow using the repository_dispatch event
curl -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/dispatches \
  -d '{"event_type": "manual-trigger", "client_payload": {}}'

echo "Workflow triggered manually!"

response=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/dispatches \
  -d '{"event_type": "manual-trigger", "client_payload": {}}')

echo "API Response: $response"

