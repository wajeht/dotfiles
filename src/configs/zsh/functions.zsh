# Copy stdin to the system clipboard across macOS / Wayland / X11.
_clip() {
  if command -v pbcopy >/dev/null 2>&1; then pbcopy
  elif command -v wl-copy >/dev/null 2>&1; then wl-copy
  elif command -v xclip >/dev/null 2>&1; then xclip -selection clipboard
  elif command -v xsel >/dev/null 2>&1; then xsel -b
  else cat >/dev/null; fi # no clipboard tool: discard rather than error
}

function pr() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "Not in a git repository"
    return 1
  }

  git rev-parse --abbrev-ref @{u} >/dev/null 2>&1 \
    || git push -u origin HEAD \
    || return 1

  gh pr create --fill
}

# Create a directory and cd into it
function mkcd() {
  local last="${@: -1}"
  if [ -z "$last" ]; then
    echo "Enter a directory name"
  elif [ -d "$last" ]; then
    echo "\`$last' already exists"
  else
    mkdir "$@" && cd "$last"
  fi
}

# Browse project directories with fzf (upper/lowercase both supported;
# duplicates deduped by inode since macOS filesystems are case-insensitive)
DEV_DIRS=(~/Dev ~/Work ~/dev ~/work)

# Immediate project subdirs of the given roots (hidden dirs excluded). -mindepth 1
# drops the roots themselves, so no post-filter grep is needed.
_dev_projects() { find "$@" -mindepth 1 -maxdepth 1 -type d -not -path '*/.*'; }

function dev() {
  local search_dirs=() d e dup
  for d in "${DEV_DIRS[@]}"; do
    [ -d "$d" ] || continue
    dup=0
    for e in "${search_dirs[@]}"; do [[ "$d" -ef "$e" ]] && { dup=1; break; }; done
    (( dup )) || search_dirs+=("$d")
  done
  if (( ${#search_dirs} == 0 )); then
    echo "No project directories found"
    return 1
  fi

  # Inside the tmux popup the popup draws the border and fzf fills it;
  # inline (outside tmux) fzf draws its own.
  local fzf_opts=(--height 40% --layout=reverse --border)
  [ -n "$DEV_POPUP" ] && fzf_opts=(--layout=reverse)

  # No tmux: just pick a dir and open nvim in place (no sessions to manage).
  if ! command -v tmux > /dev/null 2>&1; then
    local dir="${1:-$(_dev_projects "${search_dirs[@]}" | fzf "${fzf_opts[@]}")}"
    [ -n "$dir" ] || return 0
    [ -d "$dir" ] || { echo "Not a directory: $dir"; return 1; }
    echo "tmux not found; opening without a session"
    builtin cd "$dir" && nvim .
    return
  fi

  local mode name dir query result target rc
  if [ -n "$1" ]; then
    mode=project; dir="$1"
  else
    # One fuzzy prompt over: existing sessions (bare names -> switch to) and
    # project dirs (absolute paths -> create/attach). A project that already has
    # a session shows once, as the session — its folder is dropped (matched by the
    # @dev_path we stamp on each project session). A "+ create session" line is
    # added as you type (below) for making a brand-new named session.
    local -a cand dirs snames; local dpath sname wins owner s w
    typeset -A have_dir win_of
    local active; active=$(tmux display-message -p '#{session_name}' 2>/dev/null)
    # Session rows colored from the vscode palette: green = the session you're
    # attached to, blue = other sessions; window names trail in dim gray.
    local G=$'\e[38;2;106;153;85m' B=$'\e[38;2;86;156;214m' DIM=$'\e[38;2;90;90;90m' RST=$'\e[0m'
    # One tmux call for all windows (grouped in-shell), one for sessions+@dev_path —
    # not two spawns per session. Join windows with ' | ' in zsh (no paste/sed); any
    # '/' in a window name is flattened so it can't break the --nth -1 match below.
    while IFS=$'\t' read -r s w; do
      [[ -n $s ]] || continue
      w="${w//\// }"
      win_of[$s]+="${win_of[$s]:+ | }$w"
    done < <(tmux list-windows -a -F '#{session_name}'$'\t''#{window_name}' 2>/dev/null)
    while IFS=$'\t' read -r sname owner; do
      [[ -n $sname ]] || continue
      snames+=("$sname")
      [[ -n $owner ]] && have_dir[$owner]=1
      wins="${win_of[$sname]}"
      local disp="${sname//\//_}"   # flatten '/' so --nth -1 doesn't split the row
      if [[ "$sname" == "$active" ]]; then
        cand+=("${G}${disp}${RST}  ${DIM}${wins}${RST}")
      else
        cand+=("${B}${disp}${RST}  ${DIM}${wins}${RST}")
      fi
    done < <(tmux list-sessions -F '#{session_name}'$'\t''#{@dev_path}' 2>/dev/null)
    dirs=(${(f)"$(_dev_projects "${search_dirs[@]}" | sort)"})
    for dpath in $dirs; do
      [[ -n $dpath ]] && [[ -z ${have_dir[${dpath:A}]} ]] && cand+=("$dpath")
    done
    # As you type a NEW name (not an existing session or project basename), a green
    # `create session "<query>"` line is prepended and pinned to the very top. To
    # keep it reliably on top we turn fzf's relevance sort OFF (--no-sort below),
    # so the rest shows in a fixed order: sessions first, then folders A-Z.
    local tmpf namesf
    tmpf=$(mktemp); namesf=$(mktemp)
    print -rl -- "${cand[@]}" > "$tmpf"
    # existing names (plain session names + folder basenames) for create-line suppression
    { print -rl -- "${snames[@]}"; for dpath in $dirs; do print -r -- "${dpath:t}"; done } > "$namesf"
    local reload='q="$FZF_QUERY"; [ -n "$q" ] && ! grep -qxF -- "$q" '${(q)namesf}' && printf "\033[38;2;106;153;85mcreate session \"%s\"\033[0m\n" "$q"; cat '${(q)tmpf}
    # --delimiter/--nth: match only the last path component (project name), not the
    # whole path — otherwise "dotf" matches via the shared "/Users/jaw/Dev/" prefix.
    result=$(fzf --ansi --no-sort --print-query --delimiter / --nth -1 --bind "change:reload($reload)" "${fzf_opts[@]}" < "$tmpf")
    rc=$?
    rm -f "$tmpf" "$namesf"
    [ "$rc" -ne 0 ] && [ "$rc" -ne 1 ] && return 0   # aborted (Esc/^C)
    # Output lines: 1 = query (--print-query), 2 = selected item
    query="${result%%$'\n'*}"
    if [[ "$result" == *$'\n'* ]]; then target="${result#*$'\n'}"; else target=""; fi
    if [[ "$target" == 'create session "'* ]]; then
      [ -n "$query" ] || return 0
      mode=new; name="${query//[^A-Za-z0-9_-]/_}"   # sanitize: tmux forbids dots/colons
    elif [[ "$target" == /* ]]; then
      mode=project; dir="$target"
    elif [ -n "$target" ]; then
      mode=session; name="${target%%[[:space:]]*}"   # session row is "name  <windows>"
      # exact-recover names that contain spaces (row starts with "<name>  ")
      for sname in "${snames[@]}"; do [[ "$target" == "${sname//\//_}  "* ]] && { name="$sname"; break; }; done
    elif [ -n "$query" ]; then
      mode=new; name="${query//[^A-Za-z0-9_-]/_}"
    else
      return 0
    fi
  fi

  if [ "$mode" = project ]; then
    [ -d "$dir" ] || { echo "Not a directory: $dir"; return 1; }
    dir="${dir:A}"   # absolutize so a relative arg names/opens the right dir
    # Session name = sanitized project-dir basename. Disambiguate with the parent
    # dir ONLY when a session with that EXACT name already exists AND belongs to a
    # different dir (or is an ad-hoc/external session with no @dev_path) — so we
    # never hijack an unrelated same-named session, and names stay clean otherwise.
    # (Checking exact existence first also avoids show-options' prefix-matching.)
    # Prefer the dir basename; if that exact name is taken by a DIFFERENT project
    # (or an unrelated ad-hoc session), prefix the parent dir, then append "_"
    # until the name is free or is this project's — so we never hijack an
    # unrelated session at the base OR the disambiguated name.
    local base="${${dir:t}//[^A-Za-z0-9_-]/_}" owner
    name="$base"
    while tmux has-session -t "=$name" 2> /dev/null; do
      owner=$(tmux show-options -t "$name" -qv @dev_path 2>/dev/null)
      [ "$owner" = "$dir" ] && break
      if [ "$name" = "$base" ]; then
        name="${${dir:h:t}//[^A-Za-z0-9_-]/_}_${base}"
      else
        name="${name}_"
      fi
    done
    if ! tmux has-session -t "=$name" 2> /dev/null; then
      tmux new-session -ds "$name" -c "$dir" -n nvim nvim .
      tmux new-window -t "$name" -c "$dir" -n shell
      tmux select-window -t "$name:nvim"
      tmux set-option -t "$name" @dev_path "$dir"   # stamp for dedup + clash check
    fi
  elif [ "$mode" = new ]; then
    # Ad-hoc session from the typed name, rooted at $HOME.
    tmux has-session -t "=$name" 2> /dev/null || tmux new-session -ds "$name" -c "$HOME"
  fi
  # mode=session: it already exists; just attach/switch below.

  if [ -n "$TMUX" ]; then
    tmux switch-client -t "=$name"
  else
    tmux attach -t "=$name"
  fi
}

function workterm() {
  local ghostty_bin="/Applications/Ghostty.app/Contents/MacOS/ghostty"
  if command -v ghostty >/dev/null 2>&1; then
    ghostty_bin="$(command -v ghostty)"
  elif [[ ! -x "$ghostty_bin" ]]; then
    echo "Ghostty executable not found"
    return 1
  fi

  local -a work_cmd
  if (( $# )); then
    work_cmd=("$@")
  else
    work_cmd=(ssh work)
  fi

  local -a ghostty_args=(
    --background="#2a1600"
    --foreground="#ffe8cc"
    --cursor-color="#ff9f1c"
    --selection-background="#7a3f00"
    --selection-foreground="#fff4e6"
  )

  if [[ "$(uname)" == "Darwin" ]]; then
    ghostty_args+=(--window-theme=dark --macos-titlebar-style=transparent)
  else
    ghostty_args+=(
      --gtk-single-instance=false
      --window-decoration=auto
      --window-theme=ghostty
      --window-titlebar-background="#e95420"
      --window-titlebar-foreground="#fff4e6"
      --gtk-titlebar=true
      --gtk-titlebar-style=native
    )
  fi

  "$ghostty_bin" "${ghostty_args[@]}" -e "${work_cmd[@]}"
}

# import psql db
function importDB() {
  if [ "$1" != "" ]; then
    local db_container=$(docker ps --format "table {{.Names}}" | grep -E '\bdatabase\b' | grep -v 'database_test' | head -1)
    if [ -z "$db_container" ]; then
      echo "No PostgreSQL 'database' container found"
      return 1
    fi
    gunzip -c "$1" | docker exec -i -e PGPASSWORD="${PGPASSWORD:-password}" "$db_container" psql -U "${PGUSER:-username}" "${PGDATABASE:-database}"
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
    gunzip -c "$1" | docker exec -i "$db_container" mysql -u "${MYSQL_USER:-username}" -p"${MYSQL_PWD:-password}" "${MYSQL_DATABASE:-database}"
  else
    echo "Missing path"
  fi
}

# List directory contents on every change — via a chpwd hook so it also covers
# AUTO_CD, pushd/popd, and cd flags (unlike overriding the cd builtin). No-ops
# where lsd isn't installed.
chpwd() {
  command -v lsd >/dev/null 2>&1 && lsd -lF
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
  local -a filter_args=()
  if [ "$exclude_tests" = true ]; then
    filter_args=(
      --
      .
      ':(exclude)*Test.php'
      ':(exclude)*.test.php'
      ':(exclude)*.test.ts'
      ':(exclude)*.test.js'
      ':(exclude)*.test.jsx'
      ':(exclude)*.test.tsx'
      ':(exclude)*.spec.js'
      ':(exclude)*.spec.ts'
      ':(exclude)*.spec.jsx'
      ':(exclude)*.spec.tsx'
      ':(exclude)tests/*'
      ':(exclude)Tests/*'
    )
  elif [ "$only_tests" = true ]; then
    filter_args=(
      --
      '*Test.php'
      '*.test.php'
      '*.test.ts'
      '*.test.js'
      '*.test.jsx'
      '*.test.tsx'
      '*.spec.js'
      '*.spec.ts'
      '*.spec.jsx'
      '*.spec.tsx'
      'tests/*'
      'Tests/*'
    )
  fi

  ALL_DIFFS=$(
    (
      git -c color.diff=always --no-pager diff "${target_branch}..." "${filter_args[@]}" &&
      git -c color.diff=always --no-pager diff "${filter_args[@]}" &&
      git -c color.diff=always --no-pager diff --cached "${filter_args[@]}"
    )
  )

  echo "$ALL_DIFFS";

  echo "$ALL_DIFFS" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" | _clip;
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
  echo "$FULL_OUTPUT" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" | _clip
}

function gh_login() {
  gh auth login --web --git-protocol https
}

# Kill process running on specified port
function kill-port() {
  if [ -z "$1" ]; then
    echo "Usage: kill-port <port_number>"
    return 1
  fi

  local pid=$(lsof -ti:$1)

  if [ -z "$pid" ]; then
    echo "No process found running on port $1"
    return 1
  fi

  echo "Killing process $pid on port $1"
  kill -9 $pid
}

sopse() {
  sops --input-type dotenv --output-type dotenv \
    -e --age "$(age-keygen -y "${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}")" \
    "$1" > "$1.sops"
}

sopsd() {
  # SOPS_AGE_KEY_FILE is exported from env.zsh; sops reads it for decryption.
  sops --input-type dotenv --output-type dotenv -d "$1"
}

# ======================
# Custom Keybindings
# ======================

# Widget function to run dev() and refresh the command line
function dev-widget() {
  # Clear line and execute via command line for proper terminal takeover
  zle kill-whole-line
  BUFFER="dev"
  zle accept-line
}

# Create a zsh widget from the function
zle -N dev-widget

# Set up key bindings after zsh-vi-mode initializes
# zsh-vi-mode overrides many bindings, so we need to set ours after it loads
function zvm_after_init() {
  # Bind Ctrl+F (\x06) to the sessionizer, matching tmux's `bind -n C-f`.
  # (cmd+f is routed to nvim's M-f via Ghostty, so Ctrl+F is the trigger here.)
  zvm_bindkey viins '\x06' dev-widget
  # Also bind in normal/command mode for convenience
  zvm_bindkey vicmd '\x06' dev-widget
}

# Fallback: If zsh-vi-mode is not loaded, bind directly
# This will be overridden by zvm_after_init if the plugin loads later
bindkey '\x06' dev-widget  # Ctrl+F for dev widget
