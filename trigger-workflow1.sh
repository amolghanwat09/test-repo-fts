#!/bin/bash

# Set your GitHub repository details
REPO_OWNER="amolghanwat09"
REPO_NAME="test-repo-fts"
WORKFLOW_ID="test-workflow.yml"

# Set your Personal Access Token (PAT)
GITHUB_TOKEN="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"

# Trigger the workflow using the repository_dispatch event
response=$(curl -s -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/dispatches \
  -d '{"event_type": "manual-trigger", "client_payload": {}}')

# Get the latest workflow run ID
latest_run=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/workflows/$WORKFLOW_ID/runs?per_page=1" \
  | jq -r '.workflow_runs[0].id')

# Check the status of the latest workflow run
status=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/runs/$latest_run" \
  | jq -r '.conclusion')

echo "Workflow Status: $status"

if [[ "$status" == "success" ]]; then
  echo "Workflow completed successfully!"
else
  echo "Workflow failed or encountered issues. Please check the Actions tab for more details."
fi


