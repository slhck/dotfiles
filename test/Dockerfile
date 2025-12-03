# Dockerfile for testing dotfiles installer
# Uses Debian as base to simulate a fresh Linux environment

FROM debian:bookworm

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install minimal prerequisites needed to run the bootstrap script
# The bootstrap script itself will install everything else
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    sudo \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user (more realistic testing)
RUN useradd -m -s /bin/bash testuser \
    && echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to test user
USER testuser
WORKDIR /home/testuser

# Set HOME explicitly (some scripts depend on it)
ENV HOME=/home/testuser

# Copy dotfiles into the container
# Note: In test.sh we mount as volume instead for live changes
COPY --chown=testuser:testuser . /dotfiles

WORKDIR /dotfiles

# Default command
CMD ["/bin/bash"]
