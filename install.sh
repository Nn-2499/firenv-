
# Install Neovim + NvChad
echo -e "${YELLOW}📦 Installing Neovim and NvChad...${NC}"
pkg install -y neovim ripgrep

# Backup old nvim config
[ -d ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.bak.$(date +%s)

# Install NvChad
echo -e "${YELLOW}🎨 Cloning NvChad...${NC}"
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1

# สร้าง custom config
mkdir -p ~/.config/nvim/lua/custom
cat > ~/.config/nvim/lua/custom/init.lua << 'NVIM_CUSTOM'
-- Custom config for NvChad on Termux
local M = {}

M.ui = {
  theme = "catppuccin",
  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
  },
}

M.plugins = {
  user = {
    -- Telescope for file finding
    {
      "nvim-telescope/telescope.nvim",
      cmd = "Telescope",
      keys = {
        { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
        { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
        { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Find buffers" },
      },
      config = function()
        local telescope = require("telescope")
        telescope.setup({
          defaults = {
            file_ignore_patterns = { "node_modules", ".git", "target" },
          },
        })
      end,
    },
    -- NvimTree file explorer
    {
      "nvim-tree/nvim-tree.lua",
      cmd = "NvimTreeToggle",
      keys = {
        { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file explorer" },
      },
      config = function()
        require("nvim-tree").setup({
          sort_by = "case_sensitive",
          view = {
            width = 30,
            side = "left",
          },
          renderer = {
            group_empty = true,
          },
        })
      end,
    },
  },
}

return M
NVIM_CUSTOM

# Install plugins automatically
echo -e "${YELLOW}🚀 Installing Neovim plugins (first run)...${NC}"
nvim --headless +'Lazy! sync' +'qa' 2>/dev/null || true

echo -e "${GREEN}✅ Neovim + NvChad installed!${NC}"
echo -e "${CYAN}   Run 'nvim' to start coding${NC}"
