# Base image
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HOSTNAME=Lightingplays
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
    iproute2 \
    iptables \
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

# ---- Install Tailscale ----
RUN curl -fsSL https://tailscale.com/install.sh | sh

# ---- Workspace ----
WORKDIR /workspace

EXPOSE $PORT

# ---- Railway-ready CMD ----
USER mehraz
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD sh -c "\
    mkdir -p /workspace/tailscale && \
    tailscaled --state=/workspace/tailscale/tailscaled.state --tun=userspace-networking & \
    tailscale up --authkey=$TAILSCALE_AUTHKEY --hostname=rail-container --accept-routes --accept-dns & \
    exec code-server --bind-addr 0.0.0.0:$PORT --auth password"
