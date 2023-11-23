local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"

-- if you just want default config for the servers then put them in a table
local servers = { "html", "cssls", "tsserver", "clangd" }

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

-- Ansible Language Server specific configuration
lspconfig.ansiblels.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = {"ansible-language-server", "--stdio"},
  filetypes = { "yaml" },
  -- root_dir = lspconfig.util.root_pattern(".ansible-lint", ".yamllint", ".git"),
  settings = {
    ansible = {
      validation = {
        enabled = true,
        lint = {
          enabled = true,
          path = "ansible-lint"
        }
      }, -- Added missing comma here
      ansible = {
        path = "ansible"
      },
      python = {
        interpreterPath = "python3"
      }
    }
  }
}


-- YAML Language Server configuration
lspconfig.yamlls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml" },  -- Adjust as needed
  settings = {
    yaml = {
      -- Configure yaml-lint here
      validate = true, -- enable/disable validation feature
      hover = true, -- enable/disable hover feature
      completion = true, -- enable/disable completion feature
      format = {
        enable = true, -- enable/disable formatter (requires yaml-lint to be installed)
      },
      schemas = {
        -- Optionally configure schemas
      },
      linting = true, -- Enable/disable linting (requires yaml-lint to be installed)
    },
  },
}

-- Bash Language Server configuration
lspconfig.bashls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh" },  -- Specify file types
  settings = {
    bashIde = {
      globPattern = "*@(.sh|.inc|.bash|.command)",
      highlightParsingErrors = true,
      highlightReferences = true,
    },
  },
}


-- Terraform Language Server configuration
lspconfig.terraformls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = {"terraform-ls", "serve"},
  filetypes = { "terraform", "terraform-vars" },

}

-- TFLint Language Server configuration
lspconfig.tflint.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = {"tflint", "--langserver"},
  filetypes = { "terraform" },
  
}

