#!/bin/bash

# =============================================================================
# Agent OS Global CLI Installation Script
# Installs the agent-os command globally for easy CLI access
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

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$HOME/.agent-os"
CLI_SOURCE="$BASE_DIR/scripts/agent-os"

# Determine installation location
if [[ -w "/usr/local/bin" ]]; then
    INSTALL_DIR="/usr/local/bin"
elif [[ -d "$HOME/.local/bin" ]]; then
    INSTALL_DIR="$HOME/.local/bin"
elif [[ -d "$HOME/bin" ]]; then
    INSTALL_DIR="$HOME/bin"
else
    # Create ~/.local/bin if it doesn't exist
    mkdir -p "$HOME/.local/bin"
    INSTALL_DIR="$HOME/.local/bin"
fi

INSTALL_PATH="$INSTALL_DIR/agent-os"

# -----------------------------------------------------------------------------
# Installation Functions
# -----------------------------------------------------------------------------

check_base_installation() {
    if [[ ! -d "$BASE_DIR" ]]; then
        print_error "Agent OS base installation not found at $BASE_DIR"
        echo ""
        print_status "Please run the base installation first:"
        echo "  curl -sSL https://raw.githubusercontent.com/CodefiLabs/agent-os/main/setup/base.sh | bash"
        exit 1
    fi

    if [[ ! -f "$CLI_SOURCE" ]]; then
        print_error "Agent OS CLI script not found at $CLI_SOURCE"
        exit 1
    fi
}

create_symlink() {
    print_status "Installing agent-os CLI to $INSTALL_DIR..."

    # Ensure source CLI is executable
    chmod +x "$CLI_SOURCE"

    # Remove existing symlink or file
    if [[ -L "$INSTALL_PATH" ]] || [[ -f "$INSTALL_PATH" ]]; then
        rm -f "$INSTALL_PATH"
    fi

    # Create symlink
    ln -s "$CLI_SOURCE" "$INSTALL_PATH"

    print_success "CLI installed to $INSTALL_PATH"
}

check_path() {
    if [[ ":$PATH:" == *":$INSTALL_DIR:"* ]]; then
        print_success "$INSTALL_DIR is in your PATH"
        return 0
    else
        print_warning "$INSTALL_DIR is not in your PATH"
        echo ""
        print_status "Add the following to your shell profile:"
        echo ""

        # Detect shell
        local shell_name=$(basename "$SHELL")
        case $shell_name in
            bash)
                echo "  echo 'export PATH=\"$INSTALL_DIR:\$PATH\"' >> ~/.bashrc"
                echo "  source ~/.bashrc"
                ;;
            zsh)
                echo "  echo 'export PATH=\"$INSTALL_DIR:\$PATH\"' >> ~/.zshrc"
                echo "  source ~/.zshrc"
                ;;
            fish)
                echo "  fish_add_path $INSTALL_DIR"
                ;;
            *)
                echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
                ;;
        esac
        echo ""
        return 1
    fi
}

test_installation() {
    print_status "Testing installation..."

    if command -v agent-os &> /dev/null; then
        print_success "agent-os command is available"
        echo ""
        agent-os version
        return 0
    else
        print_warning "agent-os command not found in PATH"
        echo ""
        print_status "Try running:"
        echo "  $INSTALL_PATH version"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Main Installation
# -----------------------------------------------------------------------------

main() {
    echo ""
    print_status "Agent OS Global CLI Installation"
    echo ""

    # Check base installation
    check_base_installation

    # Create symlink
    create_symlink

    echo ""

    # Check PATH
    local in_path=0
    check_path && in_path=1

    echo ""

    # Test installation
    if [[ $in_path -eq 1 ]]; then
        test_installation
        echo ""
        print_success "Installation complete!"
        echo ""
        print_status "You can now use 'agent-os' from anywhere:"
        echo "  agent-os install"
        echo "  agent-os update"
        echo "  agent-os create-profile"
        echo "  agent-os help"
    else
        echo ""
        print_warning "Installation complete, but PATH needs to be updated"
        echo ""
        print_status "After updating your PATH, you can use:"
        echo "  agent-os install"
        echo "  agent-os update"
        echo "  agent-os create-profile"
        echo "  agent-os help"
    fi
    echo ""
}

# Run main function
main "$@"
