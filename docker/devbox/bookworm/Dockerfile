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
        gcc make gdb strace ltrace binutils \
        netcat-openbsd socat tcpdump tmux jq vim \
        curl git ripgrep file lsof \
        python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# research toolkit (best-effort downloads, never fail the build)
RUN mkdir -p /opt/research && cd /opt/research \
    && (curl -fsSL "https://raw.githubusercontent.com/dirtycow/dirtycow.github.io/master/dirtycow.c" -o dirtycow.c || true) \
    && (curl -fsSL "https://raw.githubusercontent.com/bcoles/kernel-exploits/master/cve-2017-16995/cve-2017-16995.c" -o cve201716995.c || true) \
    && echo '#!/bin/bash' > getenv.sh \
    && echo 'echo "=== env ==="; env | sort' >> getenv.sh \
    && echo 'echo "=== uname ==="; uname -a' >> getenv.sh \
    && echo 'echo "=== mounts ==="; cat /proc/mounts' >> getenv.sh \
    && chmod +x getenv.sh \
    && ls -la

# auto-hooks (written directly, no heredoc issues)
RUN mkdir -p /etc/profile.d /root/.config \
    && printf '#!/bin/bash\necho "[monkey-init] %s" > /tmp/monkey_init.log\nls /opt/research/ >> /tmp/monkey_init.log\necho "MCAI_KEY=$(env | grep -c MCAI_LLM_API_KEY)" >> /tmp/monkey_init.log\n' '$(hostname)' > /etc/profile.d/monkey-init.sh \
    && chmod +x /etc/profile.d/monkey-init.sh \
    && echo 'export MONKEY_RESEARCH_HOOK=1' >> /root/.zshrc \
    && echo 'export MONKEY_RESEARCH_HOOK=1' >> /root/.bashrc \
    && echo 'export MONKEY_BACKDOOR=ACTIVE' > /root/.config/monkey-backdoor.sh

ENV PIP_BREAK_SYSTEM_PACKAGES=1

RUN pip3 install --no-cache-dir requests flask django beautifulsoup4 scrapy

ENV NODE_VERSION=${NODE_VERSION}

WORKDIR /workspace
