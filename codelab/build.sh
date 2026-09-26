#!/usr/bin/env bash
# Rigenera docs/ dal sorgente del codelab.
# Requisiti: claat (go install github.com/googlecodelabs/tools/claat@latest) e python3.
set -euo pipefail
cd "$(dirname "$0")"
ROOT="$(cd .. && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

claat export -o "$TMP" concorrente-artificiale.md
OUT="$TMP/concorrente-artificiale-adk2"

rm -rf "$ROOT/docs"
mkdir -p "$ROOT/docs/elements"
cp -R "$OUT/." "$ROOT/docs/"
cp vendor/* theme/* "$ROOT/docs/elements/"
touch "$ROOT/docs/.nojekyll"

# Il bucket storage.googleapis.com/claat-public non è più pubblico: gli elementi
# del codelab sono serviti dal repository. Niente analytics né widget esterni.
python3 - "$ROOT/docs/index.html" <<'EOF'
import re, sys
p = sys.argv[1]
s = open(p, encoding="utf-8").read()
s = s.replace("https://storage.googleapis.com/claat-public/", "elements/")
s = re.sub(r'\s*<google-codelab-analytics[^>]*></google-codelab-analytics>', "", s)
s = re.sub(r'\s*<script src="//support\.google\.com/inapp/api\.js"></script>', "", s)
s = s.replace("</head>", '  <link rel="stylesheet" href="elements/custom.css">\n</head>', 1)
s = s.replace("</body>", '  <script src="elements/custom.js"></script>\n</body>', 1)
if "claat-public" in s or "<task>" in re.sub(r"<pre>.*?</pre>", "", s, flags=re.S):
    sys.exit("index.html contiene ancora riferimenti a claat-public o segnaposto <task> non protetti")
open(p, "w", encoding="utf-8").write(s)
EOF
echo "docs/ rigenerato."
