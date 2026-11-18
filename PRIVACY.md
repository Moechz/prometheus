# Privacy Policy — Prometheus for TerraMaster TOS (`prometheusdocker`)

**Last updated:** 18 November 2026
**Data controller / contact:** Moechz — moechz@163.com

This policy covers the TOS application package `prometheusdocker` (the “app”) — the
four-file Docker application archive — and the Prometheus instance it runs on your
TerraMaster NAS. It is linked from the package itself (the `help` field in `config.ini`,
i.e. the “Help” link of the App Center entry), from the store listing and from the
developer website (<https://www.moechz.com/privacy.html>, section 6).

## 1. Summary

- The app runs **entirely on your NAS**. The developer does not receive, collect or have
  access to any data the app processes.
- No telemetry, no analytics, no account, no licence key and no cloud service operated by
  the developer.
- The container contacts only the **scrape targets you configure** in
  `prometheus.yml`, plus Docker Hub when the image is pulled.
- Prometheus has no user accounts; its web UI has **no authentication** and speaks plain
  HTTP. Reachability of the UI is therefore a security decision you make (see §5).

## 2. What data is processed

| Container path | Stored on the NAS at | Content |
|---|---|---|
| `/prometheus` | `/Volume1/DockerAppData/prometheusdocker/data` | the time-series database: `wal/`, `chunks_head/`, persisted blocks |
| `/config` | `/Volume1/DockerAppData/prometheusdocker/config` | `prometheus.yml`, the scrape configuration you edit (seeded from the bundled default on first start) |

The stored data is:

- **Metric samples** — metric names, label values, timestamps and float values collected
  from the targets you configure. Label values are whatever your exporters publish: they
  commonly include host names, IP addresses, job and instance names, container or service
  names, mount paths and HTTP status codes.
- **The scrape configuration** — target addresses and, if you add them, the credentials
  used to reach them (`basic_auth` user/password, `bearer_token`, TLS client keys). These
  are stored **in plain text** in `config/prometheus.yml`, readable by uid 1000.
- **Runtime state** — WAL segments, a `lock` file and, on shutdown, `queries.active`.
  Query text is not stored; Prometheus keeps no query history.
- **Container logs** — everything Prometheus prints to stdout/stderr, kept by the Docker
  daemon (not by this package).

Prometheus only receives what you point it at. If one of your exporters publishes personal
data (for example a user name or an e-mail address in a label), that value is stored in the
time-series database like any other label. Nothing is uploaded to the developer.

## 3. Retention period

- **Metric data:** 15 days by default — the app starts Prometheus with
  `--storage.tsdb.retention.time=15d`, and older blocks are deleted automatically. You can
  change the retention window in the wrapper's start command (or by overriding the
  container command) if you need a shorter or longer period. The TSDB grows with the number
  of active series, so the window also bounds disk usage.
- **Scrape configuration:** kept until you edit or delete it. It is re-seeded from the
  bundled default only when the file is missing or fails `promtool` validation.
- **Container logs:** bounded by the Docker daemon's log rotation (size/age limits of your
  DockerEngine configuration), not by this package. The validation log
  (`/tmp/promtool.log`) lives inside the container and is discarded with it.
- **Website / server logs (`moechz.com`):** short-lived operational logs, not used for
  profiling and unrelated to the data the app processes.

Nothing expires because it is uploaded: there is no upload. Data stays on the NAS until
you delete it or the retention window removes the oldest blocks.

## 4. Your rights and the deletion channel

| Right | How to exercise it |
|---|---|
| **Access / export** | Copy `/Volume1/DockerAppData/prometheusdocker/` — it is the complete state of the app. Individual series can be queried and exported over the read API (`/api/v1/query`, `/api/v1/query_range`). |
| **Correct** | Edit `config/prometheus.yml` (targets, labels, retention) in the data folder and restart the app; the web UI shows the running configuration under *Status → Configuration*. |
| **Delete** | Uninstall the app with **“delete data”** in the App Center, or stop the container and remove `/Volume1/DockerAppData/prometheusdocker/`. Uninstalling without “delete data” keeps the folder. |
| **Restrict** | Stop scraping a target by removing it from `config/prometheus.yml`; the samples it already produced age out after the retention window. |
| **Assistance / complaints** | E-mail **moechz@163.com** with the subject “Prometheus data request”; a reply follows within 30 days. |

**Deletion channel.** The developer holds no copy of your data, so deletion is completed by
removing the folder on your own NAS (self-service, immediately effective), or by the e-mail
address above when the request concerns the website, the store listing or the publishing
records. Deleted data cannot be recovered by the developer, because it was never sent.

## 5. Security measures

- The container runs as **uid 1000** (`user: "1000:1000"`), never as root; it is **not**
  privileged, does **not** use host networking, does **not** mount the Docker socket and
  adds no capabilities.
- Exactly **one** port is published (host `8008` → container `9090`). Nothing else is
  exposed.
- The image is pinned to `prom/prometheus:v3.16.0` (Docker Hub, used unmodified); the
  package is rebuilt and re-released when upstream ships fixes.
- Data is confined to the application data folder and owned by the app user; the packaging
  writes nothing outside it and no secrets are baked into the package.
- **You** must protect the endpoint: Prometheus has no login and serves plain HTTP. Keep
  port 8008 on the LAN, or put it behind a TLS reverse proxy with authentication. Anyone
  who can reach the UI can read every metric and the *Status → Configuration* page, which
  displays any credentials contained in `prometheus.yml`.
- Protect the NAS share as well: the configuration file is stored in plain text, so file
  permissions are the only protection for scrape credentials.

## 6. Third-party sharing and API disclosure

The developer shares nothing and operates no server in this path. No data is sold, and
there is no advertising or analytics SDK.

| Service | Endpoint | Data sent | Destination / region |
|---|---|---|---|
| Scrape targets **you configure** | the `targets:` addresses in `prometheus.yml` (usually your LAN, e.g. exporters, `node_exporter`, NAS services) | an HTTP `GET /metrics` request; the exporter's IP and user agent are visible to that server | normally your own LAN; if you scrape an internet host, that provider's servers |
| Alerting / remote write / federation (**only if you configure them**) | the URL you enter in `alerting`, `remote_write` or the federated endpoint | the samples, alerts or metadata that feature sends | the destination you chose |
| Docker image pull | `registry-1.docker.io` (or your registry mirror) | anonymous pull request, no account data | Docker Hub, US / your mirror |
| Update check | none — Prometheus does not phone home and this package adds no update check | — | — |
| Developer website | <https://www.moechz.com/> | only if you open it in a browser | the site's hosting provider |

Disable or remove any integration you do not want in `config/prometheus.yml`; an invalid
file is rejected by `promtool` and replaced by the bundled default, which scrapes only
`localhost`.

## 7. Children

The app is a self-hosted monitoring utility and is not directed at children. It has no
accounts and no user-generated content.

## 8. Changes to this policy

Material changes are published in this file and in the repository
(<https://github.com/Moechz/prometheus>), and are reflected in the “Last updated” date
above. The policy shipped with a given package version is the one that applies to it.

## 9. Contact

Moechz — **moechz@163.com** — <https://www.moechz.com/privacy.html>

Package repository: <https://github.com/Moechz/prometheus> ·
Upstream project: <https://github.com/prometheus/prometheus>
