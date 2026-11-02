local add = MiniDeps.add

-- plenary.nvim (shared dependency)
add({ source = "nvim-lua/plenary.nvim" })

-- LSP
add({ source = "neovim/nvim-lspconfig" })
add({ source = "williamboman/mason.nvim" })
add({ source = "williamboman/mason-lspconfig.nvim" })

-- Completion
add({ source = "hrsh7th/nvim-cmp" })
add({ source = "hrsh7th/cmp-nvim-lsp" })
add({ source = "hrsh7th/cmp-buffer" })
add({ source = "hrsh7th/cmp-path" })
add({ source = "L3MON4D3/LuaSnip" })
add({ source = "saadparwaiz1/cmp_luasnip" })

-- lsp.lua: LSPと補完のセットアップ

local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local cmp = require("cmp")
local cmp_nvim_lsp = require("cmp_nvim_lsp")

-- LSPサーバー一覧
local servers = {
  "lua_ls",
  "ruby_lsp",
  "dockerls",
  "docker_compose_language_service",
  "ts_ls",
  "eslint",
  "cssls",
  "html",
  "metals",
}

-- masonのセットアップ
mason.setup()
mason_lspconfig.setup({
  ensure_installed = vim.tbl_filter(function(s) return s ~= "metals" end, servers),
  automatic_installation = true,
})

-- capabilities: cmp_nvim_lspで拡張
local capabilities = cmp_nvim_lsp.default_capabilities()

-- vim.lsp.configを使用した新しいAPI
for _, server in ipairs(servers) do
  local config = {
    capabilities = capabilities,
  }

  if server == "ts_ls" then
    config.settings = {
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = "all",
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
        },
      },
      javascript = {
        inlayHints = {
          includeInlayParameterNameHints = "all",
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
        },
      },
    }
    config.filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx",
    }
  end

  if server == "eslint" then
    config.on_attach = function(client, bufnr)
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        command = "EslintFixAll",
      })
    end
  end

  vim.lsp.config(server, config)
  vim.lsp.enable(server)
end

-- nvim-cmp 設定
cmp.setup({
  mapping = {
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
  },
})

-- キーマップはlua/config/keymaps.luaに統合されました
