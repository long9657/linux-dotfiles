#!/usr/bin/env bash
#-------------------------------------------------------------------------
#  Fedora WSL Setup (All-in-One: Fix Mirror + Plugins + CLI Only)
#-------------------------------------------------------------------------

set -e # Dừng nếu lỗi nghiêm trọng xảy ra

echo
echo "🚀 STARTING INSTALLATION (FINAL VERSION)..."
echo

# # 1. FIX DNF & MIRRORS ----------------------------------------------------
# echo "🧹 Cleaning DNF cache to fix 404 errors..."
# # Xóa cache cũ để tránh lỗi "Metadata says file exists, but server says 404"
# sudo dnf clean all

# echo "🔄 Refreshing repositories..."
# # Ép buộc tải lại metadata mới nhất
# sudo dnf makecache --refresh

# # Cập nhật hệ thống trước để tránh xung đột phiên bản
# echo "⬆️  Upgrading system packages..."
# sudo dnf upgrade --refresh -y

# 2. INSTALL PACKAGES (CLI TOOLS ONLY) ------------------------------------
echo "📦 INSTALLING PACKAGES..."

# Danh sách gói cụ thể (Tránh dùng Group để không lỗi trên dnf5)
PKGS=(
    # Core Build Tools
    'gcc' 'gcc-c++' 'make' 'automake' 'autoconf' 'cmake' 
    'pkgconf-pkg-config' 'libtool' 'openssl-devel'
    
    # System Tools
    'git' 'stow' 'curl' 'wget' 'unzip' 'man-db' 'bat'
    'xclip'
    'gawk'
    # Terminal Tools
    'zsh' 'tmux' 'lsd' 'zoxide' 'fzf' 'ripgrep' 'fd-find' 'tree'
    'tree-sitter-cli'
    # Runtimes
    'python3' 'python3-pip'
    'nodejs' 'npm'
    'java-latest-openjdk' 'java-latest-openjdk-devel'
    'cargo'
)

# Cài đặt (Thêm --skip-broken để nếu 1 gói lỗi mirror thì không dừng cả script)
echo "⏳ Downloading and Installing..."
sudo dnf install "${PKGS[@]}" --refresh --skip-broken -y

# 3. POST-INSTALL CONFIGURATION -------------------------------------------

# 3.1 Fix fd command
if ! command -v fd &> /dev/null; then
    if command -v fdfind &> /dev/null; then
        echo "🔗 Linking fdfind to fd..."
        sudo ln -s $(which fdfind) /usr/local/bin/fd
    fi
fi

# 3.2 Cài Bob (Neovim Manager) via Cargo
if ! command -v bob &> /dev/null; then
    echo "🦀 Installing Bob (via Cargo)..."
    # Source cargo env tạm thời nếu vừa cài xong
    [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
    
    cargo install bob-nvim
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# 3.3 Cài Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "⚙️  Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 3.4 Cài Zsh Plugins (FIX LỖI "PLUGIN NOT FOUND")
echo "🔌 Installing Zsh Plugins..."
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# 3.5 Cài TPM (Tmux Plugin Manager)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "🔌 Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# 3.6 Đổi Shell sang Zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "🔄 Changing shell..."
    if command -v lchsh &> /dev/null; then
        sudo lchsh -i "$USER"
    else
        sudo chsh -s $(which zsh) "$USER"
    fi
fi

echo
echo "✅ DONE! Setup hoàn tất."
echo "--------------------------------------------------------"
echo "👉 BƯỚC CUỐI CÙNG:"
echo "1. Chạy lệnh: source ~/.zshrc (để load lại config mới)"
echo "2. Nếu bạn có dotfiles, hãy chạy 'stow' ngay bây giờ."
echo "--------------------------------------------------------"
