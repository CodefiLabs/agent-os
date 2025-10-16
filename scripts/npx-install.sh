#!/bin/bash

# =============================================================================
# Agent OS NPX Installation Script
# Installs Agent OS to ~/.agent-os from npm package or GitHub fork
# =============================================================================

set -e

# Colors
BLUE='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() { echo -e "${BLUE}$1${NC}"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

BASE_DIR="$HOME/.agent-os"
REPO_URL="${AGENT_OS_REPO:-https://github.com/CodefiLabs/agent-os}"
TEMP_DIR=$(mktemp -d)

# Cleanup on exit
cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

# -----------------------------------------------------------------------------
# Installation Functions
# -----------------------------------------------------------------------------

detect_installation_source() {
    local script_dir="$(cd "$(dirname "$0")" && pwd)"

    # Check if we're being run from npx (npm temp directory)
    if [[ "$script_dir" == *"/node_modules/"* ]] || [[ "$script_dir" == *"/_npx/"* ]]; then
        # NPX installation - check if it has .git (GitHub install)
        if [[ -d "$script_dir/../.git" ]]; then
            echo "github"
        else
            echo "npm"
        fi
    # Check if AGENT_OS_REPO environment variable is set
    elif [[ -n "$AGENT_OS_REPO" ]]; then
        echo "github"
    # Check if we're in a git clone (local development)
    elif [[ -d "$script_dir/../.git" ]]; then
        echo "local"
    else
        # Default to npm for npx installations
        echo "npm"
    fi
}

install_from_npm() {
    local source="${1:-npm package}"
    print_status "Installing from $source..."

    # The package is already downloaded by npx
    # Copy everything to ~/.agent-os
    local package_dir="$(cd "$(dirname "$0")/.." && pwd)"

    if [[ -d "$BASE_DIR" ]]; then
        if [[ -t 0 ]]; then
            print_warning "Existing installation found at $BASE_DIR"
            read -p "Overwrite? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_status "Installation cancelled"
                exit 0
            fi
        fi
        rm -rf "$BASE_DIR"
    fi

    mkdir -p "$BASE_DIR"

    # Copy all files except node_modules and package files
    if command -v rsync &> /dev/null; then
        rsync -av \
            --exclude='node_modules' \
            --exclude='package.json' \
            --exclude='package-lock.json' \
            --exclude='.git' \
            --exclude='.github' \
            "$package_dir/" "$BASE_DIR/" > /dev/null
    else
        # Fallback to cp if rsync not available
        cp -R "$package_dir"/* "$BASE_DIR/" 2>/dev/null || true
    fi

    # Make scripts executable
    chmod +x "$BASE_DIR/scripts/"*.sh 2>/dev/null || true
    chmod +x "$BASE_DIR/scripts/agent-os" 2>/dev/null || true

    print_success "Installed to $BASE_DIR"
}

install_from_github() {
    print_status "Installing from GitHub: $REPO_URL"

    # Clone the repository
    git clone "$REPO_URL" "$TEMP_DIR/agent-os" > /dev/null 2>&1

    if [[ -d "$BASE_DIR" ]]; then
        print_warning "Existing installation found at $BASE_DIR"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Installation cancelled"
            exit 0
        fi
        rm -rf "$BASE_DIR"
    fi

    mkdir -p "$BASE_DIR"

    # Copy files
    rsync -av \
        --exclude='.git' \
        --exclude='.github' \
        --exclude='node_modules' \
        "$TEMP_DIR/agent-os/" "$BASE_DIR/" > /dev/null

    # Make scripts executable
    chmod +x "$BASE_DIR/scripts/"*.sh 2>/dev/null || true
    chmod +x "$BASE_DIR/scripts/agent-os" 2>/dev/null || true

    print_success "Installed from $REPO_URL to $BASE_DIR"
}

install_from_local() {
    print_status "Installing from local repository..."

    local repo_dir="$(cd "$(dirname "$0")/.." && pwd)"

    if [[ -d "$BASE_DIR" ]]; then
        print_warning "Existing installation found at $BASE_DIR"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Installation cancelled"
            exit 0
        fi
        rm -rf "$BASE_DIR"
    fi

    mkdir -p "$BASE_DIR"

    # Copy files
    rsync -av \
        --exclude='.git' \
        --exclude='.github' \
        --exclude='node_modules' \
        "$repo_dir/" "$BASE_DIR/" > /dev/null

    # Make scripts executable
    chmod +x "$BASE_DIR/scripts/"*.sh 2>/dev/null || true
    chmod +x "$BASE_DIR/scripts/agent-os" 2>/dev/null || true

    print_success "Installed from local repository to $BASE_DIR"
}

offer_global_cli_install() {
    echo ""
    read -p "Install 'agent-os' command globally? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        if [[ -f "$BASE_DIR/scripts/install-global.sh" ]]; then
            bash "$BASE_DIR/scripts/install-global.sh"
        fi
    fi
}

# -----------------------------------------------------------------------------
# Main Installation
# -----------------------------------------------------------------------------

main() {
    echo ""
    print_status "Agent OS NPX Installation"
    echo ""

    # Detect installation source
    local source=$(detect_installation_source)

    case $source in
        npm)
            install_from_npm "npm package"
            ;;
        github)
            # When using npx github:user/repo, it clones to a temp dir
            # We can use install_from_npm since files are already there
            install_from_npm "GitHub repository"
            ;;
        local)
            install_from_local
            ;;
        *)
            print_error "Unable to determine installation source"
            exit 1
            ;;
    esac

    echo ""
    print_success "Agent OS base installation complete!"

    # Offer global CLI installation
    if [[ -t 0 ]]; then
        offer_global_cli_install
    fi

    echo ""
    print_status "Next steps:"
    echo ""
    echo "1. Navigate to a project directory"
    echo "   cd path/to/project"
    echo ""
    echo "2. Install Agent OS in your project"
    echo "   agent-os install"
    echo "   (or ~/.agent-os/scripts/project-install.sh if CLI not installed globally)"
    echo ""
}

# Only run if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
