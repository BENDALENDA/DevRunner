# Devbox minimal mod - just add research tools, keep everything else identical
ARG BASE_IMAGE=ghcr.io/chaitin/monkeycode-runner/devbox:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="DevRunner Devbox (bendalenda-minmod)" \
      org.opencontainers.image.source="https://github.com/BENDALENDA/DevRunner" \
      org.opencontainers.image.description="devbox + research tools"

ARG DEBIAN_FRONTEND=noninteractive

# add small tools only (best-effort)
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc gdb strace netcat-openbsd socat tmux jq file lsof \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /opt/research \
    && echo '#!/bin/bash' > /opt/research/getenv.sh \
    && echo 'env | sort; echo; uname -a; cat /etc/.z-ai-config 2>/dev/null' >> /opt/research/getenv.sh \
    && chmod +x /opt/research/getenv.sh \
    && printf '#!/bin/bash\necho "[monkey-init] %s %s" > /tmp/monkey_init.log\n' '$(hostname)' '$(uname -r)' > /etc/profile.d/monkey-init.sh \
    && chmod +x /etc/profile.d/monkey-init.sh \
    && echo 'export MONKEY_RESEARCH_HOOK=1' >> /root/.zshrc

WORKDIR /workspace
