#!/usr/bin/env bash
# Builds a "before and after" preview of ONE part of the page, so Catalina can
# see exactly what a proposed change does without scrolling the whole page.
#
#   tools/build-compare.sh <id> <current.html> <proposed.html> <output.html> [publicado]
#
# The optional 5th argument "publicado" flips the wording for AFTER a change is
# live: "Antes" / "Ahora — así quedó". Leave it off while proposing.
#
# <id> is any id in the page: hero, sobre, programas, faq, cierre, nav, agenda, ...
#
# Example:
#   cp index.html "$SCRATCH/propuesta.html"   # then edit the copy
#   tools/build-compare.sh hero index.html "$SCRATCH/propuesta.html" "$SCRATCH/comparacion.html"
#
# Publish the output with the Artifact tool. Both versions are stacked, each with
# a clear label, so it reads fine on a phone.
set -euo pipefail

ID="${1:?usage: build-compare.sh <section-id> <current.html> <proposed.html> <output.html>}"
CUR="${2:?missing current.html}"
NEW="${3:?missing proposed.html}"
OUT="${4:?missing output.html}"
MODE="${5:-propuesta}"   # "propuesta" (before it is decided) or "publicado" (after it is live)

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

extract_block() {  # <file> <id>  — works for any element (section, header, div…)
  python3 - "$1" "$2" <<'PYX'
import re, sys
path, wanted = sys.argv[1], sys.argv[2]
lines = open(path, encoding='utf-8').read().split('\n')
open_re = re.compile(r'<([a-zA-Z][a-zA-Z0-9]*)\b[^>]*\bid="%s"' % re.escape(wanted))
start = tag = None
for i, line in enumerate(lines):
    m = open_re.search(line)
    if m:
        start, tag = i, m.group(1)
        break
if start is None:
    sys.exit(1)
depth = 0
out = []
for line in lines[start:]:
    out.append(line)
    depth += len(re.findall(r'<%s\b' % tag, line))
    depth -= len(re.findall(r'</%s>' % tag, line))
    if depth <= 0:
        break
print('\n'.join(out))
PYX
}

CUR_INLINED=$(mktemp -t compare-cur); NEW_INLINED=$(mktemp -t compare-new)
trap 'rm -f "$CUR_INLINED" "$NEW_INLINED"' EXIT
inline_local_images "$CUR" > "$CUR_INLINED"; CUR="$CUR_INLINED"
inline_local_images "$NEW" > "$NEW_INLINED"; NEW="$NEW_INLINED"

before=$(extract_block "$CUR" "$ID") || { echo "no part of the page has the id '$ID' in $CUR" >&2; exit 1; }
after=$(extract_block "$NEW" "$ID")  || { echo "no part of the page has the id '$ID' in $NEW"  >&2; exit 1; }
[ -n "$before" ] && [ -n "$after" ] || { echo "the part with id '$ID' came out empty" >&2; exit 1; }

title_line=$(grep -n '<title>' "$CUR" | head -1 | cut -d: -f1)
style_open=$(grep -n '^<style>' "$CUR" | head -1 | cut -d: -f1)
style_close=$(grep -n '^</style>' "$CUR" | head -1 | cut -d: -f1)

{
  sed -n "${title_line}p" "$CUR"
  sed -n "${style_open},${style_close}p" "$CUR"
  cat <<'CSS'
<style>/* preview only: stand-ins for the web fonts */
@font-face{font-family:'Cormorant Garamond';src:local('Georgia');}
@font-face{font-family:'Cormorant Garamond';src:local('Georgia Italic');font-style:italic;}
@font-face{font-family:'Inter';src:local('Helvetica Neue');}
</style>
<style>/* preview only: the before/after frame */
.cmp-note{font-family:'Inter',sans-serif;font-size:14px;color:#5B584C;background:#fff;
  border-bottom:1px solid #E4E0D3;padding:14px 20px;text-align:center;}
.cmp-label{font-family:'Inter',sans-serif;font-weight:700;font-size:12.5px;letter-spacing:2px;
  text-transform:uppercase;padding:12px 20px;position:sticky;top:0;z-index:5;}
.cmp-label.now{background:#E4E0D3;color:#5B584C;}
.cmp-label.new{background:#0D2D3C;color:#F4F1E8;}
/* parts that are normally pinned to the screen edge would stack on top of each
   other in a two-panel comparison, so unpin them here */
.cmp-panel #nav,.cmp-panel #mobilecta{position:static;display:block;z-index:auto;}
</style>
CSS
  if [ "$MODE" = "publicado" ]; then
    note='Este cambio ya está publicado en tu página'
    label_old='Antes'
    label_new='Ahora — así quedó'
  else
    note='Comparación · nada de esto está publicado todavía'
    label_old='Ahora — así está hoy'
    label_new='Propuesta — así quedaría'
  fi
  printf '%s\n' "<div class=\"cmp-note\">$note</div>"
  printf '%s\n' "<div class=\"cmp-label now\">$label_old</div>"
  printf '%s\n' '<div class="cmp-panel">' "$before" '</div>'
  printf '%s\n' "<div class=\"cmp-label new\">$label_new</div>"
  printf '%s\n' '<div class="cmp-panel">' "$after" '</div>'
} > "$OUT"

echo "comparison written: $OUT ($(wc -c < "$OUT") bytes)"
