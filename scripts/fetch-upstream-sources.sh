#!/bin/bash
# Fetches the exact mpv and FFmpeg sources linked into Lumastra for Apple TV,
# and verifies them against the digests recorded in MANIFEST.md.
#
# Together with the vendored mpvkit-0.41.0/ (which carries the patches MPVKit
# applies during its build), these make up the complete Corresponding Source for
# the LGPL libraries in the shipped app.
#
# Usage:  ./scripts/fetch-upstream-sources.sh [output-dir]

set -euo pipefail

cd "$(dirname "$0")/.."
OUT="${1:-sources}"

MPV_VERSION="v0.41.0"
MPV_URL="https://github.com/mpv-player/mpv/archive/refs/tags/${MPV_VERSION}.tar.gz"
MPV_SHA256="ee21092a5ee427353392360929dc64645c54479aefdb5babc5cfbb5fad626209"

FFMPEG_VERSION="n8.0.1"
FFMPEG_URL="https://github.com/FFmpeg/FFmpeg/archive/refs/tags/${FFMPEG_VERSION}.tar.gz"
FFMPEG_SHA256="679aa13a19415d5ddab91e580084e3ab20c963c8240001e5cbb955a97bdd81b1"

sha256_of() {
    if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1
    else shasum -a 256 "$1" | cut -d' ' -f1; fi
}

fetch() {
    local name="$1" url="$2" want="$3"
    # Separate statement: `local` expands every argument before assigning any of
    # them, so referencing $name on the line that defines it fails under `set -u`.
    local dest="$OUT/$name.tar.gz"
    if [ -f "$dest" ] && [ "$(sha256_of "$dest")" = "$want" ]; then
        echo "==> $name already present and verified"
        return
    fi
    echo "==> Downloading $name"
    curl -fL --progress-bar -o "$dest" "$url"
    local got; got="$(sha256_of "$dest")"
    if [ "$got" != "$want" ]; then
        # A mismatch means the archive is not what the shipped app was built
        # from, so it is NOT the Corresponding Source. Fail loudly rather than
        # leave someone building against the wrong tree.
        echo "ERROR: checksum mismatch for $name" >&2
        echo "  expected: $want" >&2
        echo "  actual:   $got" >&2
        echo "  This is not the source the app was built from. Please open an issue." >&2
        rm -f "$dest"
        exit 1
    fi
    echo "    verified $want"
}

mkdir -p "$OUT"
fetch mpv    "$MPV_URL"    "$MPV_SHA256"
fetch ffmpeg "$FFMPEG_URL" "$FFMPEG_SHA256"

echo "==> Extracting"
tar -xzf "$OUT/mpv.tar.gz"    -C "$OUT"
tar -xzf "$OUT/ffmpeg.tar.gz" -C "$OUT"

cat <<EOF

Done. Corresponding Source is now complete:

  $OUT/mpv-${MPV_VERSION#v}/       mpv $MPV_VERSION
  $OUT/FFmpeg-$FFMPEG_VERSION/     FFmpeg $FFMPEG_VERSION
  mpvkit-0.41.0/                   MPVKit build scripts and patches

To rebuild the frameworks as shipped (LGPL configuration, no GPL):

  cd mpvkit-0.41.0 && make build platform=tvos

Then follow the relink instructions in the relink kit from this repo's Releases.
EOF
