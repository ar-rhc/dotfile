#!/bin/bash
# GitHub Setup Script
# After creating a repository on GitHub, run this script with your repo URL

if [ -z "$1" ]; then
    echo "Usage: ./github_setup.sh <github-repo-url>"
    echo "Example: ./github_setup.sh https://github.com/username/dotfiles.git"
    exit 1
fi

REPO_URL="$1"

# Add remote
git remote add origin "$REPO_URL"

# Push to GitHub
git push -u origin main

echo "✅ Repository pushed to GitHub!"
echo "View at: $REPO_URL"

