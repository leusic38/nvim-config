-- JSON et YAML génériques (composer.json, package.json, docker-compose, CI GitLab, Ansible…).
-- SchemaStore.nvim : catalogue de schémas JSON/YAML ; les serveurs valident et complètent
-- un fichier selon son nom (composer.json, .gitlab-ci.yml, docker-compose.yml…).
-- Formatage (Prettier, seulement si le projet l'a configuré) : plan 3.

vim.pack.add({ "https://github.com/b0o/SchemaStore.nvim" }, { confirm = false })

require("manu.mason").ensure({ "json-lsp", "yaml-language-server" })

vim.lsp.config("jsonls", {
  before_init = function(_, config)
    config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
      json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } },
    })
  end,
})
vim.lsp.config("yamlls", {
  before_init = function(_, config)
    config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
      yaml = {
        -- SchemaStore.nvim fournit le catalogue ; celui intégré au serveur ferait doublon.
        schemaStore = { enable = false, url = "" },
        schemas = require("schemastore").yaml.schemas(),
        keyOrdering = false,
        -- Tags Symfony (!tagged_iterator, !php/const…) : ne pas les signaler comme inconnus.
        customTags = {
          "!tagged_iterator scalar", "!tagged_iterator mapping", "!tagged_locator scalar",
          "!tagged_locator mapping", "!php/const scalar", "!php/enum scalar", "!php/object scalar",
          "!service_closure scalar", "!abstract scalar", "!iterator sequence", "!service mapping",
        },
      },
    })
  end,
})
vim.lsp.enable({ "jsonls", "yamlls" })

require("manu.treesitter").install({ "json", "yaml", "xml" })
