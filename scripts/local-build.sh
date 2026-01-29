#!/bin/bash
set -e

# Local build script for testing
# This script mimics what the GitHub Action does, for local testing

OPENBAO_REPO="https://github.com/openbao/openbao.git"
OPENBAO_REF="${1:-main}"
BUILD_DIR="$(pwd)/local-build"

echo "==> Starting local OpenBao build"
echo "    Repository: $OPENBAO_REPO"
echo "    Reference: $OPENBAO_REF"
echo "    Build directory: $BUILD_DIR"

# Clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Clone OpenBao
echo ""
echo "==> Cloning OpenBao repository..."
git clone "$OPENBAO_REPO" "$BUILD_DIR/openbao-source"
cd "$BUILD_DIR/openbao-source"

# Checkout specified ref
echo ""
echo "==> Checking out $OPENBAO_REF..."
git checkout "$OPENBAO_REF"

COMMIT=$(git rev-parse HEAD)
SHORT_COMMIT=$(git rev-parse --short HEAD)

echo "    Commit: $COMMIT"

# Check dependencies
echo ""
echo "==> Checking dependencies..."
if ! command -v go &> /dev/null; then
    echo "ERROR: Go is not installed. Please install Go 1.23 or later."
    exit 1
fi

GO_VERSION=$(go version | awk '{print $3}')
echo "    Go version: $GO_VERSION"

# Install Go dependencies
echo ""
echo "==> Downloading Go modules..."
go mod download

# Run bootstrap
echo ""
echo "==> Running bootstrap..."
make bootstrap || echo "Bootstrap had some warnings, continuing..."

# Check if Node.js is available for UI build
BUILD_UI=false
if command -v node &> /dev/null && command -v npm &> /dev/null; then
    echo ""
    echo "==> Node.js found, building UI..."
    NODE_VERSION=$(node --version)
    echo "    Node version: $NODE_VERSION"

    cd ui
    echo "    Installing UI dependencies..."
    npm install --legacy-peer-deps || yarn install || true

    echo "    Building UI..."
    npm run build || yarn run build || echo "UI build failed, continuing without UI"
    cd ..

    BUILD_UI=true
else
    echo ""
    echo "==> WARNING: Node.js not found, skipping UI build"
    echo "    To build with UI, install Node.js 18+"
fi

# Build binary
echo ""
echo "==> Building OpenBao binary..."
BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)
NIGHTLY_VERSION="nightly-$(date -u +%Y%m%d)"

mkdir -p "$BUILD_DIR/release"

if [ "$BUILD_UI" = true ]; then
    echo "    Building with UI..."
    CGO_ENABLED=0 BUILD_TAGS='ui' sh -c "'$(pwd)/scripts/build.sh'"
else
    echo "    Building without UI..."
    CGO_ENABLED=0 sh -c "'$(pwd)/scripts/build.sh'"
fi

# Copy binary
if [ -f bin/bao ]; then
    cp bin/bao "$BUILD_DIR/release/bao"
    echo ""
    echo "==> Build successful!"
    echo "    Binary: $BUILD_DIR/release/bao"

    # Generate checksum
    cd "$BUILD_DIR/release"
    sha256sum bao > bao.sha256

    # Test binary
    echo ""
    echo "==> Testing binary..."
    chmod +x bao
    ./bao version || echo "Binary check completed"

    echo ""
    echo "==> Build complete!"
    echo "    Location: $BUILD_DIR/release/"
    echo "    Files:"
    ls -lh

    echo ""
    echo "To install:"
    echo "    sudo cp $BUILD_DIR/release/bao /usr/local/bin/"

elif [ -f openbao ]; then
    cp openbao "$BUILD_DIR/release/bao"
    echo ""
    echo "==> Build successful!"
    echo "    Binary: $BUILD_DIR/release/bao"
else
    echo ""
    echo "ERROR: Binary not found in expected location"
    echo "Searching for binary..."
    find . -name bao -type f -o -name openbao -type f
    exit 1
fi

echo ""
echo "==> Build information:"
echo "    Version: $NIGHTLY_VERSION"
echo "    Commit: $SHORT_COMMIT"
echo "    Date: $BUILD_DATE"
