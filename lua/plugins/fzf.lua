return {
  {
    "ibhagwan/fzf-lua",
    opts = {
      fzf_opts = {
        ["--ignore-case"] = "",
      },
      defaults = {
        formatter = "path.filename_first",
      },
      files = {
        fd_opts = [[--color=never --type f --type l --hidden --no-ignore --exclude .git --exclude .jj --exclude node_modules --exclude vendor --exclude dist --exclude .next --exclude build --exclude cache --exclude .claude]],
      },
    },
  },
}
