# prometheus-for-tos

> TerraMaster TOS 7 App Center — **Docker application** package for
> [Prometheus](https://github.com/prometheus/prometheus).

## What this is

A four-file TOS Docker application archive (`prometheusdocker.tar.gz`) that installs
Prometheus on TOS 7 through the App Center:

- `config.ini` — TOS application metadata (`application_type: docker`, id `prometheusdocker`)
- `prometheusdocker.lang` — 23-language superset (TOS requires 14)
- `prometheusdocker.svg` — application icon (928 bytes, 3 SVG elements)
- `docker-compose.yml` — one service, image `prom/prometheus:v3.16.0`

## How it works

| | |
|---|---|
| Container image | `prom/prometheus:v3.16.0` (Docker Hub, used unmodified) |
| Open | `http://<NAS-IP>:8008/` (container port 9090) |
| Runs as | non-root, `user: "1000:1000"` |
| Persistent data | `/prometheus` → `/Volume1/DockerAppData/prometheusdocker/data`, `/config` → `/Volume1/DockerAppData/prometheusdocker/config` |
| Logs | `docker logs prometheusdocker` (stdout/stderr) |

`/config/prometheus.yml` is the editable scrape configuration; `/prometheus` holds the time-series database (`wal/`, `chunks_head/`) and grows with retention.

## Design highlights

- **Non-root.** `user: "1000:1000"`; verified on real hardware (the container reports uid 1000).
- **Entrypoint wrapper**: the image keeps its config in a read-only path and runs as `nobody`; the wrapper seeds `prometheus.yml` into the config volume, validates it with `promtool` and starts Prometheus as uid 1000, falling back to the bundled default when the file is broken.
- **Fixed image tag, never `:latest`**, Docker Hub only, no `privileged`, no `network_mode: host`, and no Docker socket, no `cap_add`.
- **Health check** probing the service on container port 9090.
- **Deterministic build**: GNU tar with uid/gid 0 and zeroed timestamps, gzip without a timestamp, plus the review-standards self-check above.
- **Editable config in the data volume.** The image keeps its config in a read-only path; the wrapper seeds it into `/config` on first start so users can add targets from the NAS.
- **Validated with promtool.** A broken YAML is replaced by the bundled default instead of leaving the container in a restart loop.
- **Non-root.** Runs as uid 1000 with writable `/config` and `/prometheus`.

## Runtime file manifest

Everything the application writes on the NAS lives inside its own data
directory; the container-internal `/tmp` is discarded with the container. The
table lists what is created and how it behaves. Nothing else is written.

| Path | Purpose | Created when | Growth bound | Lifecycle |
|---|---|---|---|---|
| `/Volume1/DockerAppData/prometheusdocker/data` | Prometheus application data (everything the container writes outside /tmp) | on first start / on demand | bounded by your own data | persistent; kept on uninstall unless you ask to delete it |
| `/Volume1/DockerAppData/prometheusdocker/config` | Prometheus application data (everything the container writes outside /tmp) | on first start / on demand | bounded by your own data | persistent; kept on uninstall unless you ask to delete it |

## Build

```bash
scripts/build.sh                  # -> out/prometheusdocker.tar.gz + .sha256
scripts/build.sh 3.16.0-2   # packaging iteration bump
scripts/build.sh 3.16.0-1 aarch64
```

The build stages the four files, substitutes the version/platform placeholders,
embeds `src/entrypoint.sh` into the compose file (escaping every `$` as `$$`), removes CRLF/BOM/AppleDouble, then runs
`tools/verify.py`, a review-standards self-check (archive layout, JSON validity,
required fields, 14+ language coverage, version consistency, Docker-Hub-only
images, fixed tag, reserved/recommended host ports, non-root user, per-service
healthcheck/TZ/restart, data path below the application data root, never the
`/Volume*` wildcard, comment-free sequence blocks, `x-app-meta` position, no
literal secrets and the SVG size/element limits).

## Local verification

```bash
./TOSAppSelfTestingTool -c out/prometheusdocker.tar.gz   # official spec check
bash test/install-and-verify.sh                  # on-device E2E (needs root)
```

> Docker applications cannot be side-loaded through the App Center's manual
> install page (it accepts `.deb` only); the official self-testing tool's `-i`
> mode or `docker compose` are the only ways to install one for testing.

## Store submission checklist

1. Public GitHub repo (code + README only).
2. Release **tag `v3.16.0-1`**, assets `prometheusdocker.tar.gz` +
   `prometheusdocker.tar.gz.sha256` (Docker asset naming: `<app_id>.tar.gz`, **no
   platform suffix**).
3. Developer platform → Add Application: ID `prometheusdocker`, package type Docker,
   repository URL, architecture `x86_64`.
4. Version Management → Add Version `3.16.0-1` → automated validation → review.

## License / branding

Prometheus is distributed by its upstream authors under **Apache-2.0**. The container image is the official image from Docker Hub (`prom/prometheus:v3.16.0`) and is used unmodified; no upstream source code is redistributed here. This packaging is an independent community submission by Moechz and is not affiliated with the upstream project or TerraMaster.

## Limitations

- No exporters or dashboards are bundled: add scrape targets yourself and install Grafana separately.
- The default retention is 15 days and the TSDB grows with the number of series; plan disk space.
- The UI is plain HTTP; use a TLS reverse proxy before exposing it to the internet.

---

Packaged for TOS 7 by Moechz. Upstream image used unmodified from Docker Hub.
