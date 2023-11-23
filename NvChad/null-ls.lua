local null_ls = require "null-ls"
local b = null_ls.builtins

local sources = {
  -- webdev stuff
  b.formatting.deno_fmt, -- chosen for ts/js files because it's very fast!
  b.formatting.prettier.with { filetypes = { "html", "markdown", "css", "yaml", "terraform" } },
  -- Lua
  b.formatting.stylua,

  -- cpp
  b.formatting.clang_format,

  -- -- yaml
  -- b.diagnostics.yamllint, -- for YAML linting

  -- bash
  b.formatting.shfmt, -- for Bash formatting
  b.diagnostics.shellcheck, -- for Bash linting

  -- -- ansible
  -- b.diagnostics.ansiblelint, -- for Ansible linting

  
}

null_ls.setup {
  debug = true,
  sources = sources,
}
