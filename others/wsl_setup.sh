#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _            _        __  __       _    _   
#     /_\  _ _   __| |_     |  \/  |__ __| |_ (_)__ 
#    / _ \| '_| / _| ' \    | |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_||_|  |_|  |_\__,_|\__|_\__|
#  Fedora WSL Setup (CLI ONLY - DNF5 Compatible)
#-------------------------------------------------------------------------

set -e # Dừng ngay nếu có lỗi

echo
echo "🚀 STARTING INSTALLATION (FEDORA WSL - CLI ONLY)..."
echo "⚠️  LƯU Ý: Đảm bảo bạn đã chạy 'sudo dnf update' trước khi chạy script này."
echo

# 1. OFFICIAL PACKAGES (DNF/DNF5) -----------------------------------------
echo "📦 INSTALLING SYSTEM DEPENDENCIES..."

# --- FIX: Dùng cú pháp @Group thay vì groupinstall cho dnf5 ---
sudo dnf install "@Development Tools" "@C Development Tools and Libraries" -y

PKGS=(
    # SYSTEM & DOTFILES MANAGEMENT
    'git' 
    'stow' 
    'curl' 'wget' 'unzip' 'man-db' 'bat'
    'openssl-devel'             # Cần thiết để compile nhiều tool

    # TERMINAL UTILITIES
    'zsh' 
    'tmux' 
    'lsd' 
    'zoxide' 
    'fzf' 
    'ripgrep' 
    'fd-find'                   # Tên gói trong Fedora là fd-find
    'tree'
    
    # CLIPBOARD (Quan trọng cho Neovim/Tmux trong WSL)
    'wl-clipboard'              # Giúp copy từ terminal Linux ra Windows
    'xclip'                     # Fallback
    
    # LANGUAGES & RUNTIMES
    'python3' 'python3-pip'
    'nodejs' 'npm'
    'java-latest-openjdk' 'java-latest-openjdk-devel'
    'cargo'                     # Rust package manager (Cần để cài Bob)
)

echo "📦 INSTALLING PACKAGES (DNF)..."
for PKG in "${PKGS[@]}"; do
    # Kiểm tra gói đã cài chưa (hoạt động tốt trên cả dnf4 và dnf5)
    if ! rpm -q "$PKG" &> /dev/null; then
        echo "Installing $PKG..."
        sudo dnf install "$PKG" -y
    else
        echo "✅ $PKG đã được cài đặt."
    fi
done

# Fix tên lệnh fd (Fedora mặc định là fdfind, map lại thành fd)
if ! command -v fd &> /dev/null; then
    echo "🔗 Linking fdfind to fd..."
    sudo ln -s $(which fdfind) /usr/local/bin/fd
fi

# 2. EXTERNAL TOOLS (Cargo) -----------------------------------------------

# --- CÀI BOB (Neovim Version Manager) ---
if ! command -v bob &> /dev/null; then
    echo "🦀 Installing Bob (via Cargo)..."
    cargo install bob-nvim
    
    # Đảm bảo cargo bin nằm trong PATH
    export PATH="$HOME/.cargo/bin:$PATH"
else
    echo "✅ Bob đã được cài đặt."
fi

# 3. CONFIGURATION (ZSH & PLUGINS) ----------------------------------------
echo
echo "⚙️  CONFIGURING ZSH..."

# Cài Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# --- CÀI PLUGIN ZSH ---
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "🔌 Cloning zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "🔌 Cloning zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# 4. TMUX PLUGIN MANAGER (TPM) --------------------------------------------
echo
echo "🔌 CONFIGURING TMUX (TPM)..."
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "📥 Cloning Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo "✅ TPM already installed."
fi

# 5. FINISHING UP ---------------------------------------------------------

# Đổi shell sang Zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "🔄 Changing shell to Zsh..."
    # Thử lchsh trước (thường có trên Fedora), nếu không thì dùng chsh
    if command -v lchsh &> /dev/null; then
        sudo lchsh -i "$USER"
    else
        chsh -s $(which zsh)
    fi
fi

echo
echo "✅ DONE! Setup CLI hoàn tất."
echo "--------------------------------------------------------"
echo "👉 LƯU Ý:"
echo "   Nếu gặp lỗi về path của Cargo/Bob, hãy chạy lệnh sau hoặc reload shell:"
echo "   source ~/.bashrc  (hoặc source ~/.zshrc)"
echo "--------------------------------------------------------"
