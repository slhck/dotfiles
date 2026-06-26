#!/usr/bin/env python3
"""PreToolUse hook: block `rg -r` / `rg --replace`.

Claude often reaches for `rg -r` thinking it enables recursion. In ripgrep,
`-r`/`--replace` is the REPLACE flag, and recursion is on by default. This hook
denies any Bash command whose ripgrep invocation uses the replace flag, so the
mistake gets corrected instead of silently searching wrong.

It parses each pipeline/sequence segment separately, so a legitimate
`rg foo | sed -r 's/.../.../'` (where `-r` belongs to sed) is NOT blocked.
"""
import json
import re
import shlex
import sys

# ripgrep short flags that consume a value. When one of these appears in a
# short-flag cluster, everything after it is that flag's value, not more flags.
VALUE_FLAGS = set("ABCEMTefgmrtj")

# leading words that wrap a command without being the command itself
WRAPPERS = {"command", "sudo", "time", "nice", "env", "noglob", "builtin", "exec"}
ASSIGN = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*=")


def segment_uses_rg_replace(seg):
    try:
        tokens = shlex.split(seg)
    except ValueError:
        tokens = seg.split()
    if not tokens:
        return False

    i = 0
    # skip env-var assignments and command wrappers (env VAR=val rg ...)
    while i < len(tokens) and (ASSIGN.match(tokens[i]) or tokens[i] in WRAPPERS):
        i += 1
    if i >= len(tokens):
        return False

    prog = tokens[i].lstrip("\\").split("/")[-1]
    if prog != "rg":
        return False

    skip_next = False
    for tok in tokens[i + 1:]:
        if skip_next:
            skip_next = False
            continue
        if tok == "--":
            break  # everything after is positional
        if tok == "--replace" or tok.startswith("--replace="):
            return True
        if tok.startswith("--"):
            continue  # other long flag; ignore
        if tok.startswith("-") and len(tok) > 1:
            cluster = tok[1:]
            for idx, ch in enumerate(cluster):
                if ch == "r":
                    return True
                if ch in VALUE_FLAGS:
                    # value-taking flag: rest of cluster is its value, or the
                    # next token is, so stop scanning this cluster
                    if idx == len(cluster) - 1:
                        skip_next = True
                    break
    return False


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    cmd = (data.get("tool_input") or {}).get("command", "")
    if not cmd:
        sys.exit(0)

    segments = re.split(r"\|\||&&|[|;\n]", cmd)
    if any(segment_uses_rg_replace(s) for s in segments):
        reason = (
            "`rg -r` (--replace) means REPLACE, not recurse. ripgrep already "
            "searches recursively by default, so no flag is needed for that. "
            "Remove the -r. (Only use --replace if you genuinely want ripgrep "
            "to print matches with text substituted.)"
        )
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": reason,
            }
        }))
        sys.exit(0)

    sys.exit(0)


if __name__ == "__main__":
    main()
