#!/bin/bash

# Check if title is provided
if [ -z "$1" ]; then
    echo "Usage: $0 \"PR Title\""
    echo "Example: $0 \"Add new feature for user management\""
    exit 1
fi

PR_TITLE="$1"
SOURCE_BRANCH=$(git branch --show-current)
TARGET_BRANCH="main"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Check if current branch is not main
if [ "$SOURCE_BRANCH" = "$TARGET_BRANCH" ]; then
    echo "Error: Cannot create PR from main to main"
    exit 1
fi

echo "Creating PR:"
echo "  Title: $PR_TITLE"
echo "  Source: $SOURCE_BRANCH"
echo "  Target: $TARGET_BRANCH"
echo

# Create the PR and capture the output
PR_OUTPUT=$(az repos pr create \
    --title "[wip] $PR_TITLE" \
    --source-branch "$SOURCE_BRANCH" \
    --target-branch "$TARGET_BRANCH" \
    --draft \
    --description "### What?
$PR_TITLE

### Why?
Help the reviewer see the bigger picture. Note what business or engineering goal this change achieves, for instance, it may be the progress toward a goal.

### How?
Inform the reviewer of the new major constructs, new dependencies, new processing patterns, etc. Draw attention to the significant design decisions.

### Testing?
Enter the steps you performed to know it works locally or in the DEV environment (if branch was deployed before merge).

### Screenshots (optional)
Screenshots are especially helpful for UI-related changes. They can be helpful for other changes. Think about providing reviewers images from your local development process that would be helpful in understanding or seeing that the change works locally.

### Anything Else? (optional)
You may want to delve into possible architecture changes or technical debt here. Call out challenges, optimizations, etc.
" 2>&1)

# Check if PR creation was successful and extract the URL
if [ $? -eq 0 ]; then
    echo "✅ PR created successfully!"
    
    # Debug: Show what we captured (remove this after debugging)
    # echo "DEBUG: Azure CLI output:"
    # echo "$PR_OUTPUT"
    # echo "---"
    
    # Try multiple approaches to extract the URL
    # Method 1: Look for "url" field
    PR_URL=$(echo "$PR_OUTPUT" | jq -r '.url // empty' 2>/dev/null)
    
    # Method 2: If jq fails or no URL, try grep approach
    if [ -z "$PR_URL" ]; then
        PR_URL=$(echo "$PR_OUTPUT" | grep -o '"url":"[^"]*"' | sed 's/"url":"\([^"]*\)"/\1/')
    fi
    
    # Method 3: Look for webUrl field (alternative field name)
    if [ -z "$PR_URL" ]; then
        PR_URL=$(echo "$PR_OUTPUT" | jq -r '.webUrl // empty' 2>/dev/null)
    fi
    
    if [ -n "$PR_URL" ]; then
        echo "🔗 PR Link: $PR_URL"
    else
        # Fallback: try to extract PR ID and construct URL
        PR_ID=$(echo "$PR_OUTPUT" | jq -r '.pullRequestId // empty' 2>/dev/null)
        if [ -z "$PR_ID" ]; then
            PR_ID=$(echo "$PR_OUTPUT" | grep -o '"pullRequestId":[0-9]*' | sed 's/"pullRequestId":\([0-9]*\)/\1/')
        fi
        
        if [ -n "$PR_ID" ]; then
            # Get the organization and project from git remote
            REMOTE_URL=$(git config --get remote.origin.url)
            if [[ $REMOTE_URL =~ dev\.azure\.com/([^/]+)/([^/]+) ]]; then
                ORG="${BASH_REMATCH[1]}"
                PROJECT="${BASH_REMATCH[2]}"
                REPO=$(basename -s .git "$REMOTE_URL")
                echo "🔗 PR Link: https://dev.azure.com/$ORG/$PROJECT/_git/$REPO/pullrequest/$PR_ID"
            else
                echo "⚠️  PR created but couldn't extract link. PR ID: $PR_ID"
            fi
        else
            echo "⚠️  PR created but couldn't extract link or ID"
        fi
    fi
else
    echo "❌ Failed to create PR:"
    echo "$PR_OUTPUT"
    exit 1
fi