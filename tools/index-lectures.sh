#!/usr/bin/env bash
# Build a token-cheap search index for lecture material.
#
#   tools/index-lectures.sh <semester-or-course-dir> [--force]
#   tools/index-lectures.sh ~/Documents/tuda/lectures/4.ws2627
#
# For every PDF it writes a page-tagged text sidecar, so a single grep returns the exact page
# a topic appears on. The agent then reads only those pages instead of the whole document.
#
# Output goes to <lectures-root>/.search/, never into the course directories: several of them
# are git repositories and must stay clean.
#
# Incremental: a sidecar is rebuilt only when the PDF is newer, or with --force.
# Requires poppler (`pdftotext`, `pdfinfo`): brew install poppler
set -euo pipefail

target="${1:-}"
force=0
[[ "${2:-}" == "--force" ]] && force=1
[[ -n "$target" && -d "$target" ]] || { echo "usage: $0 <semester-or-course-dir> [--force]" >&2; exit 1; }

command -v pdftotext >/dev/null || { echo "error: pdftotext not found (brew install poppler)" >&2; exit 1; }
command -v pdfinfo   >/dev/null || { echo "error: pdfinfo not found (brew install poppler)" >&2; exit 1; }

target="$(cd "$target" && pwd)"

# The lectures root is the ancestor directory named "lectures"; fall back to the target itself.
root="$target"
while [[ "$root" != "/" && "$(basename "$root")" != "lectures" ]]; do root="$(dirname "$root")"; done
[[ "$root" == "/" ]] && root="$target"
search="$root/.search"

# Directories that hold dependencies or tooling, not course material.
prune=(-name .git -o -name .venv -o -name venv -o -name node_modules -o -name __pycache__
       -o -name site-packages -o -name .ipynb_checkpoints -o -name .pytest_cache)

list_files() {  # list_files <dir> <find-args...>
  local dir="$1"; shift
  find "$dir" \( "${prune[@]}" \) -prune -o -type f \( "$@" \) -print
}

human() { awk 'BEGIN{s='"$1"'; split("B KB MB GB",u," "); i=1; while(s>=1024&&i<4){s/=1024;i++} printf "%.0f%s", s, u[i]}'; }

# Strip running headers and footers: any line repeating on more than half the pages.
# They are the single largest source of false grep hits in lecture slides.
build_sidecar() {  # build_sidecar <pdf> <out.txt> <pages>
  local pdf="$1" out="$2" pages="$3"
  mkdir -p "$(dirname "$out")"
  pdftotext -layout "$pdf" - 2>/dev/null | awk -v pages="$pages" '
    BEGIN { p = 1 }
    {
      line = $0
      if (index(line, "\f")) { p++; gsub(/\f/, "", line) }
      gsub(/^[ \t]+|[ \t]+$/, "", line)
      gsub(/[ \t]+/, " ", line)
      if (length(line) == 0) next
      page[NR] = p; text[NR] = line; seen[line]++
      n = NR
    }
    END {
      threshold = (pages > 4) ? pages / 2 : pages + 1
      for (i = 1; i <= n; i++)
        if (seen[text[i]] <= threshold)
          printf "p%d\t%s\n", page[i], text[i]
    }
  ' > "$out"
}

index_course() {  # index_course <course-dir>
  local course="$1"
  local rel="${course#"$root"/}"
  local outdir="$search/$rel"
  mkdir -p "$outdir"
  local index="$outdir/INDEX.md"
  local built=0 skipped=0 docs=0

  {
    echo "# Index: $(basename "$course")"
    echo
    echo "Course directory: \`$course\`"
    echo "Generated: $(date '+%Y-%m-%d %H:%M')"
    echo
    echo "## PDFs"
    echo
    echo "Grep the sidecar, then read only the pages it reports."
    echo
    echo "| Document | Pages | Sidecar |"
    echo "| --- | --- | --- |"
  } > "$index"

  while IFS= read -r pdf; do
    [[ -n "$pdf" ]] || continue
    local relpdf="${pdf#"$course"/}"
    local pages
    pages="$(pdfinfo "$pdf" 2>/dev/null | awk '/^Pages:/{print $2}')"
    [[ -n "$pages" ]] || pages="?"
    local side="$outdir/$relpdf.txt"
    if (( force )) || [[ ! -f "$side" || "$pdf" -nt "$side" ]]; then
      build_sidecar "$pdf" "$side" "${pages/\?/0}"
      built=$((built + 1))
    else
      skipped=$((skipped + 1))
    fi
    printf '| `%s` | %s | `%s` |\n' "$relpdf" "$pages" "${side#"$search"/}" >> "$index"
    docs=$((docs + 1))
  done < <(list_files "$course" -iname '*.pdf' | sort)

  # Text-shaped files need no sidecar: grep them in place.
  local others
  others="$(list_files "$course" -iname '*.md' -o -iname '*.txt' -o -iname '*.ipynb' \
            -o -iname '*.py' -o -iname '*.cu' -o -iname '*.cpp' -o -iname '*.h' -o -iname '*.tex' \
            | sed "s|^$course/||" | sort)"
  {
    echo
    echo "## Text files (grep in place, no sidecar)"
    echo
    if [[ -n "$others" ]]; then
      printf '%s\n' "$others" | sed 's/^/- `/; s/$/`/'
    else
      echo "_none_"
    fi
  } >> "$index"

  printf '%-28s %3d pdfs  %3d built  %3d cached\n' "$(basename "$course")" "$docs" "$built" "$skipped"
}

# A target containing PDFs directly is a course; otherwise treat each child as a course.
semester_index=""
if [[ -n "$(list_files "$target" -iname '*.pdf' -maxdepth 1 2>/dev/null || true)" ]] \
   || [[ -z "$(find "$target" -mindepth 1 -maxdepth 1 -type d \( "${prune[@]}" \) -prune -o -type d -print)" ]]; then
  courses=("$target")
else
  # Read into an array without mapfile: macOS ships bash 3.2.
  courses=()
  while IFS= read -r d; do courses+=("$d"); done \
    < <(find "$target" -mindepth 1 -maxdepth 1 -type d ! -name '.*' | sort)
  semester_index="$search/${target#"$root"/}/INDEX.md"
fi

echo "lectures root: $root"
echo "index output:  $search"
echo
for c in "${courses[@]}"; do index_course "$c"; done

if [[ -n "$semester_index" ]]; then
  mkdir -p "$(dirname "$semester_index")"
  {
    echo "# Semester: $(basename "$target")"
    echo
    echo "Generated: $(date '+%Y-%m-%d %H:%M')"
    echo
    echo "| Course | PDFs | Index |"
    echo "| --- | --- | --- |"
    for c in "${courses[@]}"; do
      n="$(list_files "$c" -iname '*.pdf' | wc -l | tr -d ' ')"
      printf '| `%s` | %s | `%s` |\n' "$(basename "$c")" "$n" "${c#"$root"/}/INDEX.md"
    done
  } > "$semester_index"
  echo
  echo "semester index: $semester_index"
fi
