#!/usr/bin/env bash
#
# Build the documents in this repository.
#
#   ./build.sh                       build every document
#   ./build.sh dokumente/skript      build every document under a folder
#   ./build.sh dokumente/skript/numprog_skript.tex   build a single document
#
# Each PDF is written next to its .tex file; intermediate files land in .build/
# and are gitignored, as are the PDFs themselves -- they are build output, not
# repository content.
#
# A document that contains \ifdefined\npprint is built twice: once normally and
# once with \npprint defined, producing <name>.pdf and <name>_print.pdf.
#
# Requires a TeX Live (or MiKTeX) installation with latexmk on PATH.

set -uo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$root"

if ! command -v latexmk >/dev/null 2>&1; then
    echo "error: latexmk not found on PATH. Install TeX Live or MiKTeX." >&2
    exit 127
fi

# ---------------------------------------------------------------------------
# Work out which documents to build. A "document" is a .tex file that opens a
# document environment; the shared files under gemeinsam/ never do.
# ---------------------------------------------------------------------------
target="${1:-.}"
if [ -f "$target" ]; then
    documents="$target"
else
    documents=$(grep -rl --include='*.tex' -F '\begin{document}' "$target" |
                grep -v '/gemeinsam/' | sed 's|^\./||' | sort)
fi

if [ -z "$documents" ]; then
    echo "No documents found under '$target'." >&2
    exit 1
fi

failed=()
passed=0

# build <dir> <basename> <jobname> [pretex]
build_one() {
    local dir=$1 base=$2 job=$3 pretex=${4:-}
    local args=(-pdf -interaction=nonstopmode -halt-on-error -file-line-error
                -outdir=.build -jobname="$job")
    [ -n "$pretex" ] && args+=(-usepretex="$pretex")
    if ( cd "$dir" && latexmk "${args[@]}" "$base.tex" >/dev/null 2>&1 &&
         cp ".build/$job.pdf" "$job.pdf" ); then
        printf '    ok  -> %s/%s.pdf\n' "$dir" "$job"
        passed=$((passed + 1))
    else
        printf '    FAILED (see %s/.build/%s.log)\n' "$dir" "$job"
        failed+=("$dir/$job.tex")
    fi
}

while IFS= read -r doc; do
    dir=$(dirname "$doc")
    base=$(basename "$doc" .tex)
    printf '\n=== %s\n' "$doc"
    build_one "$dir" "$base" "$base"
    if grep -q 'ifdefined.npprint' "$doc"; then
        build_one "$dir" "$base" "${base}_print" '\def\npprint{}'
    fi
done <<< "$documents"

printf '\n---------------------------------------------\n'
printf '%d built, %d failed\n' "$passed" "${#failed[@]}"
for f in "${failed[@]:-}"; do
    [ -n "$f" ] && printf '  FAILED  %s\n' "$f"
done
[ "${#failed[@]}" -eq 0 ]
