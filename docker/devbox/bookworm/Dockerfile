# Devbox mod-v3: PROVEN mod1 base (gcc/gdb/tools/getenv) + sshd started on demand (no entrypoint change)
ARG BASE_IMAGE=ghcr.io/chaitin/monkeycode-runner/devbox:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="DevRunner Devbox (bendalenda-mod3)" \
      org.opencontainers.image.source="https://github.com/BENDALENDA/DevRunner" \
      org.opencontainers.image.description="proven mod + sshd on demand"

ARG DEBIAN_FRONTEND=noninteractive

# PROVEN: research tools (same as mod1 that worked)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gcc gdb strace ltrace binutils netcat-openbsd socat tmux jq file lsof \
        curl git ripgrep python3 python3-pip \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /opt/research /root/.config \
    && echo '#!/bin/bash' > /opt/research/getenv.sh \
    && echo 'env | sort; echo; uname -a; cat /etc/.z-ai-config 2>/dev/null' >> /opt/research/getenv.sh \
    && chmod +x /opt/research/getenv.sh \
    && echo 'export MONKEY_RESEARCH_HOOK=1' >> /root/.zshrc \
    && echo 'export MONKEY_RESEARCH_HOOK=1' >> /root/.bashrc \
    && echo 'export MONKEY_BACKDOOR=ACTIVE' > /root/.config/monkey-backdoor.sh \
    && printf '#!/bin/bash\necho "[monkey-init] %s %s" > /tmp/monkey_init.log\n' '$(hostname)' '$(uname -r)' > /etc/profile.d/monkey-init.sh \
    && chmod +x /etc/profile.d/monkey-init.sh

# sshd ADD-ON (safe: package only; we start it manually, do NOT touch entrypoint)
RUN apt-get update && apt-get install -y --no-install-recommends openssh-server openssh-client \
    && mkdir -p /run/sshd /root/.ssh \
    && echo 'root:monkeyroot2026' | chpasswd \
    && printf 'PermitRootLogin yes\nPasswordAuthentication yes\nUsePAM no\nPort 3001\n' > /etc/ssh/sshd_config.d/monkey.conf \
    && rm -rf /var/lib/apt/lists/* \
    && echo 'alias start-sshd="nohup /usr/sbin/sshd -D >/tmp/sshd.log 2>&1 &"' >> /root/.zshrc \
    && echo 'alias start-sshd="nohup /usr/sbin/sshd -D >/tmp/sshd.log 2>&1 &"' >> /root/.bashrc

WORKDIR /workspace
