#!/usr/bin/env bash
# Analyze oh-my-zsh alias usage from zsh history.
# Extracts first word from each history entry, cross-references with
# all aliases defined by enabled oh-my-zsh plugins.
#
# Usage: ./analyze-omz-usage.sh [~/.zsh_history] [~/.oh-my-zsh]

set -euo pipefail
export LC_ALL=C

HISTFILE="${1:-$HOME/.zsh_history}"
OMZ_DIR="${2:-$HOME/.oh-my-zsh}"

if [[ ! -f "$HISTFILE" ]]; then
    echo "History file not found: $HISTFILE" >&2
    exit 1
fi

# Read enabled plugins from zshrc
ZSHRC="$HOME/.zshrc"
if [[ -f "$ZSHRC" ]]; then
    PLUGINS=$(sed -n 's/^plugins=(\(.*\))/\1/p' "$ZSHRC" 2>/dev/null || true)
fi
if [[ -z "${PLUGINS:-}" ]]; then
    echo "Could not detect plugins from $ZSHRC, scanning all plugin dirs" >&2
    PLUGINS=$(ls "$OMZ_DIR/plugins/" 2>/dev/null | tr '\n' ' ')
fi

echo "Enabled plugins: $PLUGINS"
echo ""

# Collect all alias names from enabled plugins
omz_aliases=$(mktemp)
for plugin in $PLUGINS; do
    plugin_file="$OMZ_DIR/plugins/$plugin/$plugin.plugin.zsh"
    if [[ -f "$plugin_file" ]]; then
        grep -E '^\s*alias ' "$plugin_file" 2>/dev/null | \
            sed "s/.*alias \([^=]*\)=.*/\1/" | tr -d "'" | \
            while read -r a; do echo "$plugin $a"; done
    fi
done > "$omz_aliases"

total_aliases=$(wc -l < "$omz_aliases" | tr -d ' ')
echo "Total oh-my-zsh aliases across enabled plugins: $total_aliases"
echo ""

# Extract first word from each history line
cmd_counts=$(mktemp)
sed -n 's/^: [0-9]*:[0-9]*;//p' "$HISTFILE" 2>/dev/null | \
    sed 's/^[[:space:]]*//' | \
    awk '{print $1}' | \
    sort | uniq -c | sort -rn > "$cmd_counts"

total_history=$(awk '{s+=$1} END {print s}' "$cmd_counts")
echo "Total history entries parsed: $total_history"
echo ""

# Cross-reference
echo "=== oh-my-zsh aliases you USE (by frequency) ==="
echo ""
printf "%-8s %-6s %-20s %s\n" "COUNT" "PLUGIN" "ALIAS" "% OF HISTORY"
printf "%-8s %-6s %-20s %s\n" "-----" "------" "-----" "------------"
used=0
while read -r plugin alias_name; do
    count=$(grep -E "^[[:space:]]*[0-9]+[[:space:]]+${alias_name}$" "$cmd_counts" 2>/dev/null | awk '{print $1}' || true)
    if [[ -n "$count" && "$count" -gt 0 ]]; then
        pct=$(awk "BEGIN {printf \"%.2f\", ($count/$total_history)*100}")
        echo "$count $plugin $alias_name $pct%"
        used=$((used + 1))
    fi
done < "$omz_aliases" | sort -rn | while read -r count plugin alias_name pct; do
    printf "%-8s %-6s %-20s %s\n" "$count" "$plugin" "$alias_name" "$pct"
done

echo ""
echo "=== Summary ==="
echo "Aliases used:    $used / $total_aliases"
echo "Aliases unused:  $((total_aliases - used)) / $total_aliases"

echo ""
echo "=== Unused aliases by plugin ==="
for plugin in $PLUGINS; do
    unused_list=""
    while read -r p a; do
        [[ "$p" != "$plugin" ]] && continue
        count=$(grep -E "^[[:space:]]*[0-9]+[[:space:]]+${a}$" "$cmd_counts" 2>/dev/null | awk '{print $1}' || true)
        if [[ -z "$count" || "$count" -eq 0 ]]; then
            unused_list="$unused_list $a"
        fi
    done < "$omz_aliases"
    if [[ -n "$unused_list" ]]; then
        total_plugin=$(grep -c "^$plugin " "$omz_aliases")
        used_plugin=$(( total_plugin - $(echo "$unused_list" | wc -w) ))
        echo ""
        echo "$plugin ($used_plugin/$total_plugin used):"
        echo " $unused_list" | fmt -w 80
    fi
done

rm -f "$omz_aliases" "$cmd_counts"
