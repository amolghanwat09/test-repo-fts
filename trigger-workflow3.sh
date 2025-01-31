#!/bin/bash

# Set your GitHub repository details
REPO_OWNER="amolghanwat09"
REPO_NAME="test-repo-fts"
WORKFLOW_ID="140925492"

# Set your Personal Access Token (PAT)
GITHUB_TOKEN=""

# Trigger the workflow using the repository_dispatch event
response=$(curl -s -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/dispatches \
  -d '{"event_type": "manual-trigger", "client_payload": {}}')

# Get the latest workflow run ID
latest_run=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/workflows/$WORKFLOW_ID/runs?per_page=1")

# Extract the workflow run ID using bash
run_id=$(echo "$latest_run" | grep -o '"id":[0-9]*' | cut -d: -f2)

# Check the status of the latest workflow run
status=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/runs/$run_id")

# Print the full status details
echo "Workflow Run Details:"
echo "$status"

# Extract the conclusion and logs_url using bash
conclusion=$(echo "$status" | grep -o '"conclusion":"[^"]*' | cut -d: -f2 | tr -d '"')
jobs_url=$(echo "$status" | grep -o '"jobs_url":"[^"]*' | cut -d: -f2 | tr -d '"')

echo "Workflow Status: $conclusion"

if [[ "$conclusion" == "success" ]]; then
  echo "Workflow completed successfully!"
else
  echo "Workflow failed or encountered issues. Fetching job details..."

  # Fetch the job details of the latest workflow run
  if [[ -n "$jobs_url" ]]; then
    jobs=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$jobs_url")
    echo "Job Details:"
    echo "$jobs"
  else
    echo "Failed to retrieve job details. No jobs URL found."
  fi
fi

