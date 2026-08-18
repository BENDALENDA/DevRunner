#!/bin/bash
# start webterm-fm on 3002 (best-effort; needs node_modules in /opt/webterm)
cd /opt/webterm
if [ ! -d node_modules ]; then
  npm install express ws node-pty --prefix /opt/webterm >/tmp/webterm-install.log 2>&1
fi
nohup node server.js >/tmp/webterm.log 2>&1 &
disown 2>/dev/null
