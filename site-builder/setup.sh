#!/usr/bin/env bash
set -euo pipefail

# ghsetup setup — One-time installer.
# Installs gh CLI and git if missing, then runs device-flow authentication.
# Designed to be run once per machine. Safe to re-run.

echo "=== ghsetup setup ==="
echo ""

# ---------------------------------------------------------------------------
# Detect OS
# ---------------------------------------------------------------------------

OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="mac"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS="linux"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
  OS="windows"
fi

# ---------------------------------------------------------------------------
# Install git if missing
# ---------------------------------------------------------------------------

if ! command -v git &>/dev/null; then
  echo "[1/3] Installing git..."
  if [[ "$OS" == "mac" ]]; then
    xcode-select --install 2>/dev/null || true
    echo "  Git should be available after Xcode tools install. Re-run this script after."
    exit 1
  elif [[ "$OS" == "linux" ]]; then
    if command -v apt-get &>/dev/null; then
      sudo apt-get update -qq && sudo apt-get install -y -qq git
    elif command -v yum &>/dev/null; then
      sudo yum install -y git
    elif command -v dnf &>/dev/null; then
      sudo dnf install -y git
    else
      echo "  ERROR: Cannot install git automatically. Please install it manually."
      exit 1
    fi
  else
    echo "  ERROR: Please install git manually from https://git-scm.com"
    exit 1
  fi
else
  echo "[1/3] git is already installed: $(git --version)"
fi

# ---------------------------------------------------------------------------
# Install jq if missing
# ---------------------------------------------------------------------------

if ! command -v jq &>/dev/null; then
  echo "[2/3] Installing jq..."
  if [[ "$OS" == "mac" ]]; then
    if command -v brew &>/dev/null; then
      brew install -q jq
    else
      echo "  Installing jq via curl..."
      curl -sL https://github.com/jqlang/jq/releases/latest/download/jq-macos-arm64 -o /usr/local/bin/jq 2>/dev/null \
        || curl -sL https://github.com/jqlang/jq/releases/latest/download/jq-macos-amd64 -o /usr/local/bin/jq
      chmod +x /usr/local/bin/jq
    fi
  elif [[ "$OS" == "linux" ]]; then
    if command -v apt-get &>/dev/null; then
      sudo apt-get install -y -qq jq
    elif command -v yum &>/dev/null; then
      sudo yum install -y jq
    elif command -v dnf &>/dev/null; then
      sudo dnf install -y jq
    fi
  fi
else
  echo "[2/3] jq is already installed."
fi

# ---------------------------------------------------------------------------
# Install gh CLI if missing
# ---------------------------------------------------------------------------

if ! command -v gh &>/dev/null; then
  echo "[3/3] Installing GitHub CLI..."
  if [[ "$OS" == "mac" ]]; then
    if command -v brew &>/dev/null; then
      brew install gh
    else
      echo "  Installing via official script..."
      curl -sL https://cli.github.com/packages/install.sh | bash
    fi
  elif [[ "$OS" == "linux" ]]; then
    # Official install method for Debian/Ubuntu and others
    if command -v apt-get &>/dev/null; then
      (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y))
      sudo mkdir -p -m 755 /etc/apt/keyrings
      out=$(mktemp)
      wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
      sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
      sudo apt update -qq
      sudo apt install gh -y -qq
    elif command -v dnf &>/dev/null; then
      sudo dnf install 'dnf-command(config-manager)' -y
      sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
      sudo dnf install gh -y
    elif command -v yum &>/dev/null; then
      sudo yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
      sudo yum install gh -y
    else
      echo "  ERROR: Cannot install gh automatically. See https://cli.github.com"
      exit 1
    fi
  else
    echo "  ERROR: Please install gh manually from https://cli.github.com"
    exit 1
  fi
else
  echo "[3/3] GitHub CLI is already installed: $(gh --version | head -1)"
fi

# ---------------------------------------------------------------------------
# Authenticate
# ---------------------------------------------------------------------------

echo ""
if gh auth status &>/dev/null 2>&1; then
  CURRENT_USER=$(gh api user --jq '.login' 2>/dev/null || echo "unknown")
  echo "Already authenticated as: $CURRENT_USER"
  echo ""
  echo "Setup complete. You're ready to go."
else
  echo "Now let's connect your GitHub account."
  echo "A browser window will open — log in and authorize the app."
  echo ""
  gh auth login --web --git-protocol https
  echo ""
  CURRENT_USER=$(gh api user --jq '.login' 2>/dev/null || echo "unknown")
  echo "Authenticated as: $CURRENT_USER"
  echo ""
  echo "Setup complete. You're ready to go."
fi
