#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
# สคริปติดตั้ง NvChad + Zsh + Starship + ปลั๊กอิน 4 ตัวสำหรับ Termux
# สีที่ใช้: เขียวและม่วง
# ============================================================

set -e  # หยุดสคริปทันทีเมื่อเกิด error

# สีและสไตล์สำหรับข้อความในสคริป
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# ฟังก์ชันแสดงข้อความ
print_msg() { echo -e "${GREEN}==>${NC} ${BOLD}$1${NC}"; }
print_sub() { echo -e "${CYAN}   ->${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_status() { echo -e "${PURPLE}[STATUS]${NC} $1"; }

# เริ่มสคริป
clear
echo -e "${PURPLE}${BOLD}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║     Termux Setup Script - NvChad + Zsh + Starship       ║"
echo "║                  Green & Purple Theme                   ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
sleep 2

# 1. อัปเดตระบบและติดตั้ง dependencies
print_msg "อัปเดตแพ็กเกจและติดตั้ง dependencies ที่จำเป็น..."
pkg update -y && pkg upgrade -y
pkg install -y git neovim zsh starship wget curl nodejs ripgrep lazygit make cmake unzip zip which

# 2. ติดตั้ง Nerd Font (จำเป็นสำหรับไอคอน)
print_msg "กำลังติดตั้ง Nerd Font..."
mkdir -p ~/.termux
FONT_URL="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFont-Regular.ttf"
wget -O ~/.termux/font.ttf "$FONT_URL" || {
    print_warn "ดาวน์โหลด JetBrainsMono Nerd Font ไม่สำเร็จ ใช้ Font สำรอง"
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/HackNerdFont-Regular.ttf"
    wget -O ~/.termux/font.ttf "$FONT_URL"
}
termux-reload-settings
print_sub "ติดตั้ง Font เสร็จแล้ว กรุณารีสตาร์ท Termux เพื่อโหลด Font ใหม่"

# 3. ตั้งค่า Zsh เป็น Shell หลัก
print_msg "ตั้งค่า Zsh เป็น Shell หลัก..."
if [[ "$SHELL" != *"zsh"* ]]; then
    chsh -s zsh
    print_sub "เปลี่ยน Shell เป็น Zsh เรียบร้อย (ต้องรีสตาร์ท Termux เพื่อ生效)"
fi

# 4. ตั้งค่า Starship
print_msg "ตั้งค่า Starship prompt..."
mkdir -p ~/.config
cat > ~/.config/starship.toml << 'EOF'
# Starship configuration - Green & Purple Theme
add_newline = true
command_timeout = 500

[character]
success_symbol = "[➜](bold green)"
error_symbol = "[✗](bold red)"
vimcmd_symbol = "[N](bold purple)"
vimcmd_visual_symbol = "[V](bold purple)"
vimcmd_replace_symbol = "[R](bold purple)"

[directory]
style = "bold purple"
truncation_length = 2
truncation_symbol = "../"
read_only = " 🔒"

[git_branch]
symbol = "🌿 "
style = "bold green"
truncation_length = 15

[git_status]
style = "green"
ahead = "⇡"
behind = "⇣"
diverged = "⇕"

[nodejs]
symbol = "⬢ "
style = "bold green"

[rust]
symbol = "🦀 "
style = "bold purple"

[python]
symbol = "🐍 "
style = "bold purple"

[lua]
symbol = "🌙 "
style = "bold green"

[golang]
symbol = "🐹 "
style = "bold green"

[cmd_duration]
style = "purple"
min_time = 2000

[username]
style_user = "bold green"
style_root = "bold red"
show_always = false

[hostname]
ssh_only = true
style = "bold purple"
ssh_symbol = "🌐 "

[line_break]
disabled = false

[battery]
full_symbol = "🔋 "
charging_symbol = "⚡ "
discharging_symbol = "🔋 "
style = "bold green"
EOF

# 5. เพิ่ม Starship init ใน .zshrc
print_msg "เพิ่ม Starship init ไปที่ ~/.zshrc..."
cat >> ~/.zshrc << 'EOF'

# Starship prompt configuration
eval "$(starship init zsh)"

# Aliases ที่มีประโยชน์
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias nv='nvim'

# History settings
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
EOF

# 6. ติดตั้งและตั้งค่า NvChad
print_msg "ติดตั้ง NvChad..."
# Backup existing nvim config if exists
if [ -d ~/.config/nvim ]; then
    print_warn "พบการตั้งค่า Neovim เดิม กำลัง backup ไปที่ ~/.config/nvim.bak"
    mv ~/.config/nvim ~/.config/nvim.bak
fi

git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1

print_sub "ติดตั้ง NvChad เสร็จแล้ว"

# 7. เพิ่มปลั๊กอิน 4 ตัว
print_msg "เพิ่มปลั๊กอินที่แนะนำ 4 ตัว..."

# สร้างโฟลเดอร์ custom plugins
mkdir -p ~/.config/nvim/lua/custom/plugins

# ปลั๊กอินที่ 1: nvim-tree (file explorer)
cat > ~/.config/nvim/lua/custom/plugins/nvim-tree.lua << 'EOF'
return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("nvim-tree").setup({
      sort_by = "case_sensitive",
      view = {
        width = 30,
        side = "left",
        number = false,
        relativenumber = false,
      },
      renderer = {
        group_empty = true,
        highlight_git = true,
      },
      filters = {
        dotfiles = false,
      },
    })
    vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = "Toggle file explorer" })
  end,
}
EOF

# ปลั๊กอินที่ 2: telescope.nvim (fuzzy finder)
cat > ~/.config/nvim/lua/custom/plugins/telescope.lua << 'EOF'
return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        file_ignore_patterns = { "node_modules", ".git" },
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 10,
      },
      pickers = {
        find_files = { theme = "dropdown" },
        live_grep = { theme = "dropdown" },
      },
    })
    vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { desc = "Find files" })
    vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', { desc = "Live grep" })
    vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<CR>', { desc = "Find buffers" })
    vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<CR>', { desc = "Help tags" })
  end,
}
EOF

# ปลั๊กอินที่ 3: which-key.nvim (keybinding helper)
cat > ~/.config/nvim/lua/custom/plugins/which-key.lua << 'EOF'
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    require("which-key").setup({
      icons = { breadcrumb = "»", separator = "➜", group = "+" },
      window = { border = "single", position = "bottom" },
    })
  end,
}
EOF

# ปลั๊กอินที่ 4: indent-blankline.nvim (indentation guide)
cat > ~/.config/nvim/lua/custom/plugins/indent-blankline.lua << 'EOF'
return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  config = function()
    require("ibl").setup({
      indent = { char = "│" },
      scope = { enabled = true, show_start = false, show_end = false },
      whitespace = { highlight = { "Whitespace" } },
    })
  end,
}
EOF

# 8. ปรับแต่งธีม NvChad เป็นสีเขียว/ม่วง
print_msg "ปรับแต่งธีม NvChad เป็นโทนสีเขียว-ม่วง..."

# อัปเดต chadrc เพื่อเปลี่ยน theme
cat > ~/.config/nvim/lua/custom/chadrc.lua << 'EOF'
---@type ChadrcConfig
local M = {}

M.ui = {
  theme = "catppuccin",  -- สามารถเปลี่ยนเป็น "onedark", "tokyonight", "gruvbox" ได้ตามชอบ
  transparency = false,

  -- กำหนดสีหลักเป็นม่วงและเขียว
  hl_override = {
    Comment = { italic = true, fg = "#7c7c9c" },
    ["@comment"] = { italic = true, fg = "#7c7c9c" },
    Normal = { bg = "none" },
    TelescopeBorder = { fg = "#a277ff", bg = "none" },
    TelescopePromptBorder = { fg = "#a277ff", bg = "none" },
    TelescopeResultsBorder = { fg = "#a277ff", bg = "none" },
    TelescopePreviewBorder = { fg = "#a277ff", bg = "none" },
    NvimTreeNormal = { bg = "none" },
    StatusLine = { bg = "#2a2a3a", fg = "#f8f8f2" },
    StatusLineNC = { bg = "#1e1e2a", fg = "#6272a4" },
    WinSeparator = { fg = "#a277ff", bg = "none" },
    CursorLine = { bg = "#2a2a3a" },
    LineNr = { fg = "#6272a4" },
    CursorLineNr = { fg = "#f8f8f2", bold = true },
    Pmenu = { bg = "#2a2a3a", fg = "#f8f8f2" },
    PmenuSel = { bg = "#a277ff", fg = "#ffffff" },
  },

  statusline = {
    theme = "minimal",
    separator_style = "arrow",
    overrides = {
      mode = { fg = "#a277ff", bg = "#1e1e2a", bold = true },
      file = { fg = "#6cbf6c" },
      git = { fg = "#a277ff" },
      diagnostics = { fg = "#6cbf6c" },
    },
  },

  tabufline = {
    enabled = true,
    lazyload = false,
    overrides = {
      tab = { fg = "#a277ff" },
      tab_active = { fg = "#6cbf6c", bold = true },
    },
  },
}

M.plugins = {
  user = {
    { "nvim-tree/nvim-tree.lua", import = "custom.plugins.nvim-tree" },
    { "nvim-telescope/telescope.nvim", import = "custom.plugins.telescope" },
    { "folke/which-key.nvim", import = "custom.plugins.which-key" },
    { "lukas-reineke/indent-blankline.nvim", import = "custom.plugins.indent-blankline" },
  },
}

return M
EOF

# 9. เปิด Neovim ครั้งแรกเพื่อติดตั้งปลั๊กอิน
print_msg "กำลังเปิด Neovim เพื่อติดตั้งปลั๊กอินและส่วนประกอบเพิ่มเติม..."
print_warn "เมื่อเปิด Neovim ครั้งแรกปลั๊กอินจะถูกติดตั้งอัตโนมัติ"
print_warn "หากเจอข้อความ 'Press ENTER or type command to continue' ให้กด Enter"
print_warn "จากนั้นรันคำสั่ง :MasonInstallAll และ :TSInstallAll ใน Neovim"
print_status "กด Enter เพื่อเริ่ม Neovim..."
read -r

# สร้าง temporary init script
cat > /tmp/nvim_init.vim << 'EOF'
lua require("lazy").sync()
lua vim.cmd("MasonInstallAll")
lua vim.cmd("TSInstallSync all")
echo "การติดตั้งปลั๊กอินเสร็จสมบูรณ์!"
quit
EOF

nvim --headless -u ~/.config/nvim/init.lua -S /tmp/nvim_init.vim || {
    print_warn "Neovim headless mode error. กรุณาเปิด Neovim ด้วยคำสั่ง nvim แล้วรัน :MasonInstallAll และ :TSInstallAll ด้วยตัวเอง"
}

rm -f /tmp/nvim_init.vim

# 10. เสร็จสิ้น
echo ""
echo -e "${PURPLE}${BOLD}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                 การติดตั้งเสร็จสมบูรณ์!                   ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${GREEN}สิ่งที่ต้องทำเพิ่มเติม:${NC}"
echo "1. รีสตาร์ท Termux เพื่อให้การเปลี่ยนแปลงทั้งหมด生效"
echo "   คำสั่ง: exit แล้วเปิด Termux ใหม่"
echo ""
echo "2. เปิด Neovim เพื่อติดตั้งปลั๊กอินเพิ่ม (ถ้ายังไม่เสร็จสมบูรณ์)"
echo "   คำสั่ง: nvim"
echo "   จากนั้นใน Neovim ให้รัน: :MasonInstallAll"
echo "   และ: TSInstallAll"
echo ""
echo -e "${PURPLE}Keybindings ที่สำคัญใน NvChad:${NC}"
echo "   - Space + th   : เปลี่ยนธีม"
echo "   - Space + ff   : ค้นหาไฟล์ (Telescope)"
echo "   - Space + e    : เปิด/ปิด File Explorer"
echo "   - Space + ch   : ดู Keybindings ทั้งหมด"
echo "   - Ctrl + n     : Toggle file tree"
echo ""
echo -e "${GREEN}Enjoy your new Termux environment! 🚀${NC}"
