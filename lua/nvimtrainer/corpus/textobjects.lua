return {
  {
    id = "to-diw-01", title = "Supprimer le mot sous le curseur",
    category = "textobjects", difficulty = 2, hint = "text object 'inner word'",
    start_lines = { "le chat noir dort" }, start_cursor = { 1, 3 },
    target_lines = { "le  noir dort" }, expected_keys = "diw",
  },
  {
    id = "to-ci-quote-01", title = "Remplacer le contenu entre guillemets par X",
    category = "textobjects", difficulty = 3, hint = "ci\" puis taper X",
    filetype = "lua",
    start_lines = { 'local s = "vieux"' }, start_cursor = { 1, 12 },
    target_lines = { 'local s = "X"' }, expected_keys = 'ci"X',
  },
  {
    id = "to-dap-01", title = "Supprimer le paragraphe entier",
    category = "textobjects", difficulty = 3, hint = "dap",
    start_lines = { "para un", "encore un", "", "para deux" }, start_cursor = { 1, 0 },
    target_lines = { "para deux" }, expected_keys = "dap",
  },
}
