# Manifest — exactly what is linked into Lumastra for Apple TV

Every value below was read from the resolved package graph or extracted from the
**built binary**, not copied from documentation.

## Package

| | |
|---|---|
| Package | MPVKit |
| Version | `0.41.0` |
| Commit | `613c0ccc3acf70e136aaff880a9b5fe8fdfaf5b8` |
| Product linked | `MPVKit` — the **LGPL** product, **not** `MPVKit-GPL` |
| Upstream | https://github.com/mpvkit/MPVKit |
| Vendored here | `mpvkit-0.41.0/` |

The vendored copy was cloned at tag `0.41.0` and resolves to commit `613c0cc`,
which matches the revision pinned in the app's `Package.resolved` exactly.

## Library sources

| Component | Version | SHA-256 of source archive |
|---|---|---|
| mpv | `v0.41.0` | `ee21092a5ee427353392360929dc64645c54479aefdb5babc5cfbb5fad626209` |
| FFmpeg | `n8.0.1` | `679aa13a19415d5ddab91e580084e3ab20c963c8240001e5cbb955a97bdd81b1` |

`scripts/fetch-upstream-sources.sh` downloads both and verifies these digests.

## How the shipped binaries were configured

Extracted with `strings` from the tvOS `Libavutil` binary in the app — this is
the real configuration, not a claim from a build script:

```
--enable-gnutls --enable-libass --enable-libdav1d --enable-libfreetype
--enable-libfribidi --enable-libharfbuzz --enable-libplacebo --enable-libshaderc
--enable-libuavs3d --enable-libxml2 --enable-nonfree --enable-version3
--disable-shared --enable-static
```

Notably **absent: `--enable-gpl`.** The shipped build is the LGPL configuration.

### Notes on two flags

- **`--enable-version3`** is set, so LGPL**v3** terms apply in addition to
  LGPL-2.1. All three licence bodies are provided in `Legal/`.
- **`--enable-nonfree`** is set by MPVKit's build script, but **no nonfree
  component is actually enabled** — there is no `libfdk_aac`, `nvenc`, CUDA,
  `libnpp`, `decklink` or OpenSSL in the build. Every enabled external library
  is free software:

  | Library | Licence |
  |---|---|
  | gnutls | LGPL-2.1-or-later |
  | libass | ISC |
  | dav1d | BSD-2-Clause |
  | freetype | FTL / GPLv2 dual |
  | fribidi | LGPL-2.1-or-later |
  | harfbuzz | MIT |
  | libplacebo | LGPL-2.1-or-later |
  | shaderc | Apache-2.0 |
  | uavs3d | BSD-3-Clause |
  | libxml2 | MIT |

  The flag appears to be vestigial in MPVKit's configure invocation. It is
  documented here rather than left to be discovered, because a binary that
  self-reports `--enable-nonfree` looks alarming until you check what it
  actually contains.

## Linkage

The libraries are **statically** linked (`ar` archives inside `.framework`
wrappers). This is why Lumastra provides object code for relinking under
LGPL-3.0 §4(d)(0) / LGPL-2.1 §6(a) rather than relying on the shared-library
route in §4(d)(1) / §6(b).

## Scope

Only the **tvOS** application links these components. The Lumastra iOS
application links no LGPL component.
