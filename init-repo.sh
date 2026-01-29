#!/bin/bash
set -e

echo "==================================="
echo "OpenBao Nightly Build - Repository Initialization"
echo "==================================="
echo ""

# Check if we're in the right directory
if [ ! -f "README.md" ] || [ ! -d ".github" ]; then
    echo "ERROR: Please run this script from the openbao-nightly-diy directory"
    exit 1
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Step 1: Clean up the reference clone
echo "Step 1: Cleaning up reference clone..."
if [ -d "openbao" ]; then
    echo "  Removing openbao directory (reference clone not needed in repo)..."
    rm -rf openbao
    print_status "Removed openbao directory"
else
    print_status "openbao directory already clean"
fi
echo ""

# Step 2: Check git status
echo "Step 2: Checking git status..."
if [ -d ".git" ]; then
    print_warning "Git repository already initialized"
    echo "  Current status:"
    git status --short
else
    echo "  Initializing git repository..."
    git init
    print_status "Git repository initialized"
fi
echo ""

# Step 3: Get repository information
echo "Step 3: Repository Setup"
echo ""
echo "Please enter your GitHub repository information:"
echo ""

read -p "GitHub username: " GH_USERNAME
read -p "Repository name (e.g., openbao-nightly): " REPO_NAME

if [ -z "$GH_USERNAME" ] || [ -z "$REPO_NAME" ]; then
    print_error "Username and repository name are required"
    exit 1
fi

REPO_URL="https://github.com/$GH_USERNAME/$REPO_NAME.git"
echo ""
echo "Repository URL: $REPO_URL"
echo ""

# Step 4: Update README with actual repo URL
echo "Step 4: Updating documentation with your repository details..."
if command -v sed &> /dev/null; then
    # Update README placeholders
    sed -i.bak "s|YOUR_USERNAME|$GH_USERNAME|g" README.md
    sed -i.bak "s|YOUR_REPO|$REPO_NAME|g" README.md
    sed -i.bak "s|YOUR_USERNAME|$GH_USERNAME|g" SETUP.md
    sed -i.bak "s|YOUR_REPO|$REPO_NAME|g" SETUP.md
    sed -i.bak "s|YOUR_USERNAME|$GH_USERNAME|g" QUICK_START.md
    sed -i.bak "s|YOUR_REPO|$REPO_NAME|g" QUICK_START.md
    rm -f *.bak
    print_status "Updated documentation with your repository details"
else
    print_warning "sed not found - you'll need to manually update YOUR_USERNAME and YOUR_REPO in docs"
fi
echo ""

# Step 5: Add remote if not exists
echo "Step 5: Configuring git remote..."
if git remote get-url origin &> /dev/null; then
    CURRENT_REMOTE=$(git remote get-url origin)
    if [ "$CURRENT_REMOTE" != "$REPO_URL" ]; then
        print_warning "Remote 'origin' already exists: $CURRENT_REMOTE"
        read -p "Update to $REPO_URL? (y/n): " UPDATE_REMOTE
        if [ "$UPDATE_REMOTE" = "y" ]; then
            git remote set-url origin "$REPO_URL"
            print_status "Updated remote URL"
        fi
    else
        print_status "Remote already correctly configured"
    fi
else
    git remote add origin "$REPO_URL"
    print_status "Added remote 'origin'"
fi
echo ""

# Step 6: Stage files
echo "Step 6: Staging files..."
git add .
NUM_FILES=$(git diff --cached --numstat | wc -l)
print_status "Staged $NUM_FILES files"
echo ""

# Step 7: Show what will be committed
echo "Step 7: Files to be committed:"
git status --short
echo ""

# Step 8: Create initial commit
echo "Step 8: Creating initial commit..."
read -p "Create initial commit? (y/n): " CREATE_COMMIT
if [ "$CREATE_COMMIT" = "y" ]; then
    git commit -m "Initial setup: OpenBao nightly build automation

- Add GitHub Actions workflows for automated builds
- Add documentation (README, SETUP, QUICK_START)
- Add local build script for testing
- Configure multi-platform builds with GoReleaser"
    print_status "Created initial commit"
else
    print_warning "Skipped commit - you can commit manually later"
fi
echo ""

# Step 9: Show next steps
echo "==================================="
echo "Setup Complete!"
echo "==================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Create the repository on GitHub:"
echo "   → Go to: https://github.com/new"
echo "   → Name: $REPO_NAME"
echo "   → Visibility: Public (recommended)"
echo "   → Do NOT initialize with README"
echo ""
echo "2. Push to GitHub:"
echo "   → git push -u origin main"
echo ""
echo "3. Configure GitHub Actions:"
echo "   → Go to: https://github.com/$GH_USERNAME/$REPO_NAME/settings/actions"
echo "   → Enable: 'Allow all actions and reusable workflows'"
echo "   → Enable: 'Read and write permissions'"
echo "   → Save"
echo ""
echo "4. Trigger first build:"
echo "   → Go to: https://github.com/$GH_USERNAME/$REPO_NAME/actions"
echo "   → Select: 'OpenBao Nightly Release (GoReleaser)'"
echo "   → Click: 'Run workflow'"
echo ""
echo "5. Check the release:"
echo "   → Go to: https://github.com/$GH_USERNAME/$REPO_NAME/releases"
echo "   → Look for: 'nightly' tag"
echo ""
echo "For detailed instructions, see:"
echo "  • QUICK_START.md - 5-minute guide"
echo "  • SETUP.md - Comprehensive setup guide"
echo "  • README.md - Full documentation"
echo ""
echo "Good luck with your nightly builds! 🚀"
echo ""
