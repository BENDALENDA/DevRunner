#!/bin/bash
# full-recon.sh: Comprehensive container security reconnaissance
# Output: /tmp/full-recon.txt
OUT=/tmp/full-recon.txt
echo "=== Full Security Recon $(date -u +%FT%TZ) ===" > "$OUT"

{
  echo "--- Kernel Info ---"
  uname -a
  cat /proc/version
  echo

  echo "--- Capabilities (PID 1) ---"
  cat /proc/1/status 2>/dev/null | grep -iE 'Cap|Seccomp'
  echo

  echo "--- Capabilities (self) ---"
  cat /proc/self/status 2>/dev/null | grep -iE 'Cap|Seccomp'
  echo

  echo "--- Effective Capabilities ---"
  if command -v capsh &>/dev/null; then capsh --print 2>/dev/null; else grep CapEff /proc/self/status; fi
  echo

  echo "--- Seccomp ---"
  cat /proc/self/status | grep Seccomp
  echo

  echo "--- AppArmor/SELinux ---"
  cat /proc/self/attr/current 2>/dev/null
  aa-status 2>/dev/null || echo 'aa-status: not available'
  getenforce 2>/dev/null || echo 'SELinux: not available'
  echo

  echo "--- cgroup ---"
  cat /proc/self/cgroup
  echo

  echo "--- Mounts ---"
  mount | grep -vE 'proc|sysfs|cgroup'
  echo

  echo "--- Sockets ---"
  for s in /var/run/docker.sock /run/docker.sock /run/containerd/containerd.sock /run/containerd/containerd.sock; do
    [ -S "$s" ] && echo "FOUND: $s" && ls -la "$s"
  done
  echo

  echo "--- Runtime Versions ---"
  runc --version 2>/dev/null || echo 'runc: not found'
  docker --version 2>/dev/null || echo 'docker: not found'
  containerd --version 2>/dev/null || echo 'containerd: not found'
  echo

  echo "--- CVE-2025-31133 Check (maskedPaths TOCTOU) ---"
  RUNC_V=$(runc --version 2>/dev/null | head -1)
  if echo "$RUNC_V" | grep -qE 'runc v1\.(0|1)\.[0-9]|runc v1\.2\.[0-3]'; then
    echo "VULNERABLE: $RUNC_V (patched in 1.2.5, 1.1.14)"
  else
    echo "OK (or runc not found): $RUNC_V"
  fi
  echo

  echo "--- CVE-2024-21626 Check (WORKDIR fd leak) ---"
  if [ -d /proc/self/fd ]; then
    for fd in /proc/self/fd/*; do
      target=$(readlink "$fd" 2>/dev/null)
      echo "$fd -> $target" | grep -iE 'cgroup|docker' && echo "INTERESTING FD LEAK CANDIDATE"
    done 2>/dev/null
    echo "scan complete"
  else
    echo 'fd scan: not available'
  fi
  echo

  echo "--- Kernel Symbols Access ---"
  ls -la /proc/kallsyms 2>/dev/null | awk '{print $1,$3,$4,$NF}'
  echo "kcore: $(ls -la /proc/kcore 2>/dev/null | awk '{print $1,$3,$4,$NF}')"
  echo

  echo "--- SCTP Module ---"
  lsmod | grep sctp
  cat /proc/sys/net/sctp 2>/dev/null | head -5
  echo

  echo "--- Network ---"
  ip addr show 2>/dev/null || ifconfig 2>/dev/null
  ip route show 2>/dev/null || route -n 2>/dev/null
  echo
  echo "--- DNS ---"
  cat /etc/resolv.conf
  echo
  echo "--- Host Port Scan ---"
  for hp in 192.168.16.1:2375 192.168.16.1:81 192.168.16.1:65510 192.168.16.1:80 192.168.16.1:443 \
             172.17.0.1:2375 172.17.0.1:80 10.0.0.1:80 10.0.0.1:2375; do
    timeout 1 bash -c "echo > /dev/tcp/${hp%:*}/${hp#*:}" 2>/dev/null && echo "OPEN: $hp"
  done
  echo
  echo "--- Listening Ports ---"
  ss -tlnp
  echo
  echo "--- Disk ---"
  df -h /
  echo
  echo "--- Environment (tokens redacted) ---"
  env | grep -vE 'agent_access_[a-f0-9-]+|API_KEY|TOKEN|SECRET|PASSWORD' | sort
  echo "TOKENS: $(env | grep -cE 'agent_access_|API_KEY|TOKEN') env vars with potential tokens"
  echo
  echo "--- Process List ---"
  ps auxf 2>/dev/null | head -30
  echo
} >> "$OUT" 2>&1

echo "Recon saved to $OUT ($(wc -l < $OUT) lines)"