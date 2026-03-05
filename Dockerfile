FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HOSTNAME=mehraz
ENV PORT=7860

# ---- Base packages ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    git \
    sudo \
    htop \
    btop \
    neovim \
    lsof \
    qemu-system \
    cloud-image-utils \
    nodejs \
    npm \
    procps \
    tini \
    && rm -rf /var/lib/apt/lists/*

# ---- Create user ----
RUN useradd -m -s /bin/bash mehraz \
    && echo "mehraz:mehraz5566" | chpasswd \
    && usermod -aG sudo mehraz

# ---- Install code-server ----
RUN curl -fsSL https://code-server.dev/install.sh | sh

# ---- Install Claude Code CLI ----
RUN npm install -g @anthropic-ai/claude-code

# ---- Workspace ----
WORKDIR /workspace

EXPOSE $PORT

# ---- Railway-ready CMD ----
USER mehraz
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD exec code-server --bind-addr 0.0.0.0:$PORT --auth password
