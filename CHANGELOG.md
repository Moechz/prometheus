# Changelog

All notable user-visible changes to the Prometheus TOS application package.

## 3.16.0-1 — 2026-11-14

### Added
- First release. Prometheus (`prom/prometheus:v3.16.0`, Docker Hub official image, unmodified)
  packaged as a TOS 7 Docker application, published on port 8008 and running
  as a non-root user (1000:1000).
- Persistent data is kept under `/Volume1/DockerAppData/prometheusdocker/`.
