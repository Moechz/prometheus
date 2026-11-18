# NOTICE — third-party components and attributions

This package (`prometheusdocker`, TOS 7 Docker application) is an independent packaging by
Moechz of the upstream **Prometheus** project. It is not affiliated with, sponsored or
endorsed by the Prometheus Authors or by TerraMaster.

## 1. Upstream application — Prometheus

- Project: <https://github.com/prometheus/prometheus>
- Homepage: <https://prometheus.io/>
- Licence: **Apache-2.0**
- Relationship: the upstream application is used **unmodified**, inside the container
  image. No upstream source code is redistributed in this package.

## 2. Container image — `prom/prometheus:v3.16.0`

- Registry: Docker Hub (`prom/prometheus:v3.16.0`), digest
  `sha256:e04987641b57704f408e31f6373ba4138ecf27cb4a165d24aabb6c38fddd0f06`
  (x86_64, also published for aarch64)
- Maintainer: the Prometheus Authors
- The image is pulled from Docker Hub (or the user's registry mirror) at install time and
  is **not** redistributed inside this package.

## 3. Components inside the image

The image is built by the Prometheus Authors on top of their BusyBox/Buildroot base image
and contains the Prometheus server, `promtool`, the web UI assets and the base system
utilities. Their licences (Apache-2.0 for Prometheus; GPL-2.0 for BusyBox and the base
system) are documented in the image's own package metadata. They are shipped inside the
image only and are not redistributed as separate files by this package.

## 4. This packaging

The files authored for this package — `docker-compose.yml`, `config.ini`,
`prometheusdocker.lang`, `prometheusdocker.svg`, `entrypoint.sh`, the build/verification
scripts and this documentation — are released under the **MIT** licence (see `LICENSE`).
The upstream application stays under Apache-2.0; no upstream source code is included here.

## 5. Trademarks

“Prometheus” is a project name of the Prometheus Authors; “TerraMaster”, “TOS” and “App
Center” are trademarks or registered trademarks of their respective owners. Their use here
is descriptive only (to identify the software being packaged and the platform it runs on).

## 6. Icon

The application icon in `src/prometheusdocker.svg` is the Prometheus brand glyph (the
project's flame mark, in the project's orange) scaled to the TOS icon safe area, used only
to identify the project this package installs. It is not a TerraMaster or App Center asset
and no TerraMaster artwork is reproduced.

## 7. Contact

Moechz — **moechz@163.com** — <https://www.moechz.com/>
Privacy policy: [PRIVACY.md](PRIVACY.md)
