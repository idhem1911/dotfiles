
# P10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    sudo
    web-search
    copypath
    dirhistory
    zsh-history-substring-search
    fzf
    history
    command-not-found
    docker
    aliases
)

# History settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt appendhistory sharehistory incappendhistory

# Useful aliases
alias ll='ls -lah'

# Path exports
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# P10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ---------------------------------------------------------
#  System Health: Mirrors + Update + Clean + Health
# ---------------------------------------------------------
function sysup() {
    # 1. Rank Arch Linux Mirrors (Fastest 10, HTTPS only)
    echo -e "\n\033[1;33m📡 RANKING ARCH MIRRORS (Speed)...\033[0m"
    sudo reflector --verbose --country 'France,Germany,Netherlands' --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

    # 2. Update Arch & AUR (No confirm, just do it)
    # Note: If you use paru, change 'yay' to 'paru'. If you don't use AUR helpers, change to 'sudo pacman -Syu'
    echo -e "\n\033[1;36m🔄 STARTING SYSTEM UPDATE...\033[0m"
    yay -Syu --noconfirm

    # 3. Update Flatpaks
    echo -e "\n\033[1;34m📦 UPDATING FLATPAKS...\033[0m"
    flatpak update -y

    # 4. Cleanup Orphans & Cache
    echo -e "\n\033[1;32m🧹 CLEANING SYSTEM TRASH...\033[0m"
    # Remove orphans
    if [[ -n $(pacman -Qdtq) ]]; then
        sudo pacman -Rns $(pacman -Qdtq) --noconfirm
    fi
    # Keep only 1 cache version (Requires pacman-contrib)
    sudo paccache -rk1
    # Remove unused flatpak runtimes
    flatpak uninstall --unused -y
    # Vacuum logs
    sudo journalctl --vacuum-time=2weeks

    # 5. Final Health Check
    echo -e "\n\033[1;37m🏥 SYSTEM HEALTH CHECK...\033[0m"
    failed=$(systemctl --failed --no-legend)
    if [[ -n "$failed" ]]; then
        echo -e "\033[1;31m⚠️  FAILED SERVICES:\033[0m"
        echo "$failed"
    else
        echo -e "\033[1;32m✅ System Clean & Healthy.\033[0m"
    fi
}
# 1. Basic pretty tree (all files, human size, color, dirs first)
alias t='tree -a -h -C --dirsfirst'

# 2. Tree with limited depth (prevents flooding terminal in large projects)
# Adjust -L number as needed (e.g., -L 3)
alias tt='tree -a -h -C -L 2 --dirsfirst'
alias ttt='tree -a -h -C -L 3 --dirsfirst'

# Print Details about system devices
alias lsb='lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,MODEL,UUID'

# -------------

alias vault-open='sudo cryptsetup open /dev/sdc cryptusb && sudo mount /dev/mapper/cryptusb /mnt/cryptusb'
alias vault-close='sync && sudo umount /mnt/cryptusb && sudo cryptsetup close cryptusb'

alias cfg='nvim ~/.config/hypr/hyprland.conf'

export EDITOR='nvim'
export VISUAL='nvim'

# Function to export official and AUR packages separately
pkgprint() {
    # ├── Official Repo Packages
    pacman -Qqne > official_pkgs.txt
    # └── AUR/Foreign Packages
    pacman -Qqme > aur_pkgs.txt

    echo "Files created: official_pkgs.txt and aur_pkgs.txt"
}

# Optn=alias_name,command (Prints all Hypr/Waybar configs to text file)
sysConfigs() {
    local dir="$HOME/sysConfigs"

    # Safety check: Prevent accidental rm -rf if dir variable is empty
    if [[ -z "$dir" || "$dir" == "$HOME" ]]; then
        echo "❌ Error: Invalid directory path."; return 1
    fi

    # Clear previous dump so stale files don't linger if you remove a config
    rm -rf "$dir"
    mkdir -p "$dir"

    # ── Define Sub-directories ──
    local hypr_dir="$dir/hyprland"
    local waybar_dir="$dir/waybar"
    local system_dir="$dir/system"
    local pkg_dir="$dir/packages"
    local config_dir="$dir/configs"
    local gpu_dir="$dir/gpu-display"
    local net_dir="$dir/network"
    local svc_dir="$dir/services"

    mkdir -p "$hypr_dir" "$waybar_dir" "$system_dir" "$pkg_dir" "$config_dir" "$gpu_dir" "$net_dir" "$svc_dir"

    # ── Hyprland ──
    cat ~/.config/hypr/hyprland.conf    > "$hypr_dir/hyprland.txt"      2>/dev/null
    cat ~/.config/hypr/hypridle.conf    > "$hypr_dir/hypridle.txt"      2>/dev/null
    cat ~/.config/hypr/hyprpaper.conf   > "$hypr_dir/hyprpaper.txt"     2>/dev/null
    cat ~/.config/hypr/hyprlock.conf    > "$hypr_dir/hyprlock.txt"      2>/dev/null
    cat ~/.config/hypr/keybindings.conf > "$hypr_dir/keybindings.txt"   2>/dev/null

    # ── Waybar ──
    cat ~/.config/waybar/config         > "$waybar_dir/config.txt"      2>/dev/null
    cat ~/.config/waybar/style.css      > "$waybar_dir/style.txt"       2>/dev/null
    cat ~/.config/waybar/scripts/amd-gpu.sh > "$waybar_dir/amd-gpu.txt" 2>/dev/null
    cat ~/.config/waybar/scripts/gpu-usage.sh > "$waybar_dir/gpu-usage.txt" 2>/dev/null

    # ── System Info ──
    fastfetch                           > "$system_dir/fastfetch.txt"   2>/dev/null
    uname -a                            > "$system_dir/kernel.txt"      2>/dev/null
    lspci                               > "$system_dir/lspci.txt"      2>/dev/null
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT > "$system_dir/disks.txt" 2>/dev/null
    free -h                             > "$system_dir/memory.txt"      2>/dev/null
    cat /proc/cpuinfo                   > "$system_dir/cpuinfo.txt"     2>/dev/null
    journalctl -b -p err --no-pager     > "$system_dir/boot-errors.txt" 2>/dev/null

    # ── Packages ──
    pacman -Qe                          > "$pkg_dir/explicit.txt"       2>/dev/null
    pacman -Qn                          > "$pkg_dir/official.txt"       2>/dev/null
    pacman -Qm                          > "$pkg_dir/AUR.txt"            2>/dev/null
    pacman -Qg                          > "$pkg_dir/groups.txt"         2>/dev/null

    # ── Other useful configs ──
    cat /etc/makepkg.conf               > "$config_dir/makepkg.txt"     2>/dev/null
    cat /etc/pacman.conf                > "$config_dir/pacman.txt"      2>/dev/null
    cat ~/.zshrc                        > "$config_dir/zshrc.txt"      2>/dev/null
    cat /etc/locale.gen                 > "$config_dir/locale.txt"      2>/dev/null
    cat /etc/environment                > "$config_dir/environment.txt" 2>/dev/null

    # ── GPU / Display ──
    glxinfo -B                          > "$gpu_dir/opengl.txt"         2>/dev/null
    xrandr                              > "$gpu_dir/display-layout.txt" 2>/dev/null

    # ── Network ──
    ip addr                             > "$net_dir/interfaces.txt"     2>/dev/null

    # ── Services ──
    systemctl list-unit-files --state=enabled --no-pager > "$svc_dir/enabled.txt" 2>/dev/null
    systemctl --user list-unit-files --state=enabled --no-pager > "$svc_dir/user.txt" 2>/dev/null

    # ── Summary ──
    local count=$(find "$dir" -type f ! -empty | wc -l)
    echo "✅ Dumped $count non-empty files to $dir/"

    # Use 'tree' for a nice visual output if installed, otherwise fallback to 'ls'
    if command -v tree &> /dev/null; then
        tree -C "$dir" --prune
    else
        ls -lhR "$dir"
    fi
}

# =========================================================================================

alias hyprlog='hyprctl configerrors'
alias hyprlogcp='hyprctl configerrors | wl-copy'

alias ping='ping -i 0.2 archlinux.org'
alias .zsh='nvim ~/.zshrc'

# =========================================================================================
# Gif Tools
# =========================================================================================

# Optimize GIF/MP4 for 1080p 24fps with custom palette
optigif() {
    if [[ -z "$1" ]]; then
        echo "Usage: optigif <input.mp4/gif> [output.gif]"
        return 1
    fi

    local input="$1"
    local name="${input%.*}" # Strips .mp4 or .gif
    local output="${2:-${name}_opt.gif}"

    ffmpeg -i "$input" -vf "fps=24,scale=1920:1080:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" "$output"
    echo "Done: $output"
}

# High-Quality Video to GIF Clipper
vid2gif() {
    if [[ -z "$1" ]]; then
        echo "Usage: vid2gif <input.mp4> [start_time] [duration_seconds]"
        echo "Example: vid2gif cyberpunk.mp4 00:01:15 5  (Starts at 1m15s, takes 5 seconds)"
        echo "Example: vid2gif cyberpunk.mp4 45 3       (Starts at 45s, takes 3 seconds)"
        return 1
    fi

    local input="$1"
    local start="${2:-0}"
    local duration="${3:-0}"
    local name="${input%.*}"
    local output="${name}_clip.gif"

    # Build duration flag only if provided
    local dur_flag=""
    if [[ "$duration" != "0" ]]; then
        dur_flag="-t $duration"
    fi

    echo "Extracting from $start for $duration seconds..."

    # -ss before -i for fast seeking.
    # stats_mode=diff optimizes colors for moving parts.
    # dither=sierra2_4a kills the fuzzy noise and reduces file size.
    ffmpeg -y -ss "$start" $dur_flag -i "$input" \
    -vf "fps=24,scale=1920:1080:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=256:stats_mode=diff[p];[s1][p]paletteuse=dither=sierra2_4a" \
    -loop 0 "$output"

    echo "Done: $output"
}

alias dotsync='~/.dotfiles/sync.sh'

alias sys='~/sysConfigs_dump.sh'
