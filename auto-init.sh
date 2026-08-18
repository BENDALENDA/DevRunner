#!/bin/bash
# Auto-init for devbox-mod v6 - runs in EVERY new container.
# Starts sshd + webterm-fm + logs preview URL via inner MCP.
export PAGER=cat GIT_PAGER=cat
LOG=/tmp/auto-init.log
{
  echo "=== auto-init $(date -u +%FT%TZ) ==="
  echo "host: $(hostname) kernel: $(uname -r)"
  # 1. start sshd on 3001
  mkdir -p /run/sshd
  nohup /usr/sbin/sshd -D >/tmp/sshd.log 2>&1 &
  # 2. start webterm-fm on 3002
  if [ -f /opt/webterm/start-webterm.sh ]; then
    /opt/webterm/start-webterm.sh
  fi
  sleep 2
  ss -tln | grep -E '3001|3002'
  # 3. try to get preview URL via inner MCP (port 65510)
  TASK=$(hostname)
  PREV=$(curl -s --max-time 8 -X POST "http://127.0.0.1:65510/mcp?task_id=$TASK" \
    -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" \
    -d '{"jsonrpc":"2.0","id":9,"method":"tools/call","params":{"name":"request_preview","arguments":{"port":3002}}}' 2>/dev/null \
    | grep -oE 'https://[a-zA-Z0-9.-]+' | head -1)
  echo "PREVIEW: $PREV"
  # 4. save token + preview for later
  echo "$PREV" > /tmp/preview_url
  TOK=$(cat /etc/.z-ai-config 2>/dev/null | python3 -c "import sys,json;print(json.load(sys.stdin).get('token',''))" 2>/dev/null)
  echo "gRPC token: ${TOK:0:20}..." >> "$LOG"
} >> "$LOG" 2>&1
