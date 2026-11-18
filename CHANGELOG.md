# Changelog

All notable user-visible changes to the Prometheus TOS application package.

## 3.16.0-2 — 2026-11-18

Review remediation for the listing report of 2026-11-17 (items C3, C4, C5, F1, F2, F6, F7,
T1). The upstream image is unchanged: `prom/prometheus:v3.16.0` is still the current
Prometheus release.

### Added
- `PRIVACY.md` — a complete application privacy policy covering what the app processes
  (metric samples, label values, the scrape configuration and any credentials in it),
  the retention period (15 days of metric data by default, configuration kept until
  changed), user rights (access/export, correct, delete, restrict), the deletion channel
  (remove the data folder, or e-mail `moechz@163.com`), the security measures and the
  third-party/API disclosure (only the endpoints the user configures, plus the Docker Hub
  pull).
- `NOTICE.md` — licence chain and attributions (Prometheus Apache-2.0, the image pulled
  from Docker Hub, this packaging MIT, trademark and icon notes).
- README sections `## Privacy`, `## Third-party services`, `## Licence and attributions`
  and `## Support`.
- `docs/REVIEW-REPLY-3.16.0-2.md` — the item-by-item reply sent with the resubmission.

### Changed
- The package `help` field (`config.ini`) now points at the privacy policy
  (`https://github.com/Moechz/prometheus/blob/main/PRIVACY.md`) instead of the issue
  tracker, so the policy ships with the package and is reachable from the App Center
  entry. Support and issue links stay in the README.
- The release notes (all 23 languages, English/zh-cn/zh-hk written out) mention the
  privacy policy and the re-verification.
- `tosapp.json` gained `config_file: config/prometheus.yml`, so the E2E script now also
  tests that a corrupted `prometheus.yml` is replaced by the bundled default instead of
  leaving the container down.

### Verified
- Official `TOSAppSelfTestingTool -c`: passes for both architectures.
- On-device E2E (TOS 7, official installer `-i`, 17 checks): container healthy, uid 1000,
  port 8008 published and listening, UI and `/-/healthy` answer, restart and reinstall
  keep the data, and an invalid configuration falls back instead of crash-looping.

## 3.16.0-1 — 2026-11-14

### Added
- First release. Prometheus (`prom/prometheus:v3.16.0`, Docker Hub official image, unmodified)
  packaged as a TOS 7 Docker application, published on port 8008 and running
  as a non-root user (1000:1000).
- Persistent data is kept under `/Volume1/DockerAppData/prometheusdocker/`.
