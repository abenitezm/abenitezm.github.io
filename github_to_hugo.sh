#!/bin/bash

GITHUB_USER="abenitezm"
HUGO_CONTENT_DIR="content/projects/posts"

echo "Waiting for a response from the GitHub API ..."
repos=$(curl -s "https://api.github.com/users/$GITHUB_USER/repos")
echo "Accessing $GITHUB_USER's repos ..."

echo "$repos" | jq -c '.[]' | while read -r repo; do
	name=$(echo "$repo" | jq -r '.name')
	description=$(echo "$repo" | jq -r '.description // "No description."')
	created_at=$(echo "$repo" | jq -r '.created_at')
	html_url=$(echo "$repo" | jq -r '.html_url')
	language=$(echo "$repo" | jq -r '.language // "Not specified."')
	is_fork=$(echo "$repo" | jq -r '.fork')

	if [ "$is_fork" = "true" ]; then
		echo "Skipping fork $name ..."
		continue
	fi

	filename="${name,,}"
	filename="${filename// /-}"
	filepath="$HUGO_CONTENT_DIR/$filename.md"
	
	echo "Building $name's markdown file"
	cat > "$filepath" <<EOF
---
title: "$name"
date: "$created_at"
tags: ["${language,,}"]
draft: false
---

Visit the [GitHub repo]($html_url).

## Description

$description
EOF

	echo "File created at $filepath"
done
