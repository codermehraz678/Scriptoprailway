# Base image
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HOSTNAME=Lightingplays
ENV PORT=7860
ENV TAILSCALE_AUTHKEY=tskey-auth-kwAXwP4tPc11CNTRL-DBiGx22nELGFMJc9tRtzKGVgXqvpQZFg

# ---- Base packages ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    git \
    sudo \
    docker.io \
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

EXPOSE 7860

# ---- Railway-ready CMD ----
USER mehraz
CMD sh -c "\
    mkdir -p /workspace/tailscale && \
    tailscaled --state=/workspace/tailscale/tailscaled.state --tun=userspace-networking & \
    tailscale up --authkey=$TAILSCALE_AUTHKEY --hostname=rail-container --accept-routes --accept-dns & \
    code-server --bind-addr 0.0.0.0:$PORT --auth password"
