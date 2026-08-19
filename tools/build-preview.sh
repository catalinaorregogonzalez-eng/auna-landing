#!/usr/bin/env bash
# Builds a shareable preview of the page (or of a proposed edit) that can be
# published as an Artifact and opened on a phone.
#
#   tools/build-preview.sh <source.html> <output.html>
#
# Artifacts are wrapped in their own <html>/<head>/<body>, so this strips those
# wrappers and keeps only the title, the styles and the page content.
# Google Fonts cannot load inside an Artifact, so local lookalikes are mapped in.
set -euo pipefail

SRC="${1:?usage: build-preview.sh <source.html> <output.html>}"
OUT="${2:?usage: build-preview.sh <source.html> <output.html>}"

inline_local_images() {  # <file> -> stdout with images/*.webp turned into data: URIs
  python3 - "$1" <<'PYI'
import base64, mimetypes, os, re, sys
src = sys.argv[1]
root = os.path.dirname(os.path.abspath(src)) or '.'
# preview files are built from copies in the scratchpad; the images live next to
# the real index.html, so look there too
here = os.path.dirname(os.path.abspath(__file__)) if '__file__' in dir() else '.'
repo = os.path.abspath(os.path.join(os.getcwd()))
text = open(src, encoding='utf-8').read()

def swap(m):
    path = m.group(1)
    for base in (root, repo):
        full = os.path.join(base, path)
        if os.path.exists(full):
            mime = mimetypes.guess_type(full)[0] or 'application/octet-stream'
            data = base64.b64encode(open(full, 'rb').read()).decode()
            return 'src="data:%s;base64,%s"' % (mime, data)
    print('WARNING: could not find %s to inline' % path, file=sys.stderr)
    return m.group(0)

print(re.sub(r'src="((?!data:|https?:)[^"]+)"', swap, text), end='')
PYI
}

SRC_INLINED=$(mktemp -t preview-src)
trap 'rm -f "$SRC_INLINED"' EXIT
inline_local_images "$SRC" > "$SRC_INLINED"
SRC="$SRC_INLINED"

title_line=$(grep -n '<title>' "$SRC" | head -1 | cut -d: -f1)
style_open=$(grep -n '^<style>' "$SRC" | head -1 | cut -d: -f1)
style_close=$(grep -n '^</style>' "$SRC" | head -1 | cut -d: -f1)
body_open=$(grep -n '^<body>' "$SRC" | head -1 | cut -d: -f1)
body_close=$(grep -n '^</body>' "$SRC" | head -1 | cut -d: -f1)

{
  sed -n "${title_line}p" "$SRC"
  sed -n "${style_open},${style_close}p" "$SRC"
  printf '%s\n' "<style>/* preview only: stand-ins for the web fonts */" \
    "@font-face{font-family:'Cormorant Garamond';src:local('Georgia');}" \
    "@font-face{font-family:'Cormorant Garamond';src:local('Georgia Italic');font-style:italic;}" \
    "@font-face{font-family:'Inter';src:local('Helvetica Neue');}" \
    "</style>"
  sed -n "$((body_open + 1)),$((body_close - 1))p" "$SRC"
} > "$OUT"

echo "preview written: $OUT ($(wc -c < "$OUT") bytes)"
