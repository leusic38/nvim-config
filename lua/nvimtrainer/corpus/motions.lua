return {
  {
    id = "mo-dd-01", title = "Supprimer la ligne courante",
    category = "motions", difficulty = 1, hint = "dd",
    start_lines = { "garde moi", "supprime moi" }, start_cursor = { 2, 0 },
    target_lines = { "garde moi" }, expected_keys = "dd",
  },
  {
    id = "mo-w-01", title = "Avancer de trois mots puis supprimer jusqu'à la fin de ligne",
    category = "motions", difficulty = 2, hint = "3w puis D",
    start_lines = { "un deux trois quatre cinq" }, start_cursor = { 1, 0 },
    target_lines = { "un deux trois " }, expected_keys = "3wD",
  },
  {
    id = "mo-G-01", title = "Aller à la dernière ligne et la dupliquer",
    category = "motions", difficulty = 2, hint = "G puis yyp",
    start_lines = { "a", "b", "c" }, start_cursor = { 1, 0 },
    target_lines = { "a", "b", "c", "c" }, expected_keys = "Gyyp",
  },
}
