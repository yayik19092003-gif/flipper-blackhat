#!/bin/bash

################################################################################
# FLIPPER BLACKHAT - COMPLETE DEPLOYMENT SCRIPT
# ============================================================================
# This script sets up the entire Flipper Blackhat environment
# Includes: Environment setup, dependencies, all 3 repos, and build tools
# Run: chmod +x DEPLOYMENT.sh && ./DEPLOYMENT.sh
################################################################################

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "\n${BLUE}═════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═════════════════════════════════════════════════════════${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# ============================================================================
# STEP 1: Update System & Install Dependencies
# ============================================================================

print_header "STEP 1: System Setup & Dependencies"

print_info "Updating package manager..."
apk update || print_warning "Failed to update package manager"

print_info "Installing essential packages..."
packages=(
    "git"
    "curl"
    "wget"
    "ca-certificates"
    "python3"
    "py3-pip"
    "vim"
    "nano"
    "tree"
    "bash"
    "coreutils"
    "findutils"
)

for package in "${packages[@]}"; do
    echo -n "Installing $package... "
    if apk add "$package" &>/dev/null; then
        print_success "$package installed"
    else
        print_warning "$package already installed or unavailable"
    fi
done

# ============================================================================
# STEP 2: Python Environment Setup
# ============================================================================

print_header "STEP 2: Python Environment Setup"

print_info "Upgrading pip..."
pip install --upgrade pip --quiet || print_warning "pip upgrade had issues"

print_info "Installing Python dependencies..."
python_packages=(
    "kicad"
    "kifield"
    "numpy"
    "pandas"
)

for package in "${python_packages[@]}"; do
    echo -n "Installing $package... "
    if pip install "$package" --quiet 2>/dev/null; then
        print_success "$package installed"
    else
        print_warning "$package installation had issues (may not be available)"
    fi
done

# ============================================================================
# STEP 3: Git Configuration
# ============================================================================

print_header "STEP 3: Git Configuration"

print_info "Configuring git..."
git config --global user.name "Flipper Blackhat Developer" 2>/dev/null || true
git config --global user.email "dev@flipper-blackhat.local" 2>/dev/null || true

print_success "Git configured"

# ============================================================================
# STEP 4: Create Project Structure
# ============================================================================

print_header "STEP 4: Project Directory Structure"

base_dir="$HOME/flipper-blackhat-project"

print_info "Creating project directories..."
mkdir -p "$base_dir"/{repos,output,docs,tools,builds}

print_info "Creating directory structure:"
echo "  $base_dir/"
echo "  ├── repos/                    # All source repositories"
echo "  ├── output/                   # Generated files (BOM, Gerbers, etc)"
echo "  ├── docs/                     # Documentation & guides"
echo "  ├── tools/                    # Utility scripts"
echo "  └── builds/                   # Build artifacts"

print_success "Directories created"

# ============================================================================
# STEP 5: Clone All Three Repositories
# ============================================================================

print_header "STEP 5: Cloning Repositories"

cd "$base_dir/repos"

# Clone Hardware (current repo)
print_info "Cloning flipper-blackhat (Hardware)..."
if [ -d "flipper-blackhat" ]; then
    print_warning "flipper-blackhat already exists, skipping clone"
else
    git clone https://github.com/yayik19092003-gif/flipper-blackhat.git
    print_success "flipper-blackhat cloned"
fi

# Clone OS
print_info "Cloning flipper-blackhat-os (Firmware)..."
if [ -d "flipper-blackhat-os" ]; then
    print_warning "flipper-blackhat-os already exists, skipping clone"
else
    git clone https://github.com/o7-machinehum/flipper-blackhat-os.git
    print_success "flipper-blackhat-os cloned"
fi

# Clone App
print_info "Cloning flipper-blackhat-app (Application)..."
if [ -d "flipper-blackhat-app" ]; then
    print_warning "flipper-blackhat-app already exists, skipping clone"
else
    git clone https://github.com/o7-machinehum/flipper-blackhat-app.git
    print_success "flipper-blackhat-app cloned"
fi

# ============================================================================
# STEP 6: Repository Information
# ============================================================================

print_header "STEP 6: Repository Information"

cd "$base_dir/repos"

for repo_dir in flipper-blackhat flipper-blackhat-os flipper-blackhat-app; do
    if [ -d "$repo_dir" ]; then
        print_info "Repository: $repo_dir"
        cd "$repo_dir"
        
        # Get info
        branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
        commit=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
        remote=$(git config --get remote.origin.url 2>/dev/null || echo "unknown")
        
        echo "  Branch: $branch"
        echo "  Commit: $commit"
        echo "  Remote: $remote"
        echo "  Size: $(du -sh . | cut -f1)"
        echo ""
        
        cd ..
    fi
done

# ============================================================================
# STEP 7: Setup Development Branches
# ============================================================================

print_header "STEP 7: Setting Up Development Branches"

cd "$base_dir/repos"

for repo_dir in flipper-blackhat flipper-blackhat-os flipper-blackhat-app; do
    if [ -d "$repo_dir" ]; then
        print_info "Creating development branch in $repo_dir..."
        cd "$repo_dir"
        
        current_branch=$(git rev-parse --abbrev-ref HEAD)
        dev_branch="development-$(date +%Y%m%d)"
        
        # Only create if not already exists
        if ! git rev-parse --verify "$dev_branch" >/dev/null 2>&1; then
            git checkout -b "$dev_branch" 2>/dev/null
            print_success "Created branch: $dev_branch"
        else
            print_warning "Branch $dev_branch already exists"
        fi
        
        cd ..
    fi
done

# ============================================================================
# STEP 8: Generate Bill of Materials
# ============================================================================

print_header "STEP 8: Generating Bill of Materials (BOM)"

cd "$base_dir/repos/flipper-blackhat/hat/nff_pcb"

print_info "Checking for BOM generation script..."
if [ -f "generate_bom.py" ]; then
    print_success "Found generate_bom.py"
    print_info "BOM generation script is ready to use"
    print_info "Usage: python3 generate_bom.py <netlist.xml> <output.csv>"
else
    print_warning "generate_bom.py not found"
fi

# ============================================================================
# STEP 9: Create Utility Scripts
# ============================================================================

print_header "STEP 9: Creating Utility Scripts"

tools_dir="$base_dir/tools"

# Create a quick status script
cat > "$tools_dir/status.sh" << 'EOF'
#!/bin/bash
echo "=== Flipper Blackhat Project Status ==="
cd "$HOME/flipper-blackhat-project/repos"

for repo_dir in flipper-blackhat flipper-blackhat-os flipper-blackhat-app; do
    if [ -d "$repo_dir" ]; then
        echo ""
        echo "Repository: $repo_dir"
        cd "$repo_dir"
        git status
        cd ..
    fi
done
EOF

chmod +x "$tools_dir/status.sh"
print_success "Created status.sh"

# Create an update script
cat > "$tools_dir/update-all.sh" << 'EOF'
#!/bin/bash
echo "=== Updating All Repositories ==="
cd "$HOME/flipper-blackhat-project/repos"

for repo_dir in flipper-blackhat flipper-blackhat-os flipper-blackhat-app; do
    if [ -d "$repo_dir" ]; then
        echo ""
        echo "Updating $repo_dir..."
        cd "$repo_dir"
        git pull origin master
        cd ..
    fi
done

echo ""
echo "All repositories updated!"
EOF

chmod +x "$tools_dir/update-all.sh"
print_success "Created update-all.sh"

# ============================================================================
# STEP 10: Documentation & README
# ============================================================================

print_header "STEP 10: Creating Documentation"

cat > "$base_dir/README.md" << 'EOF'
# Flipper Blackhat - Complete Development Environment

## Project Structure
```
flipper-blackhat-project/
├── repos/
│   ├── flipper-blackhat/          # Hardware design (PCB, schematics)
│   ├── flipper-blackhat-os/       # Operating system/firmware
│   └── flipper-blackhat-app/      # Flipper Zero application
├── output/                        # Generated files (BOM, Gerbers, etc)
├── docs/                          # Documentation
├── tools/                         # Utility scripts
└── builds/                        # Build artifacts
```

## Quick Start

### Generate Bill of Materials
```bash
cd repos/flipper-blackhat/hat/nff_pcb
python3 generate_bom.py hardware.xml output.csv
```

### Check Repository Status
```bash
cd ~/flipper-blackhat-project
bash tools/status.sh
```

### Update All Repositories
```bash
cd ~/flipper-blackhat-project
bash tools/update-all.sh
```

### Create Development Branch
```bash
cd repos/flipper-blackhat
git checkout -b feature/my-feature
```

## Repositories

### Hardware (flipper-blackhat)
- PCB schematics (.kicad_sch files)
- PCB layout (.kicad_pcb file)
- Component libraries
- Mechanical designs (FreeCAD)
- Bill of Materials generator (Python)

### Operating System (flipper-blackhat-os)
- Bootloader
- Linux kernel patches
- Device drivers
- System utilities
- Language: C++
- License: MIT

### Application (flipper-blackhat-app)
- Flipper Zero UI app
- WiFi attack implementations
- Command handlers
- Language: C

## Important Notes
- License: CC 4.0 Non-commercial (hardware), MIT (firmware)
- Personal use only - do not sell cloned boards
- All three components are needed for a complete system

## Development Workflow

1. **Create a feature branch**
   ```bash
   git checkout -b feature/my-feature
   ```

2. **Make changes**
   - Edit schematics in KiCad (desktop)
   - Edit code in your editor

3. **Commit and push**
   ```bash
   git add .
   git commit -m "Description of changes"
   git push origin feature/my-feature
   ```

4. **Create Pull Request** on GitHub

## Tools Available
- `tools/status.sh` - Show status of all repos
- `tools/update-all.sh` - Pull latest changes from all repos
- Python BOM generator in hardware repo
- KiField for batch editing (requires installation)

## Next Steps
1. Review datasheets in `repos/flipper-blackhat/hat/app_notes/`
2. Understand hardware in `repos/flipper-blackhat/hat/nff_pcb/`
3. Explore OS codebase in `repos/flipper-blackhat-os/`
4. Check app implementation in `repos/flipper-blackhat-app/`

## Support
- Original repositories: https://github.com/o7-machinehum
- Your fork: https://github.com/yayik19092003-gif/flipper-blackhat
- Discuss issues, create PRs, collaborate!
EOF

print_success "Created README.md"

# ============================================================================
# STEP 11: Final Status Report
# ============================================================================

print_header "STEP 11: Deployment Summary"

print_success "✓ Deployment completed successfully!"

echo ""
echo "Project Location: $base_dir"
echo ""

# Calculate total size
total_size=$(du -sh "$base_dir" | cut -f1)
echo -e "${GREEN}Total project size: $total_size${NC}"
echo ""

# Repository stats
echo -e "${BLUE}Repository Status:${NC}"
cd "$base_dir/repos"

for repo in flipper-blackhat flipper-blackhat-os flipper-blackhat-app; do
    if [ -d "$repo" ]; then
        size=$(du -sh "$repo" | cut -f1)
        files=$(find "$repo" -type f | wc -l)
        echo "  ✓ $repo ($size, $files files)"
    fi
done

echo ""
echo -e "${BLUE}Available Tools:${NC}"
echo "  ✓ tools/status.sh - View repository status"
echo "  ✓ tools/update-all.sh - Update all repositories"
echo ""

echo -e "${BLUE}Documentation:${NC}"
echo "  ✓ README.md - Project guide"
echo ""

echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. cd $base_dir"
echo "  2. cat README.md                      # Read the guide"
echo "  3. bash tools/status.sh               # Check status"
echo "  4. cd repos/flipper-blackhat          # Start with hardware"
echo ""

echo -e "${GREEN}🎉 Ready to begin development!${NC}"
echo ""

################################################################################
# End of Deployment Script
################################################################################
