# Create a directory and cd into it
function mkcd() {
  local last
  last=$(eval "echo \$$#")
  if [ ! -n "$last" ]; then
    echo "Enter a directory name"
  elif [ -d "$last" ]; then
    echo "\`$last' already exists"
  else
    mkdir "$@" && cd "$last"
  fi
}

# Browse directories in ~/Dev with fzf
function dev() {
  local selected_dir
  selected_dir=$(find ~/Dev -maxdepth 1 -type d -not -path "*/\.*" | grep -v "^$HOME/Dev$" | fzf --height 40% --layout=reverse --border)
  if [ -n "$selected_dir" ]; then
    builtin cd "$selected_dir" && nvim .
  fi
}

# import psql db
function importDB() {
  if [ "$1" != "" ]; then
    local db_container=$(docker ps --format "table {{.Names}}" | grep -E '\bdatabase\b' | grep -v 'database_test' | head -1)
    if [ -z "$db_container" ]; then
      echo "No PostgreSQL 'database' container found"
      return 1
    fi
    gunzip -c "$1" | docker exec -i -e PGPASSWORD=password "$db_container" psql -U username database
  else
    echo "Missing path"
  fi
}

# import msql db
function importMDB() {
  if [ "$1" != "" ]; then
    local db_container=$(docker ps --format "table {{.Names}}" | grep -E '\bdatabase\b' | grep -v 'database_test' | head -1)
    if [ -z "$db_container" ]; then
      echo "No MySQL 'database' container found"
      return 1
    fi
    gunzip -c "$1" | docker exec -i "$db_container" mysql -u username -ppassword database
  else
    echo "Missing path"
  fi
}

# change dr and list them at same time
function cd() {
  if [ $# -eq 0 ]; then
    # No arguments - go to home directory
    builtin cd "$HOME" && lsd -lF
  elif [ -d "$1" ]; then
    # Valid directory - change to it
    builtin cd "$1" && lsd -lF
  else
    # Invalid directory - show error and stay in current directory
    echo "cd: no such file or directory: $1"
    return 1
  fi
}

# Function to display colored diffs to terminal, copy plain diffs to clipboard
function git_diff_all() {
  local exclude_tests=false
  local only_tests=false
  local target_branch="main"
  
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --exclude-tests|-et)
        exclude_tests=true
        shift
        ;;
      --only-tests|-ot)
        only_tests=true
        shift
        ;;
      *)
        target_branch="$1"
        shift
        ;;
    esac
  done

  local ALL_DIFFS

  # Check if the branch exists locally
  if ! git rev-parse --verify "${target_branch}" >/dev/null 2>&1; then
    # Try to find it as a remote branch
    local remote_branch=$(git branch -r | grep -E "/${target_branch}$" | head -1 | xargs)
    if [ -n "$remote_branch" ]; then
      echo "Branch '${target_branch}' not found locally. Using remote branch '${remote_branch}'"
      target_branch="$remote_branch"
    else
      # Try to fetch from origin and check again
      echo "Branch '${target_branch}' not found locally. Attempting to fetch from origin..."
      git fetch origin "${target_branch}":"${target_branch}" 2>/dev/null || {
        echo "Failed to fetch '${target_branch}' from origin."
        echo "Available branches:"
        git branch -a | grep -E "(${target_branch}|main|master)" | head -10
        return 1
      }
      echo "Successfully fetched '${target_branch}' from origin."
    fi
  fi

  # Build exclude/include patterns if needed
  local filter_args=""
  if [ "$exclude_tests" = true ]; then
    filter_args="-- . ':(exclude)*Test.php' ':(exclude)*.test.php' ':(exclude)*.test.ts' ':(exclude)*.test.js' ':(exclude)*.test.jsx' ':(exclude)*.test.tsx' ':(exclude)*.spec.js' ':(exclude)*.spec.ts' ':(exclude)*.spec.jsx' ':(exclude)*.spec.tsx' ':(exclude)tests/*' ':(exclude)Tests/*'"
  elif [ "$only_tests" = true ]; then
    filter_args="-- '*Test.php' '*.test.php' '*.test.ts' '*.test.js' '*.test.jsx' '*.test.tsx' '*.spec.js' '*.spec.ts' '*.spec.jsx' '*.spec.tsx' 'tests/*' 'Tests/*'"
  fi

  ALL_DIFFS=$( ( \
      eval "git -c color.diff=always --no-pager diff ${target_branch}... ${filter_args}" && \
      eval "git -c color.diff=always --no-pager diff ${filter_args}" && \
      eval "git -c color.diff=always --no-pager diff --cached ${filter_args}" \
  ) );

  echo "$ALL_DIFFS";

  echo "$ALL_DIFFS" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" | pbcopy;
}

# Function to display PR details and all comments in chronological order with colors to terminal, copy plain text to clipboard
function git_pr_comments() {
  local REPO_INFO PR_NUMBER PR_DETAILS REVIEW_COMMENTS GENERAL_COMMENTS PR_REVIEW_COMMENTS ALL_COMMENTS HEADER

  REPO_INFO=$(gh repo view --json owner,name --jq '.owner.login + "/" + .name')
  PR_NUMBER=$(gh pr view --json number --jq '.number')

  PR_DETAILS=$(gh pr view --json title,headRefName,baseRefName,body,author,state,url,number)

  HEADER=$(echo "$PR_DETAILS" | jq -r --arg pr_num "$PR_NUMBER" --arg repo "$REPO_INFO" '
      "=== PR #" + (.number | tostring) + ": " + .title + " ===\n" +
      "Repository: " + $repo + "\n" +
      "Branch: " + .headRefName + " → " + .baseRefName + "\n" +
      "Author: " + .author.login + "\n" +
      "Status: " + .state + "\n" +
      "URL: " + .url + "\n" +
      (if .body and .body != "" then "\nDescription:\n" + .body + "\n" else "\nNo description provided.\n" end) +
      "\n--- COMMENTS ---"
  ')

  # Get review comments (on specific lines) with timestamps
  REVIEW_COMMENTS=$(
      gh api repos/$REPO_INFO/pulls/$PR_NUMBER/comments \
      --jq '.[] | [.created_at, "REVIEW", .path, (.line | tostring), .user.login, .body] | @tsv'
  )

  # Get general PR comments (overall conversation) with timestamps
  GENERAL_COMMENTS=$(
      gh api repos/$REPO_INFO/issues/$PR_NUMBER/comments \
      --jq '.[] | [.created_at, "GENERAL", "N/A", "N/A", .user.login, .body] | @tsv'
  )

  # Get PR review comments (overall review submissions) with timestamps
  PR_REVIEW_COMMENTS=$(
      gh api repos/$REPO_INFO/pulls/$PR_NUMBER/reviews \
      --jq '.[] | select(.body != null and .body != "") | [.submitted_at, "PR_REVIEW", "N/A", "N/A", .user.login, .body] | @tsv'
  )

  # Combine, sort by timestamp, and format all comments
  ALL_COMMENTS=$(
      {
          echo "$REVIEW_COMMENTS"
          echo "$GENERAL_COMMENTS"
          echo "$PR_REVIEW_COMMENTS"
      } | \
      sort -k1,1 | \
      cut -f2- | \
      column -t -s$'\t' | \
      awk '{
          if ($1 == "REVIEW") {
              print "\033[1;35m[REVIEW]\033[0m", "\033[1;34m" $2 "\033[0m", "\033[1;33m" $3 "\033[0m", "\033[1;32m" $4 "\033[0m", substr($0, index($0,$5))
          } else if ($1 == "PR_REVIEW") {
              print "\033[1;31m[PR_REVIEW]\033[0m", "\033[1;32m" $4 "\033[0m", substr($0, index($0,$5))
          } else {
              print "\033[1;36m[GENERAL]\033[0m", "\033[1;32m" $4 "\033[0m", substr($0, index($0,$5))
          }
      }'
  )

  FULL_OUTPUT=$(printf "%s\n\n%s" "$HEADER" "$ALL_COMMENTS")

  echo "$FULL_OUTPUT"

  # Strip colors and copy plain text to clipboard
  echo "$FULL_OUTPUT" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" | pbcopy
}

function gh_login() {
  gh auth login --web --git-protocol https
}
