-- Prise en charge XML : lemminx (LSP officiel Eclipse) pour la validation de
-- schéma, la complétion de balises/attributs et le formatage.
--
-- Complémentaire de symfony_lsp, qui ne fait que du Symfony (services, params,
-- routes) et ignore les XSD. Sur un projet Symfony à layout bundle, les
-- `Resources/config/*.xml` déclarent leur schéma via `xsi:schemaLocation`
-- (services-1.0.xsd, doctrine-mapping.xsd…) : lemminx le résout et signale un
-- attribut inconnu ou une balise mal placée avant l'exécution.
--
-- Le formatage passe par le fallback LSP de conform (pas de formateur XML
-- externe déclaré).

return {
  {
    "neovim/nvim-lspconfig",
    optional = true,
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          vim.list_extend(opts.ensure_installed, { "lemminx" })
        end,
      },
    },
    opts = {
      servers = {
        lemminx = {
          filetypes = { "xml", "xsd", "xsl", "xslt", "svg" },
          settings = {
            xml = {
              -- Les XSD Symfony sont référencés par URL http://symfony.com/… :
              -- sans téléchargement, aucune validation possible. Les schémas
              -- sont mis en cache par lemminx après le premier accès.
              downloadExternalResources = { enabled = true },
              validation = {
                enabled = true,
                -- Évite de résoudre les entités externes d'un document (XXE).
                resolveExternalEntities = false,
              },
              format = {
                enabled = true,
                splitAttributes = false,
                joinCDATALines = false,
                preserveEmptyContent = true,
              },
              completion = { autoCloseTags = true },
            },
          },
        },
      },
    },
  },
}
