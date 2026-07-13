FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install essential dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    build-essential \
    unzip \
    ripgrep \
    fd-find \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    # Emacs runtime dependencies
    emacs-nox \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user and setup home directory
RUN useradd -m -s /bin/bash emacsuser
USER emacsuser
ENV HOME=/home/emacsuser
WORKDIR /workspace

# Copy the Emacs configuration files
RUN mkdir -p $HOME/.config/emacs
COPY --chown=emacsuser:emacsuser . $HOME/.config/emacs

# Pre-install packages by running Emacs in batch mode
# This will trigger package.el to download all use-package declarations
RUN emacs --init-directory "$HOME/.config/emacs" \
    --batch \
    --eval "(progn (load (expand-file-name \"early-init.el\" user-emacs-directory)) (load (expand-file-name \"init.el\" user-emacs-directory)))" \
    2>&1 || true

# Run again to install any remaining packages that depend on previously installed ones
RUN emacs --init-directory "$HOME/.config/emacs" \
    --batch \
    --eval "(progn (load (expand-file-name \"early-init.el\" user-emacs-directory)) (load (expand-file-name \"init.el\" user-emacs-directory)))" \
    2>&1 || true

# Set up entrypoint
ENTRYPOINT ["emacs", "-nw"]
