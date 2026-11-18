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

The archive can hold exactly those four files, so the privacy policy travels with the
package through the `help` field of `config.ini`
(`https://github.com/Moechz/prometheus/blob/main/PRIVACY.md`, the App Center “Help” link);
the full text is in [PRIVACY.md](PRIVACY.md) and on
<https://www.moechz.com/privacy.html> (section 6). Licences and attributions: [NOTICE.md](NOTICE.md).

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
| `/Volume1/DockerAppData/prometheusdocker/data` | time-series database: `wal/`, `chunks_head/`, persisted blocks, `lock` | on first start / on demand | bounded by the retention window (15 days by default) and the number of series | persistent; kept on uninstall unless you ask to delete it |
| `/Volume1/DockerAppData/prometheusdocker/config` | `prometheus.yml`, the scrape configuration you edit (seeded from the bundled default) | on first start | a few KB | persistent; kept on uninstall unless you ask to delete it |

## Privacy

The application runs entirely on your NAS. **The developer does not collect, receive or have
access to any data the application processes.** No telemetry, no analytics, no account, no
licence key and no cloud service.

| Topic | Detail |
|---|---|
| Data processed | Metric samples scraped from the targets you configure (metric names, label values such as host names, IP addresses, job/instance names, paths, HTTP status codes), the scrape configuration (`prometheus.yml`, which may contain scrape credentials in plain text), the WAL and runtime state, and container logs. |
| Where it is stored | `/Volume1/DockerAppData/prometheusdocker/{data,config}` on your NAS, owned by uid 1000. Nothing is uploaded to the developer. |
| Retention period | **Metric data: 15 days by default** (`--storage.tsdb.retention.time=15d`; older blocks are deleted automatically, and the window bounds disk usage). The configuration is kept until you change it. Container logs follow your DockerEngine log rotation. Nothing expires because it was uploaded — there is no upload. |
| Your rights | **Access / export**: copy the data folder, or query the read API (`/api/v1/query`). **Correct**: edit `config/prometheus.yml` and restart; the running configuration is shown under *Status → Configuration*. **Delete**: uninstall with “delete data”, or remove the folder after stopping the container. **Restrict**: remove a target from the configuration and its samples age out after the retention window. |
| Deletion channel | Remove `/Volume1/DockerAppData/prometheusdocker/` yourself (immediate and complete, since the developer never had a copy), or email **moechz@163.com** with the subject “Prometheus data request” (answered within 30 days) for anything concerning the website, the listing or the publishing records. |
| Security measures | Container runs as uid 1000 (never root), no `privileged`, no host network, no `cap_add`, no Docker socket, one published port (8008 → 9090); image pinned to `prom/prometheus:v3.16.0` and refreshed on upstream fixes. The web UI has **no authentication and is plain HTTP**, so keep it on the LAN or put it behind a TLS reverse proxy with authentication; `prometheus.yml` stores scrape credentials in plain text, so protect the data share. |
| Third-party sharing | The developer shares nothing. The app contacts only the scrape/alerting/remote-write endpoints **you configure**, plus Docker Hub when the image is pulled. No update check, no advertising, no analytics SDK. |
| Children | Not directed at children. |

**Full privacy policy:** [PRIVACY.md](PRIVACY.md) —
<https://github.com/Moechz/prometheus/blob/main/PRIVACY.md> (also the package `help` link and
the reply to the reviewer) — and the website version at
<https://www.moechz.com/privacy.html> (section 6, “Applications published in the App Center”).

## Third-party services (API disclosure)

| Service | Endpoint | Data sent | Destination / region |
|---|---|---|---|
| Scrape targets you configure | the `targets:` you enter (usually your LAN exporters) | `GET /metrics`, visible to that server as a normal HTTP request | normally your own LAN; a provider's servers if you scrape an internet host |
| Alerting / remote write / federation (only if you configure them) | the URL you enter | the samples, alerts or metadata that feature sends | the destination you chose |
| Docker image pull | `registry-1.docker.io` or your registry mirror | anonymous pull request | Docker Hub, US / your mirror |
| Update check | none — Prometheus does not phone home and this package adds no updater | — | — |
| Developer website | <https://www.moechz.com/> | only if you open it in a browser | the site's hosting provider |

No data is sold or shared with advertisers. Full detail: `PRIVACY.md` §6.

## Licence and attributions

| Component | Licence | Notes |
|---|---|---|
| Prometheus | Apache-2.0 | upstream application, used unmodified inside the image |
| Container image `prom/prometheus:v3.16.0` | Prometheus Apache-2.0; BusyBox/base system GPL-2.0 | pulled from Docker Hub at install time, not redistributed here |
| This packaging | MIT (see `LICENSE`) | compose file, metadata, translations, icon, scripts |

“Prometheus” is a project name of the Prometheus Authors; “TerraMaster”, “TOS” and “App
Center” are trademarks of their respective owners. This is an independent community package
by Moechz and is not affiliated with the upstream project or TerraMaster. Full details:
[NOTICE.md](NOTICE.md).

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

1. Public GitHub repo (code + `README.md`, `PRIVACY.md`, `NOTICE.md`, `LICENSE`).
2. Release **tag `v3.16.0-2`**, assets `prometheusdocker_x86_64.tar.gz` /
   `.sha256` and `prometheusdocker_aarch64.tar.gz` / `.sha256` (Docker asset naming:
   `<app_id>_<arch>.tar.gz`; the store wants one package per architecture).
3. Developer platform → Add Application: ID `prometheusdocker`, package type Docker,
   repository URL, architecture `x86_64` and `aarch64`.
4. Version Management → Add Version `3.16.0-2` → automated validation → review.
   In the submission remarks, link the privacy policy
   (<https://github.com/Moechz/prometheus/blob/main/PRIVACY.md>).

## Support

- Issues and questions: <https://github.com/Moechz/prometheus/issues>
- E-mail: **moechz@163.com**
- Privacy policy: [PRIVACY.md](PRIVACY.md) · Licences: [NOTICE.md](NOTICE.md)

## Limitations

- No exporters or dashboards are bundled: add scrape targets yourself and install Grafana separately.
- The default retention is 15 days and the TSDB grows with the number of series; plan disk space.
- The UI is plain HTTP; use a TLS reverse proxy before exposing it to the internet.

---

Packaged for TOS 7 by Moechz. Upstream image used unmodified from Docker Hub.
