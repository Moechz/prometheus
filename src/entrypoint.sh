#!/bin/sh
# ===========================================================================
# Prometheus entrypoint for a non-root container (TOS 7 requirement).
#
# The upstream image runs as `nobody` and keeps its configuration inside
# /etc/prometheus, which a container cannot write. This wrapper:
#   1. seeds an editable prometheus.yml into the mounted config folder once,
#   2. validates it with promtool,
#   3. falls back to the bundled default when the file is unusable (a typo must
#      not turn into a restart loop),
#   4. starts Prometheus as uid 1000 with the TSDB in the mounted data folder.
# ===========================================================================
set -e
set -u

CONF_DIR=/config
CONF="$CONF_DIR/prometheus.yml"
DATA_DIR=/prometheus
DEFAULT=/etc/prometheus/prometheus.yml

mkdir -p "$CONF_DIR" "$DATA_DIR" 2>/dev/null || true

if [ ! -s "$CONF" ]; then
  cp "$DEFAULT" "$CONF"
  echo "prometheus: seeded a default $CONF"
fi

if ! /bin/promtool check config "$CONF" >/tmp/promtool.log 2>&1; then
  echo "prometheus: $CONF is not valid - restoring the bundled default"
  sed -n '1,5p' /tmp/promtool.log
  cp "$DEFAULT" "$CONF"
fi

exec /bin/prometheus \
  --config.file="$CONF" \
  --storage.tsdb.path="$DATA_DIR" \
  --web.listen-address=:9090
