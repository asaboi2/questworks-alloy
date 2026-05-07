#!/bin/sh
# QUE-142 — Emit a 1-minute synthetic heartbeat to stdout while alloy runs.
#
# Why: the production alert `que130-alloy-p0-forwarder-down` watches for
# absence of any log line on this service in Loki. Alloy's natural log
# cadence is the ~2h usage-report tick, so a real outage takes ~3.5h to
# page. This loop emits one line per minute so the alert can be tightened
# to a 5m absent + 2m for window (worst-case TTL = 7m).
#
# Heartbeat content is intentionally bland and uses level=info so it does
# NOT match the existing P1 rules:
#   - que130-alloy-p1-forwarder-error  (level=~error|critical|alert|emergency)
#   - que130-alloy-p1-loki-push-failed (loki.*(push|write).*(fail|error|reject)|tenant.*forbidden|429)
#
# The detection LogQL is `|~ "subsystem=heartbeat"`, so changing the
# heartbeat content must preserve that exact substring.

set -eu

heartbeat_loop() {
  while true; do
    # ISO-8601 UTC timestamp, logfmt-ish line, single line per emit.
    printf 'ts=%s level=info subsystem=heartbeat msg="alloy heartbeat ok"\n' \
      "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    sleep 60
  done
}

# Run the heartbeat in the background; alloy stays in the foreground as
# the container's main process so Render still tracks alloy health
# directly. If the container dies, both stop together.
heartbeat_loop &

exec alloy run /etc/alloy/config.alloy
