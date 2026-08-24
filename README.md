# Lumastra — LGPL Corresponding Source

This repository exists to satisfy the LGPL for **Lumastra for Apple TV**, which
statically links [MPVKit](https://github.com/mpvkit/MPVKit) (libmpv + FFmpeg).

If you received the app and want to modify the LGPL libraries inside it and run
your modified version, everything you need is here or linked from here.

> The Lumastra **iOS** app links no LGPL component and is not covered by this
> repository. Only the tvOS app is.

---

## What is here

| Path | What it is |
|---|---|
| `mpvkit-0.41.0/` | **MPVKit at tag `0.41.0`, vendored verbatim** — build scripts and the patches it applies to upstream |
| `scripts/fetch-upstream-sources.sh` | Fetches the pinned mpv and FFmpeg sources |
| `MANIFEST.md` | Exact versions, commits and checksums of everything linked |
| `Legal/` | LGPL-2.1, LGPL-3.0 and GPL-3.0 licence texts |

**MPVKit is vendored rather than merely linked on purpose.** MPVKit patches mpv
and FFmpeg during its build, so vanilla upstream tarballs are *not* the
Corresponding Source on their own — the patches are part of what was built.
Upstream tags can also move or disappear; this copy cannot.

## What is not here, and why

This repository does **not** contain Lumastra's own source code, and is not
required to. LGPL-3.0 §0 defines the Corresponding Application Code as

> "the **object code and/or source code** for the Application"

The *and/or* is the point: object code satisfies it. That is exactly the
difference between the LGPL and the GPL, and it is why Lumastra can link libmpv
while remaining a proprietary application.

The application's **object code** — everything needed to relink it — is
published as a **relink kit**, attached to this repository's Releases for every
Apple TV build that is distributed.

---

## Relinking Lumastra with your own libmpv

1. **Get the library source**

   ```bash
   ./scripts/fetch-upstream-sources.sh
   ```

   This downloads mpv `v0.41.0` and FFmpeg `n8.0.1` and verifies them against
   `MANIFEST.md`. Combined with `mpvkit-0.41.0/`, that is the complete
   Corresponding Source for the libraries in the shipped app.

2. **Make your changes and rebuild the frameworks**

   ```bash
   cd mpvkit-0.41.0
   make build platform=tvos
   ```

   This produces `.xcframework` bundles. Note the shipped build is the **LGPL**
   configuration — do not pass `enable-gpl` if you want to match it.

3. **Download the relink kit** for the app version you have, from this
   repository's Releases. It contains the application's object code, the exact
   link command used to produce the shipped binary, and the unmodified
   frameworks for comparison.

4. **Relink** — replace the matching framework with yours and re-run the link
   command from the kit against the supplied object code.

5. **Sign and install.** Sign with your own certificate and install to your own
   Apple TV through Xcode. **A free Apple ID is sufficient** for installing to a
   device you own; you do not need a paid developer account.

Full step-by-step instructions ship inside each relink kit's own `README.md`,
generated against the specific build it belongs to.

---

## Your rights

The LGPL grants you the right to modify the covered libraries and to run a
Lumastra relinked against your modified versions, for any purpose. It also
requires that you be permitted to reverse engineer the application as far as
needed to debug those modifications. We don't restrict that for the LGPL
components, whatever the platform's standard licence terms say.

## Requests

If anything here is incomplete, unclear, or a link has rotted, please open an
issue on this repository. A compliance gap is a bug, and will be treated as one.

## Licences

Covered components are under the GNU Lesser General Public License. Full texts
of LGPL-2.1, LGPL-3.0 and GPL-3.0 (which the LGPL incorporates by reference) are
in `Legal/`, and are also reproduced in full inside the app under
**Settings → Licenses**.
