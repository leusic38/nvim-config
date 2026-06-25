return {
  {
    id = "ex-subst-01", title = "Remplacer tous les 'foo' par 'bar' dans le fichier",
    category = "excmd", difficulty = 3, hint = ":%s/foo/bar/g",
    start_lines = { "foo a foo", "b foo" }, start_cursor = { 1, 0 },
    target_lines = { "bar a bar", "b bar" },
  },
  {
    id = "ex-move-01", title = "Déplacer la ligne 1 après la ligne 3",
    category = "excmd", difficulty = 4, hint = ":1m3",
    start_lines = { "une", "deux", "trois" }, start_cursor = { 1, 0 },
    target_lines = { "deux", "trois", "une" },
  },
  {
    id = "ex-sort-01", title = "Trier les lignes alphabétiquement",
    category = "excmd", difficulty = 2, hint = ":%sort",
    start_lines = { "charlie", "alpha", "bravo" }, start_cursor = { 1, 0 },
    target_lines = { "alpha", "bravo", "charlie" },
  },
}
