#!/usr/bin/env bash
# Reconcile ~/.claude/skills with skills.json.
#
#   ./install.sh            apply
#   ./install.sh --dry-run  print the plan and change nothing
#
# Skills owned by this repository are linked to it, so editing a SKILL.md here is the only
# step needed to change behavior. Third-party skills are linked to their installer root and
# never copied here, so they keep receiving upstream updates; this script only decides
# whether each one is active.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
manifest="$repo/skills.json"
dry_run=0
[[ "${1:-}" == "--dry-run" ]] && dry_run=1

[[ -f "$manifest" ]] || { echo "error: $manifest not found" >&2; exit 1; }

eval "$(python3 -I - "$manifest" <<'PY'
import json, shlex, sys
m = json.load(open(sys.argv[1]))
print(f"target={shlex.quote(m['target'])}")
print(f"external_root={shlex.quote(m['external_root'])}")
print("ignore=" + shlex.quote("\n".join(m.get("unmanaged_ignore", []))))
rows = [f"owned\t{s['name']}" for s in m["owned"] if s.get("active", True)]
rows += [f"external\t{s['name']}" for s in m["external"] if s.get("active", True)]
rows += [f"disable\t{s['name']}" for s in m["external"] if not s.get("active", True)]
print("plan=" + shlex.quote("\n".join(rows)))
PY
)"

target="${target/#\~/$HOME}"
external_root="${external_root/#\~/$HOME}"
backups="$repo/.install-backups"

say() { printf '%-9s %s\n' "$1" "$2"; }
run() { (( dry_run )) || "$@"; }

mkdir -p "$target"

while IFS=$'\t' read -r kind name; do
  [[ -n "$name" ]] || continue
  link="$target/$name"

  if [[ "$kind" == "disable" ]]; then
    if [[ -L "$link" ]]; then
      say disable "$name (link removed)"
      run rm -f "$link"
    elif [[ -d "$link" ]]; then
      # A real directory is an unmanaged copy. Preserve it instead of deleting.
      say disable "$name (copy moved to .install-backups/)"
      run mkdir -p "$backups"
      run mv "$link" "$backups/$name.$(date +%Y%m%d%H%M%S)"
    else
      say ok "$name (already inactive)"
    fi
    continue
  fi

  case "$kind" in
    owned)    src="$repo/skills/$name" ;;
    external) src="$external_root/$name" ;;
  esac

  if [[ ! -d "$src" ]]; then
    say MISSING "$name -> $src does not exist"
    continue
  fi

  if [[ -L "$link" ]]; then
    current="$(readlink "$link")"
    if [[ "$current" == "$src" ]]; then
      say ok "$name"
      continue
    fi
    say relink "$name ($current -> $src)"
  elif [[ -d "$link" ]]; then
    # An unmanaged copy: this is how skills drift out of sync. Keep it, then replace it.
    say replace "$name (copy moved to .install-backups/)"
    run mkdir -p "$backups"
    run mv "$link" "$backups/$name.$(date +%Y%m%d%H%M%S)"
  else
    say link "$name"
  fi
  run ln -sfn "$src" "$link"
done <<< "$plan"

echo
echo "Unmanaged entries in $target (not declared in skills.json):"
declared=$(printf '%s\n%s\n' "$(cut -f2 <<< "$plan")" "$ignore" | sort -u)
found=0
for entry in "$target"/*; do
  [[ -e "$entry" || -L "$entry" ]] || continue
  base="$(basename "$entry")"
  if ! grep -qxF "$base" <<< "$declared"; then
    echo "  $base"
    found=1
  fi
done
(( found )) || echo "  none"

(( dry_run )) && echo && echo "dry run: nothing was changed"
exit 0
