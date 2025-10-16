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

    # Find the actual package directory by looking for critical files
    # Start from the script's directory
    local script_dir="$(cd "$(dirname "$0")" && pwd)"
    local package_dir=""

    # First, check if the parent of scripts/ has everything we need
    local potential_root="$(dirname "$script_dir")"

    if [[ -f "$potential_root/config.yml" ]] && \
       [[ -d "$potential_root/profiles" ]] && \
       [[ -f "$script_dir/install-global.sh" ]]; then
        # Perfect - we found it
        package_dir="$potential_root"
    else
        # Search upward for the repository root
        local search_dir="$potential_root"
        local max_depth=5
        local depth=0

        while [[ $depth -lt $max_depth && "$search_dir" != "/" ]]; do
            if [[ -f "$search_dir/config.yml" ]] && \
               [[ -d "$search_dir/scripts" ]] && \
               [[ -d "$search_dir/profiles" ]] && \
               [[ -f "$search_dir/scripts/install-global.sh" ]]; then
                package_dir="$search_dir"
                break
            fi

            search_dir="$(dirname "$search_dir")"
            ((depth++))
        done
    fi

    # Final check - if still not found, exit with error
    if [[ -z "$package_dir" ]] || [[ ! -f "$package_dir/scripts/install-global.sh" ]]; then
        print_error "Could not locate Agent OS repository files"
        print_status "Script location: $script_dir"
        print_status "Searched from: $potential_root"

        # Show what we can see
        print_status "Contents of script directory:"
        ls -la "$script_dir" 2>/dev/null | head -10

        exit 1
    fi

    print_status "Source: $package_dir"

    if [[ -d "$BASE_DIR" ]]; then
        if [[ -t 0 ]]; then
            print_warning "Existing installation found at $BASE_DIR"
            read -p "Overwrite? (y/N): " -r
            echo
            # Default to "n" if empty
            REPLY=${REPLY:-n}
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_status "Installation cancelled"
                exit 0
            fi
        fi
        rm -rf "$BASE_DIR"
    fi

    mkdir -p "$BASE_DIR"

    # Copy all files - simple and reliable
    if command -v rsync &> /dev/null; then
        # Use rsync for reliable copying
        rsync -a --quiet \
            --exclude='node_modules' \
            --exclude='package.json' \
            --exclude='package-lock.json' \
            --exclude='.git' \
            --exclude='.github' \
            "$package_dir/" "$BASE_DIR/"
    else
        # Fallback: use tar for reliable copying of all files
        (cd "$package_dir" && tar cf - --exclude='node_modules' --exclude='.git' --exclude='.github' --exclude='package.json' --exclude='package-lock.json' .) | (cd "$BASE_DIR" && tar xf -)
    fi

    # Verify critical files were copied
    if [[ ! -f "$BASE_DIR/scripts/install-global.sh" ]]; then
        print_error "Critical files missing after copy"
        print_status "Source directory: $package_dir"
        print_status "Attempting direct copy..."

        # Direct copy as last resort
        mkdir -p "$BASE_DIR"
        cp -R "$package_dir"/* "$BASE_DIR/" 2>/dev/null || true
        cp -R "$package_dir"/.[!.]* "$BASE_DIR/" 2>/dev/null || true

        if [[ ! -f "$BASE_DIR/scripts/install-global.sh" ]]; then
            print_error "Installation failed - files could not be copied"
            exit 1
        fi
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
    read -p "Install 'agent-os' command globally? (Y/n): " -r
    echo
    # Default to "y" if empty (user just pressed Enter)
    REPLY=${REPLY:-y}
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [[ -f "$BASE_DIR/scripts/install-global.sh" ]]; then
            bash "$BASE_DIR/scripts/install-global.sh"
        else
            print_error "Global install script not found at $BASE_DIR/scripts/install-global.sh"
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
