#!/usr/bin/env bash
# new-course.sh — scaffold a new course folder under the course-site repo's ws26-27/<slug>/,
# wired for this skill's render.py pipeline: a src/ for Markdown sources, an owned copy of
# assets/quiz.js + assets/style.css (not a symlink — courses diverge, e.g. FOMO's palette),
# and cheat-sheets/ as an alias for the skeleton's reference/ folder.
#
# Usage:
#   template/new-course.sh <slug> "<Course Title>" "<Badge Label>" ["<one-line lede>"]
#
# Example:
#   template/new-course.sh robotics "Introduction to Robotics" "ROBOTICS" \
#     "Kinematics, control, and perception, tied to the lab exercises."
#
# Run this from anywhere. It only creates files under the site repo's ws26-27/<slug>/ —
# it does not touch any other course's files or ws26-27/index.html. After it runs, do the
# manual steps it prints at the end.

set -euo pipefail

if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <slug> \"<Course Title>\" \"<Badge Label>\" [\"<one-line lede>\"]" >&2
    exit 1
fi

SLUG="$1"
TITLE="$2"
LABEL="$3"
LEDE="${4:-Keyword lessons, worked exercises, question banks, and cheat sheets.}"

if ! [[ "$SLUG" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
    echo "error: slug must be lowercase letters, digits, and hyphens only (got: $SLUG)" >&2
    exit 1
fi

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SITE_REPO="$HOME/repo/minhh-nguyen.github.io"
TEMPLATE_DIR="$SKILL_DIR/template/skeleton"
DEST_DIR="$SITE_REPO/ws26-27/$SLUG"

if [ ! -d "$SITE_REPO" ]; then
    echo "error: course-site repo not found at $SITE_REPO" >&2
    exit 1
fi

if [ -e "$DEST_DIR" ]; then
    echo "error: $DEST_DIR already exists" >&2
    exit 1
fi

cp -R "$TEMPLATE_DIR" "$DEST_DIR"
mkdir -p "$DEST_DIR/src"
cp "$SKILL_DIR/assets/quiz.js" "$SKILL_DIR/assets/style.css" "$DEST_DIR/assets/"
ln -s reference "$DEST_DIR/cheat-sheets"

# Placeholder substitution (index.html only — the other files have none).
sed -i '' \
    -e "s/{{COURSE_TITLE}}/$TITLE/g" \
    -e "s/{{COURSE_LABEL}}/$LABEL/g" \
    -e "s/{{COURSE_SLUG}}/$SLUG/g" \
    -e "s/{{COURSE_LEDE}}/$LEDE/g" \
    "$DEST_DIR/index.html"

echo "Created $DEST_DIR"
echo
echo "Three manual steps left (the header/footer nav is plain static HTML,"
echo "same as every other page on the site — no shared script to update):"
echo
echo "1. In $DEST_DIR/index.html's <header>, list the other courses too"
echo "   (copy their <a> links from any existing ws26-27/<course>/index.html)."
echo
echo "2. In each EXISTING course's <header> ($SITE_REPO/ws26-27/{fomo,hcsd,pmpp,chinese}/index.html)"
echo "   and in index.html/blog/index.html/ws26-27/index.html, add:"
echo "     <a href=\"/ws26-27/$SLUG/\">$LABEL</a>"
echo
echo "3. In $SITE_REPO/ws26-27/index.html, add a card inside <div class=\"grid\">:"
cat <<EOF

    <a class="card" href="/ws26-27/$SLUG/">
        <span class="badge accent">TU Darmstadt · WS 2026/27</span>
        <h3>$TITLE</h3>
        <p>$LEDE</p>
        <span class="meta">Study site →</span>
    </a>
EOF
