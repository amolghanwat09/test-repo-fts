#!/bin/bash

# Set your GitHub repository details
REPO_OWNER="amolghanwat09"
REPO_NAME="test-repo-fts"
WORKFLOW_ID="140925492"

# Set your Personal Access Token (PAT) from environment variable
GITHUB_TOKEN="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"

# Trigger the workflow using the repository_dispatch event
response=$(curl -s -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/dispatches \
  -d '{"event_type": "manual-trigger", "client_payload": {}}')

if [[ $? -ne 0 ]]; then
  echo "Failed to trigger the workflow."
  exit 1
fi

# Get the latest workflow runs
latest_runs=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/runs?per_page=5")

if [[ $? -ne 0 ]]; then
  echo "Failed to fetch the latest workflow runs."
  exit 1
fi

# Extract the most recent workflow run ID using jq
run_id=$(echo "$latest_runs" | jq -r '.workflow_runs | sort_by(.created_at) | last(.[]).id')

# Check the status of the latest workflow run
status=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/runs/$run_id")

if [[ $? -ne 0 ]]; then
  echo "Failed to fetch the workflow run status."
  exit 1
fi

# Print the full status details for debugging
echo "Workflow Run Details:"
echo "$status" | jq

# Extract the conclusion and jobs_url using jq
conclusion=$(echo "$status" | jq -r '.conclusion')
jobs_url=$(echo "$status" | jq -r '.jobs_url')

echo "Workflow Status: $conclusion"

if [[ "$conclusion" == "success" ]]; then
  echo "Workflow completed successfully!"
else
  echo "Workflow failed or encountered issues. Fetching job details..."

  # Fetch the job details of the latest workflow run
  if [[ -n "$jobs_url" ]]; then
    jobs=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$jobs_url")
    if [[ $? -ne 0 ]]; then
      echo "Failed to fetch job details."
      exit 1
    fi

    latest_job=$(echo "$jobs" | jq -r '.jobs | sort_by(.started_at) | last(.[])')

    if [[ "$latest_job" != "null" ]]; then
      echo "Latest Job Details:"
      echo "$latest_job" | jq

      # Fetch the logs URL
      logs_url=$(echo "$latest_job" | jq -r '.logs_url')

      if [[ -n "$logs_url" ]]; then
        # Fetch and print the logs
        logs=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$logs_url")
        if [[ $? -ne 0 ]]; then
          echo "Failed to fetch logs."
          exit 1
        fi

        echo "Workflow Logs:"
        echo "$logs"
      else
        echo "No logs URL found."
      fi
    else
      echo "No job details found. There might be an issue with the workflow file."
    fi
  else
    echo "Failed to retrieve job details. No jobs URL found."
  fi
fi

