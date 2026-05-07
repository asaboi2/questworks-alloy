FROM grafana/alloy:latest
COPY config.alloy /etc/alloy/config.alloy
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
# QUE-142: entrypoint wraps `alloy run` with a 1-min synthetic heartbeat
# emitted to stdout so Render Log Streams forwards it to Loki. See
# entrypoint.sh for the full rationale.
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
