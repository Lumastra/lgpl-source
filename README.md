# Lumastra — LGPL Corresponding Source and relink kits

This repository provides the LGPL materials for **Lumastra for Apple TV**
(tvOS). The app statically links libmpv, FFmpeg and other libraries built from
MPVKit recipes. The libraries under the LGPL are distributed under **LGPL
version 3**: where a library is "LGPL-2.1-or-later", the later-version option is
used. The Lumastra **iOS** app links no LGPL component and is not covered here.

## Where the materials are: one GitHub Release per distributed build

Each distributed Apple TV build has its own Release, tagged
`tvos-<version>-<build>`, for example `tvos-1.0.1-2610061531`. **Settings → Licenses** in the app links
directly to the Release for the build you have installed. Each Release contains:

| Asset | What it is |
|---|---|
| `corresponding-source-<build>.tar.gz` | Complete Corresponding Source for every library linked into that build: pinned upstream source trees, every patch applied, build recipes and scripts, generated configuration headers, notices, and `source-manifest.json` with the checksum of every file and the linked-binary hashes it corresponds to |
| `relink-kit-<build>.tar.gz` | The application's object code and resources for that build (no application source), the exact non-SDK libraries linked, the captured final link commands for the app and its Top Shelf extension, and `relink.py` / `sign.py` |
| `SHA256SUMS` | SHA-256 of both archives |

Use only the Release whose build number matches your app. A kit from one build
cannot be applied to another build, and the tools refuse to.

The files at the root of this repository are **not** Corresponding Source for any
current build. The authoritative material is the Release assets.

## Relinking

Requirements: a Mac with the Xcode and tvOS SDK versions recorded in the kit's
`manifest.json`, and Python 3.

1. Download and verify both archives (`shasum -a 256 -c SHA256SUMS`), then unpack.
2. Modify and rebuild a library from `corresponding-source-<build>`. See its
   `README.md` and `scripts/build-lgpl-libraries.sh`. The shipped configuration
   is LGPL: GPL and nonfree are disabled.
3. Relink:

   ```bash
   cd relink-kit
   python3 relink.py relink --output '/tmp/my relinked app'
   python3 relink.py relink --output '/tmp/my modified app' \
     --library Libmpv --replacement /absolute/path/to/modified/Libmpv
   ```

   Every kit input is checked against its manifest before linking.
   `verification.json` records the resulting executable and replacement checksums.
4. Sign and install with **your own** Apple identity and provisioning profiles:
   `python3 sign.py --help`. You can set your own bundle identifiers and app group
   (`--bundle-id`, `--extension-bundle-id`, `--app-group`). The app and its Top
   Shelf extension need profiles that cover a shared app group. Not every Apple ID
   or account type may offer that capability. Install with Xcode or
   `xcrun devicectl device install app --device <DEVICE> <path to .app>`.

The kit's own `README.md` is the reference for each build.

**Installation Information (LGPLv3 §4(e)):** this applies only where GPLv3 §6
would, that is, when the app is conveyed together with a transfer of the device.
Lumastra is distributed separately from the Apple TV, so we do not consider it
triggered. The installation procedure above is documented anyway. It needs no keys
from us. Apple's own limits still apply: provisioning-profile lifetimes, and App
Group availability on your account type.

## Your rights

You may modify the LGPL-covered libraries, relink Lumastra against your modified
versions, and run the result. The application object-code permission, in
`Legal/APPLICATION-OBJECT-CODE-PERMISSION.txt` inside each kit and in the app
under Settings → Licenses, also lets you reverse engineer the application as far
as needed to debug those modifications. This applies whatever the platform's
standard licence terms say.

## Builds before the first Release

Test builds before the first Release used upstream MPVKit binaries. They were only
ever installed by the developer, and they are being withdrawn from TestFlight. No
Release here covers them.

## Requests

If anything is incomplete, unclear, or a link has rotted, please open an issue. A
compliance gap is a bug and will be treated as one.

## Licences

The full licence texts for every component are inside each archive and are
reproduced in the app under **Settings → Licenses**.
