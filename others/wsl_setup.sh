#!/usr/bin/env bash
#-------------------------------------------------------------------------
#  Fedora WSL Setup (Fix Mirror 404 Issues)
#-------------------------------------------------------------------------

set -e # Dừng nếu lỗi nghiêm trọng xảy ra

echo
echo "🚀 STARTING INSTALLATION (RESILIENT MODE)..."
echo

# 1. FIX DNF & MIRRORS ----------------------------------------------------
echo "🧹 Cleaning DNF cache to fix 404 errors..."
# Xóa cache cũ để tránh lỗi "Metadata says file exists, but server says 404"
sudo dnf clean all

echo "🔄 Refreshing repositories..."
# Ép buộc tải lại metadata mới nhất
sudo dnf makecache --refresh

# Cập nhật hệ thống trước để tránh xung đột phiên bản
echo "⬆️  Upgrading system packages..."
sudo dnf upgrade --refresh -y

# 2. INSTALL BUILD TOOLS & ESSENTIALS -------------------------------------
echo "📦 INSTALLING PACKAGES..."

# Danh sách gói
PKGS=(
    # Core Build Tools (Thay thế Development Tools group)
    'gcc' 'gcc-c++' 'make' 'automake' 'autoconf' 'cmake' 
    'pkgconf-pkg-config' 'libtool' 'openssl-devel'
    
    # System Tools
    'git' 'stow' 'curl' 'wget' 'unzip' 'man-db' 'bat'
    'wl-clipboard' 'xclip'
    
    # Terminal Tools
    'zsh' 'tmux' 'lsd' 'zoxide' 'fzf' 'ripgrep' 'fd-find' 'tree'
    
    # Runtimes
    'python3' 'python3-pip'
    'nodejs' 'npm'
    'java-latest-openjdk' 'java-latest-openjdk-devel'
    'cargo'
)

# Cài đặt (Thêm --skip-broken để nếu 1 gói lỗi mirror thì không dừng cả script)
# Thêm --refresh lần nữa cho chắc
echo "⏳ Downloading and Installing..."
sudo dnf install "${PKGS[@]}" --refresh --skip-broken -y

# 3. POST-INSTALL CONFIGURATION -------------------------------------------

# Fix fd command
if ! command -v fd &> /dev/null; then
    if command -v fdfind &> /dev/null; then
        echo "🔗 Linking fdfind to fd..."
        sudo ln -s $(which fdfind) /usr/local/bin/fd
    fi
fi

# Cài Bob (Neovim Manager) via Cargo
if ! command -v bob &> /dev/null; then
    echo "🦀 Installing Bob (via Cargo)..."
    # Source cargo env tạm thời nếu vừa cài xong
    [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
    
    cargo install bob-nvim
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Cài Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "⚙️  Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Cài TPM
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "🔌 Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Đổi Shell
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "🔄 Changing shell..."
    if command -v lchsh &> /dev/null; then
        sudo lchsh -i "$USER"
    else
        sudo chsh -s $(which zsh) "$USER"
    fi
fi

echo
echo "✅ DONE! (Nếu có gói nào bị skip do lỗi mirror, hãy chạy lại script sau vài giờ)"
echo "--------------------------------------------------------"
