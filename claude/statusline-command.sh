#!/usr/bin/env bash
# Claude Code status line: model, directory, git branch, context usage, rate limits
input=$(cat)

# Empty values become "-" so that tab splitting keeps the columns aligned
IFS=$'\t' read -r model dir ctx five week < <(
  echo "$input" | jq -r '[
    (.model.display_name // "-"),
    (.workspace.current_dir // .cwd // "-"),
    (.context_window | if .current_usage != null then
      (.current_usage | (.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0))
      else (.total_input_tokens // "-") end),
    (.rate_limits.five_hour.used_percentage // "-"),
    (.rate_limits.seven_day.used_percentage // "-")
  ] | map(tostring) | join("\t")'
)

# Directory: "~" for home, otherwise the basename
short=""
if [ "$dir" != "-" ]; then
  if [ "$dir" = "$HOME" ]; then short="~"; else short=$(basename "$dir"); fi
fi

# Branch, or the short commit hash on a detached HEAD
branch=""
if [ "$dir" != "-" ] && [ -d "$dir" ]; then
  branch=$(git --no-optional-locks -C "$dir" symbolic-ref --short -q HEAD 2>/dev/null \
    || git --no-optional-locks -C "$dir" rev-parse --short HEAD 2>/dev/null)
fi

cyan=$'\033[36m'; green=$'\033[32m'; yellow=$'\033[33m'; magenta=$'\033[35m'; dim=$'\033[2m'; reset=$'\033[0m'
sep=" ${dim}|${reset} "

out="${cyan}${model}${reset}"
[ -n "$short" ] && out="$out$sep${green}${short}${reset}"
[ -n "$branch" ] && out="$out$sep${magenta}${branch}${reset}"
[ "$ctx" != "-" ] && out="$out$sep${yellow}ctx $(printf '%.0f' "$ctx") tk${reset}"
[ "$five" != "-" ] && out="$out${sep}5h $(printf '%.0f' "$five")%"
[ "$week" != "-" ] && out="$out${sep}7d $(printf '%.0f' "$week")%"
printf '%s\n' "$out"
