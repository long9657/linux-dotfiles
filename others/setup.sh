#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _           _    __  __       _   _    
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__ 
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  EndeavourOS Setup (i3 + NVIDIA + Dotfiles + TPM)
#-------------------------------------------------------------------------

set -e # Dừng ngay nếu có lỗi

echo
echo "🚀 STARTING INSTALLATION..."
echo

# 1. OFFICIAL PACKAGES (PACMAN) -------------------------------------------
PKGS=(
    # SYSTEM & DOTFILES MANAGEMENT
    'base-devel'                # Compilers
    'git'                       # Version control
    'stow'                      # Dotfiles manager
    'curl' 'wget' 'unzip' 'man-db' 'bat'
    'nvidia-inst'               # 🟢 Công cụ cài driver NVIDIA chuẩn của EndeavourOS

    # TERMINAL UTILITIES
    'zsh'                       # Shell
    'tmux'                      # Multiplexer
    'neovim'                    # Editor
    'lsd'                       # New ls
    'zoxide'                    # New cd
    'fzf'                       # Fuzzy finder
    'ripgrep'                   # Grep siêu nhanh
    'fd'                        # Find siêu nhanh
    'tree'
    'discord'
    'qutebrowser'
    # CLIPBOARD & GUI (i3/X11 Specific)
    'xclip'                     # Clipboard manager (Cần cho Nvim/i3)
    'picom'                     # Compositor (Cần cho Ghostty transparency)
    'feh'                       # Wallpaper setter
    'rofi'                      # App launcher

    # LANGUAGES & RUNTIMES
    'python' 'python-pip' 
    'nodejs' 'npm' 
    'jdk-openjdk'
    # 'jre-openjdk'

    # FONTS (Giao diện & Terminal)
    'ttf-jetbrains-mono-nerd'   # Font dự phòng phổ biến
    'ttf-inconsolata-nerd'      # 🟢 Font bạn yêu cầu (Inconsolata)
)

echo "📦 INSTALLING (PACMAN)..."
for PKG in "${PKGS[@]}"; do
    # --needed: Bỏ qua nếu đã cài rồi
    sudo pacman -S "$PKG" --noconfirm --needed
done


# 2. AUR PACKAGES (YAY) ---------------------------------------------------
# EndeavourOS thường có sẵn yay. Kiểm tra cho chắc.
if ! command -v yay &> /dev/null; then
    echo "🛠  Installing Yay..."
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
fi

AUR_PKGS=(
    'ghostty'                   # Terminal Emulator
)

echo "👻 INSTALLING (AUR)..."
for APKG in "${AUR_PKGS[@]}"; do
    yay -S "$APKG" --noconfirm --needed
done


# 3. CONFIGURATION (ZSH & PLUGINS) ----------------------------------------
echo
echo "⚙️  CONFIGURING ZSH..."

# Cài Oh My Zsh (nếu chưa có)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Định nghĩa đường dẫn custom
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# --- CÀI PLUGIN ZSH ---

# 1. zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "🔌 Cloning zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# 2. zsh-syntax-highlighting
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
    chsh -s $(which zsh)
fi

echo
echo "✅ DONE! Setup hoàn tất."
echo "--------------------------------------------------------"
echo "👉 BƯỚC TIẾP THEO (BẮT BUỘC):"
echo "1. Cài Driver NVIDIA: Chạy lệnh 'sudo nvidia-inst'"
echo "   (Lệnh này sẽ tự setup dkms và kernel param cho EndeavourOS)"
echo ""
echo "2. Link Config: Chạy 'stow' cho nvim, zsh, tmux, ghostty..."
echo ""
echo "3. Tmux Plugins: Vào tmux, bấm 'Prefix + I' để cài plugin."
echo ""
echo "4. Font Config: Tên font chính xác là 'Inconsolata Nerd Font Mono'"
echo "   Kiểm tra lại bằng lệnh: fc-list | grep Inconsolata"
echo "--------------------------------------------------------"
