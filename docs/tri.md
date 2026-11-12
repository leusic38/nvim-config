# Tri de l'ancienne config LazyVim

Généré par `tools/inventaire.lua`. Cocher `[x]` ce qui doit être repris dans neovimanu.
Les lignes « perso » sont pré-cochées. Doublons natifs de Neovim 0.12 : `gr`↔`grr`,
`<leader>ca`↔`gra`, `<leader>cr`↔`grn`, `gI`↔`gri` — les cocher les ajoute en alias,
ne pas les cocher garde seulement la touche native.

## Raccourcis — fenêtres
| ✔ | Mode | Touche | Description | Origine |
|---|------|--------|-------------|---------|
| [x] | n | `<C-Down>` | Decrease Window Height | LazyVim |
| [x] | n | `<C-H>` | Go to Left Window | plugin snacks.nvim |
| [x] | n | `<C-J>` | Go to Lower Window | plugin snacks.nvim |
| [x] | n | `<C-K>` | Go to Upper Window | plugin snacks.nvim |
| [x] | n | `<C-L>` | Go to Right Window | plugin snacks.nvim |
| [x] | n | `<C-Left>` | Decrease Window Width | LazyVim |
| [x] | n | `<C-Right>` | Increase Window Width | LazyVim |
| [x] | n | `<C-Up>` | Increase Window Height | LazyVim |
| [x] | n | `<C-W><Space>` | Window Hydra Mode (which-key) | plugin which-key.nvim |
| [x] | n | `<leader>-` | Split Window Below | perso |
| [x] | n | `<leader>bD` | Delete Buffer and Window | LazyVim |
| [x] | n | `<leader>wd` | Delete Window | LazyVim |
| [ ] | n | `<leader>wm` | Toggle Zoom Mode | LazyVim |
| [x] | n | `<leader><Bar>` | Split Window Right | LazyVim |

## Raccourcis — buffers
| ✔ | Mode | Touche | Description | Origine |
|---|------|--------|-------------|---------|
| [x] | n | `<leader>,` | Switch Buffer | LazyVim (extra editor.fzf) |
| [ ] | n | `<leader>.` | Toggle Scratch Buffer | LazyVim |
| [x] | n | `<leader><Tab><Tab>` | New Tab | LazyVim |
| [x] | n | `<leader><Tab>[` | Previous Tab | LazyVim |
| [x] | n | `<leader><Tab>]` | Next Tab | LazyVim |
| [x] | n | `<leader><Tab>d` | Close Tab | LazyVim |
| [x] | n | `<leader><Tab>f` | First Tab | LazyVim |
| [x] | n | `<leader><Tab>l` | Last Tab | LazyVim |
| [x] | n | `<leader><Tab>o` | Close Other Tabs | LazyVim |
| [x] | n | `<leader>?` | Buffer Keymaps (which-key) | LazyVim |
| [x] | n | `<leader>Df` | DB: Find buffer | perso |
| [x] | n | `<leader>Dr` | DB: Rename buffer | perso |
| [ ] | n | `<leader>S` | Select Scratch Buffer | LazyVim |
| [x] | n | `<leader>`` | Switch to Other Buffer | LazyVim |
| [x] | n | `<leader>bP` | Delete Non-Pinned Buffers | LazyVim |
| [x] | n | `<leader>bb` | Switch to Other Buffer | LazyVim |
| [x] | n | `<leader>bd` | Delete Buffer | LazyVim |
| [ ] | n | `<leader>be` | Buffer Explorer | LazyVim (extra editor.neo-tree) |
| [x] | n | `<leader>bi` | Delete Invisible Buffers | LazyVim |
| [x] | n | `<leader>bj` | Pick Buffer | LazyVim |
| [x] | n | `<leader>bl` | Delete Buffers to the Left | LazyVim |
| [x] | n | `<leader>bo` | Delete Other Buffers | LazyVim |
| [x] | n | `<leader>bp` | Toggle Pin | LazyVim |
| [x] | n | `<leader>br` | Delete Buffers to the Right | LazyVim |
| [ ] | n | `<leader>dps` | Profiler Scratch Buffer | LazyVim |
| [x] | n | `<leader>fB` | Buffers (all) | LazyVim (extra editor.fzf) |
| [x] | n | `<leader>fb` | Buffers | LazyVim (extra editor.fzf) |
| [x] | n | `<leader>sD` | Buffer Diagnostics | LazyVim (extra editor.fzf) |
| [x] | n | `<leader>sb` | Buffer Lines | LazyVim (extra editor.fzf) |
| [x] | n | `<leader>uF` | Toggle Auto Format (Buffer) | LazyVim |
| [x] | n | `<leader>xX` | Buffer Diagnostics (Trouble) | LazyVim |
| [x] | n | `H` | Prev Buffer | LazyVim |
| [x] | n | `L` | Next Buffer | LazyVim |
| [x] | n | `[B` | Move buffer prev | LazyVim |
| [x] | n | `[b` | Prev Buffer | LazyVim |
| [x] | n | `]B` | Move buffer next | LazyVim |
| [x] | n | `]b` | Next Buffer | LazyVim |

## Raccourcis — fichiers
| ✔ | Mode | Touche | Description | Origine |
|---|------|--------|-------------|---------|
| [x] | n | `-` | Open parent directory | perso |
| [x] | nxi | `<C-S>` | Save File | plugin snacks.nvim |
| [x] | n | `<leader><Space>` | Find Files (Root Dir) | perso |
| [x] | x | `<leader>RF` | Refactoring: Extract block to file | perso |
| [x] | x | `<leader>Rf` | Refactoring: Extract function to file | perso |
| [x] | n | `<leader>e` | Open parent directory floating | perso |
| [ ] | n | `<leader>fE` | Explorer NeoTree (cwd) | LazyVim (extra editor.neo-tree) |
| [x] | n | `<leader>fF` | Find Files (cwd) | LazyVim (extra editor.fzf) |
| [x] | n | `<leader>fR` | Recent (cwd) | LazyVim (extra editor.fzf) |
| [x] | n | `<leader>fc` | Find Config File | LazyVim (extra editor.fzf) |
| [ ] | n | `<leader>fe` | Explorer NeoTree (Root Dir) | LazyVim (extra editor.neo-tree) |
| [x] | n | `<leader>ff` | Find Files (Root Dir) | LazyVim (extra editor.fzf) |
| [x] | n | `<leader>fn` | New file | LazyVim |
| [x] | n | `<leader>fr` | Recent | LazyVim (extra editor.fzf) |
| [x] | n | `<leader>pp` | PHPActor Copy File | perso |
| [x] | n | `<leader>yn` | Copy file name | perso |

## Raccourcis — recherche
| ✔ | Mode | Touche | Description | Origine |
|---|------|--------|-------------|---------|
| [x] | ni | `<Esc>` | Escape and Clear hlsearch | LazyVim |
| [x] | n | `<leader>/` | Grep (Root Dir) | LazyVim (extra vscode) |
| [x] | n | `<leader>:` | Command History | LazyVim (extra editor.fzf) |
| [x] | n | `<leader>s"` | Registers | LazyVim (extra editor.fzf) |
| [x] | n | `<leader>s/` | Search History | LazyVim (extra editor.fzf) |
| [x] | n | `<leader>sC` | Commands | LazyVim (extra editor.fzf) |
| [x] | n | `<leader>sG` | Grep (cwd) | LazyVim (extra editor.fzf) |
| [x] | n | `<leader>sH` | Search Highlight Groups | LazyVim (extra editor.fzf) |
| [x] | n | `<leader>sM` | Man Pages | LazyVim (extra editor.fzf) |
| [x] | n | `<leader>sR` | Resume | LazyVim (extra editor.fzf) |
| [x] | n | `<leader>sS` | Goto Symbol (Workspace) | LazyVim (extra editor.fzf) |
| [x] | n | `<leader>sT` | Todo/Fix/Fixme | LazyVim |
| [x] | nx | `<leader>sW` | Word (cwd) | LazyVim (extra editor.fzf) |
| [x] | n | `<leader>sa` | Auto Commands | LazyVim (extra editor.fzf) |
| [x] | n | `<leader>sc` | Command History | LazyVim (extra editor.fzf) |
| [x] | n | `<leader>sd` | Diagnostics | LazyVim (extra editor.fzf) |
| [x] | n | `<leader>sg` | Grep (Root Dir) | LazyVim (extra editor.fzf) |
| [x] | n | `<leader>sh` | Help Pages | LazyVim (extra editor.fzf) |
| [x] | n | `<leader>sj` | Jumplist | LazyVim (extra editor.fzf) |
| [x] | n | `<leader>sk` | Key Maps | LazyVim (extra editor.fzf) |
| [x] | n | `<leader>sl` | Location List | LazyVim (extra editor.fzf) |
| [x] | n | `<leader>sm` | Jump to Mark | LazyVim (extra editor.fzf) |
| [ ] | n | `<leader>sn` | +noice | LazyVim |
| [ ] | n | `<leader>sna` | Noice All | LazyVim |
| [ ] | n | `<leader>snd` | Dismiss All | LazyVim |
| [ ] | n | `<leader>snh` | Noice History | LazyVim |
| [ ] | n | `<leader>snl` | Noice Last Message | LazyVim |
| [ ] | n | `<leader>snt` | Noice Picker (Telescope/FzfLua) | LazyVim |
| [x] | n | `<leader>sq` | Quickfix List | LazyVim (extra editor.fzf) |
| [x] | nx | `<leader>sr` | Search and Replace | LazyVim |
| [x] | n | `<leader>ss` | Goto Symbol | LazyVim (extra vscode) |
| [x] | n | `<leader>st` | Todo | LazyVim |
| [x] | nx | `<leader>sw` | Word (Root Dir) | LazyVim (extra editor.fzf) |
| [x] | nxo | `N` | Prev Search Result | LazyVim |
| [x] | xo | `R` | Treesitter Search | LazyVim |
| [x] | nxo | `n` | Next Search Result | perso |

## Raccourcis — code/LSP
| ✔ | Mode | Touche | Description | Origine |
|---|------|--------|-------------|---------|
| [x] | i | `<C-K>` | Signature Help | LazyVim (LSP) |
| [x] | n | `<M-n>` | Next Reference | LazyVim (LSP) |
| [x] | n | `<M-p>` | Prev Reference | LazyVim (LSP) |
| [x] | n | `<leader>cA` | Source Action | LazyVim (LSP) |
| [x] | n | `<leader>cC` | Refresh & Display Codelens | LazyVim (LSP) |
| [x] | n | `<leader>cD` | Fix all diagnostics (vtsls) | LazyVim (extra lang.typescript.vtsls) |
| [x] | nx | `<leader>cF` | Format Injected Langs | LazyVim |
| [x] | n | `<leader>cM` | Add missing imports (vtsls) | LazyVim (extra lang.typescript.vtsls) |
| [x] | n | `<leader>cR` | Rename File | LazyVim (LSP) |
| [x] | n | `<leader>cS` | LSP references/definitions/... (Trouble) | LazyVim |
| [x] | n | `<leader>cV` | Select TS workspace version (vtsls) | LazyVim (extra lang.typescript.vtsls) |
| [x] | nx | `<leader>ca` | Code Action | LazyVim (LSP) |
| [x] | nx | `<leader>cc` | Run Codelens | LazyVim (LSP) |
| [x] | nx | `<leader>cf` | Format | LazyVim |
| [x] | n | `<leader>cl` | Lsp Info | LazyVim (LSP) |
| [x] | n | `<leader>cm` | Mason | LazyVim |
| [x] | n | `<leader>co` | Organize Imports | LazyVim (LSP) |
| [x] | n | `<leader>cr` | Rename | LazyVim (LSP) |
| [x] | n | `<leader>cs` | Symbols (Trouble) | LazyVim |
| [x] | n | `<leader>jla` | JS: Add missing imports (vtsls) | perso |
| [x] | n | `<leader>jlg` | JS: Go to source definition (vtsls) | perso |
| [x] | n | `<leader>jlo` | JS: Organize imports (vtsls) | perso |
| [x] | n | `<leader>jlr` | JS: Rename file (vtsls) | perso |
| [x] | n | `<leader>jls` | JS: Sort imports (vtsls) | perso |
| [x] | n | `<leader>jlu` | JS: Remove unused imports (vtsls) | perso |
| [x] | n | `<leader>xL` | Location List (Trouble) | LazyVim |
| [x] | n | `<leader>xQ` | Quickfix List (Trouble) | LazyVim |
| [x] | n | `<leader>xT` | Todo/Fix/Fixme (Trouble) | LazyVim |
| [x] | n | `<leader>xl` | Location List | LazyVim |
| [x] | n | `<leader>xq` | Quickfix List | LazyVim |
| [x] | n | `<leader>xt` | Todo (Trouble) | LazyVim |
| [x] | n | `<leader>xx` | Diagnostics (Trouble) | LazyVim |
| [x] | n | `K` | Hover | LazyVim (LSP) |
| [x] | n | `[[` | Prev Reference | LazyVim (LSP) |
| [x] | n | `[d` | Prev Diagnostic | LazyVim |
| [x] | n | `[e` | Prev Error | LazyVim |
| [x] | n | `[q` | Previous Trouble/Quickfix Item | LazyVim |
| [x] | n | `[w` | Prev Warning | LazyVim |
| [x] | n | `]]` | Next Reference | LazyVim (LSP) |
| [x] | n | `]d` | Next Diagnostic | LazyVim |
| [x] | n | `]e` | Next Error | LazyVim |
| [x] | n | `]q` | Next Trouble/Quickfix Item | LazyVim |
| [x] | n | `]w` | Next Warning | LazyVim |
| [x] | n | `gD` | Goto Declaration | LazyVim (LSP) |
| [x] | n | `gD` | Goto Source Definition (vtsls) | LazyVim |
| [x] | n | `gI` | Goto Implementation | LazyVim (LSP) |
| [x] | n | `gK` | Signature Help | LazyVim (LSP) |
| [x] | n | `gR` | File References (vtsls) | LazyVim (extra lang.typescript.vtsls) |
| [x] | n | `gd` | Goto Definition | LazyVim (LSP) |
| [x] | n | `gr` | References | LazyVim (LSP) |
| [x] | n | `gy` | Goto T[y]pe Definition | LazyVim (LSP) |

## Raccourcis — git
| ✔ | Mode | Touche | Description | Origine |
|---|------|--------|-------------|---------|
| [x] | n | `<leader>fg` | Find Files (git-files) | LazyVim (extra editor.fzf) |
| [ ] | nx | `<leader>gB` | Git Browse (open) | LazyVim |
| [x] | n | `<leader>gD` | Fermer Diff View | perso |
| [x] | n | `<leader>gF` | Historique fichier (diff) | perso |
| [x] | n | `<leader>gG` | Lazygit (cwd) | LazyVim |
| [x] | n | `<leader>gL` | Git Log (cwd) | LazyVim |
| [x] | n | `<leader>gS` | Git Stash | LazyVim (extra editor.fzf) |
| [ ] | nx | `<leader>gY` | Git Browse (copy) | LazyVim |
| [x] | n | `<leader>gb` | Git Blame Line | LazyVim |
| [x] | n | `<leader>gc` | Commits | perso |
| [x] | n | `<leader>gd` | Diff View (HEAD) | perso |
| [ ] | n | `<leader>ge` | Git Explorer | LazyVim (extra editor.neo-tree) |
| [x] | n | `<leader>gf` | Git Current File History | LazyVim |
| [x] | n | `<leader>gg` | Lazygit (Root Dir) | LazyVim |
| [x] | n | `<leader>gl` | Commits | LazyVim |
| [x] | n | `<leader>gs` | Status | LazyVim (extra editor.fzf) |

## Raccourcis — terminal
| ✔ | Mode | Touche | Description | Origine |
|---|------|--------|-------------|---------|
| [x] | nt | `<C-/>` | Terminal (Root Dir) | LazyVim |
| [x] | nt | `<C-Bslash>` | Toggle floating terminal | perso |
| [x] | nt | `<C-_>` | which_key_ignore | plugin snacks.nvim |
| [x] | n | `<leader>aa` | Open Claude in terminal | perso |
| [x] | n | `<leader>fT` | Terminal (cwd) | LazyVim |
| [x] | n | `<leader>ft` | Terminal (Root Dir) | LazyVim |
| [x] | n | `<leader>od` | Lazydocker (conteneurs) | perso |
| [x] | n | `<leader>tf` | Float Terminal | plugin flash.nvim |
| [x] | n | `<leader>th` | Horizontal Terminal | plugin flash.nvim |
| [x] | n | `<leader>tv` | Vertical Terminal | plugin flash.nvim |

## Raccourcis — ui/toggles
| ✔ | Mode | Touche | Description | Origine |
|---|------|--------|-------------|---------|
| [x] | n | `<leader>uA` | Toggle Tabline | LazyVim |
| [x] | n | `<leader>uC` | Colorscheme with Preview | LazyVim (extra editor.fzf) |
| [ ] | n | `<leader>uD` | Toggle Dimming | LazyVim |
| [x] | n | `<leader>uI` | Inspect Tree | LazyVim |
| [x] | n | `<leader>uL` | Toggle Relative Number | LazyVim |
| [ ] | n | `<leader>uS` | Toggle Smooth Scroll | LazyVim |
| [x] | n | `<leader>uT` | Toggle Treesitter Highlight | LazyVim |
| [ ] | n | `<leader>uZ` | Toggle Zoom Mode | LazyVim |
| [ ] | n | `<leader>ua` | Toggle Animations | LazyVim |
| [x] | n | `<leader>ub` | Toggle Dark Background | LazyVim |
| [x] | n | `<leader>uc` | Toggle Conceal Level | LazyVim |
| [x] | n | `<leader>ud` | Toggle Diagnostics | LazyVim |
| [x] | n | `<leader>uf` | Toggle Auto Format (Global) | LazyVim |
| [ ] | n | `<leader>ug` | Toggle Indent Guides | LazyVim |
| [x] | n | `<leader>uh` | Toggle Inlay Hints | LazyVim |
| [x] | n | `<leader>ul` | Toggle Line Numbers | LazyVim |
| [ ] | n | `<leader>un` | Dismiss All Notifications | LazyVim |
| [x] | n | `<leader>up` | Toggle Mini Pairs | LazyVim |
| [x] | n | `<leader>ur` | Redraw / Clear hlsearch / Diff Update | LazyVim |
| [x] | n | `<leader>us` | Toggle Spelling | LazyVim |
| [x] | n | `<leader>uw` | Toggle Wrap | LazyVim |
| [ ] | n | `<leader>uz` | Toggle Zen Mode | LazyVim |

## Raccourcis — édition
| ✔ | Mode | Touche | Description | Origine |
|---|------|--------|-------------|---------|
| [x] | n | `<C-A>` | Select All | perso |
| [x] | nxo | `<C-Space>` | Treesitter Incremental Selection | LazyVim |
| [x] | ni | `<CR>` | Add line above and move cursor on | perso |
| [x] | nxi | `<M-j>` | Move Down | LazyVim |
| [x] | nxi | `<M-k>` | Move Up | LazyVim |
| [x] | n | `<S-CR>` | Add line before and move cursor on | perso |
| [x] | x | `<leader>Rb` | Refactoring: Extract block | perso |
| [x] | x | `<leader>Re` | Refactoring: Extract function | perso |
| [x] | nx | `<leader>Ri` | Refactoring: Inline variable | perso |
| [x] | nx | `<leader>Rm` | Refactoring: Menu | perso |
| [x] | x | `<leader>Rv` | Refactoring: Extract variable | perso |
| [x] | n | `<leader>qS` | Select Session | LazyVim |
| [x] | n | `<leader>qd` | Don't Save Current Session | LazyVim |
| [x] | n | `<leader>rb` | REST: Open scratchpad | perso |
| [x] | n | `<leader>rc` | REST: Copy as cURL | perso |
| [x] | n | `<leader>re` | REST: Switch environment | perso |
| [x] | n | `<leader>rr` | REST: Replay last request | perso |
| [x] | nx | `<leader>rs` | REST: Send request | perso |
| [x] | x | `<lt>` |  | LazyVim |
| [x] | x | `>` |  | LazyVim |
| [x] | nxo | `S` | Flash Treesitter | LazyVim |
| [x] | n | `[t` | Previous Todo Comment | LazyVim |
| [x] | n | `]t` | Next Todo Comment | LazyVim |
| [x] | n | `g[` | Move to left "around" | plugin which-key.nvim |
| [x] | xo | `g[` | Move to left "around" | plugin mini.ai |
| [x] | xo | `g]` | Move to right "around" | plugin mini.ai |
| [x] | n | `g]` | Move to right "around" | plugin which-key.nvim |
| [x] | n | `gcO` | Add Comment Above | LazyVim |
| [x] | n | `gco` | Add Comment Below | LazyVim |
| [x] | o | `r` | Remote Flash | LazyVim |
| [x] | nxo | `s` | Flash | LazyVim |
| [x] | n | `zug` | Remove word from dictionary | plugin which-key.nvim |

## Raccourcis — debug/tests
| ✔ | Mode | Touche | Description | Origine |
|---|------|--------|-------------|---------|
| [x] | n | `<leader>dB` | Breakpoint Condition | LazyVim (extra dap.core) |
| [x] | n | `<leader>dC` | Run to Cursor | LazyVim (extra dap.core) |
| [x] | n | `<leader>dO` | Step Over | LazyVim (extra dap.core) |
| [x] | n | `<leader>dP` | Pause | LazyVim (extra dap.core) |
| [x] | n | `<leader>dU` | DAP: Toggle UI complet | perso |
| [x] | n | `<leader>da` | Run with Args | LazyVim (extra dap.core) |
| [x] | n | `<leader>db` | Toggle Breakpoint | LazyVim (extra dap.core) |
| [x] | n | `<leader>dc` | Run/Continue | LazyVim (extra dap.core) |
| [x] | nx | `<leader>de` | Eval | LazyVim (extra dap.core) |
| [x] | n | `<leader>dg` | Go to Line (No Execute) | LazyVim (extra dap.core) |
| [x] | n | `<leader>di` | Step Into | LazyVim (extra dap.core) |
| [x] | n | `<leader>dj` | Down | LazyVim (extra dap.core) |
| [x] | n | `<leader>dk` | Up | LazyVim (extra dap.core) |
| [x] | n | `<leader>dl` | Run Last | LazyVim (extra dap.core) |
| [x] | n | `<leader>do` | Step Out | LazyVim (extra dap.core) |
| [ ] | n | `<leader>dph` | Toggle Profiler Highlights | LazyVim |
| [ ] | n | `<leader>dpp` | Toggle Profiler | LazyVim |
| [x] | n | `<leader>dr` | Toggle REPL | LazyVim (extra dap.core) |
| [x] | n | `<leader>ds` | Session | LazyVim (extra dap.core) |
| [x] | n | `<leader>dt` | Terminate | LazyVim (extra dap.core) |
| [x] | n | `<leader>du` | DAP: Toggle UI compact | perso |
| [x] | n | `<leader>dw` | Widgets | LazyVim (extra dap.core) |
| [x] | n | `<leader>tX` | NvimTrainer: stats | perso |
| [x] | n | `<leader>tx` | NvimTrainer: démarrer | perso |

## Raccourcis — IA
| ✔ | Mode | Touche | Description | Origine |
|---|------|--------|-------------|---------|
| [x] | n | `<leader>aS` | Sidekick: choisir une session | perso |
| [x] | n | `<leader>aW` | Worktree: créer + Claude | perso |
| [x] | n | `<leader>ad` | Sidekick: détacher une session | perso |
| [x] | nx | `<leader>aej` | Claude Expert JS/TS/Vue | perso |
| [x] | nx | `<leader>aek` | Claude Expert Kotlin | perso |
| [x] | nx | `<leader>aep` | Claude Expert PHP | perso |
| [x] | nx | `<leader>aet` | Claude Expert Terraform | perso |
| [x] | n | `<leader>af` | Claude: envoyer le fichier | perso |
| [x] | nx | `<leader>ai` | Claude: prompts | perso |
| [x] | nx | `<leader>ap` | Claude Expert (auto) | perso |
| [x] | x | `<leader>aq` | Send selection to Claude | perso |
| [x] | n | `<leader>ar` | Code Review with Claude | perso |
| [x] | n | `<leader>as` | Claude (sidekick) du worktree | perso |
| [x] | nx | `<leader>at` | Claude: envoyer ceci | perso |
| [x] | x | `<leader>av` | Claude: envoyer la sélection | perso |
| [x] | n | `<leader>aw` | Worktree: changer | perso |
| [x] | n | `<leader>ax` | Worktree: supprimer | perso |
| [x] | nx | `<leader>yc` | Yank for Claude format | perso |

## Raccourcis — langages
| ✔ | Mode | Touche | Description | Origine |
|---|------|--------|-------------|---------|
| [x] | n | `<leader>Cd` | Composer: dump-autoload [php] | perso |
| [x] | n | `<leader>Ci` | Composer: install [php] | perso |
| [x] | n | `<leader>Cr` | Composer: require [php] | perso |
| [x] | n | `<leader>Cu` | Composer: update [php] | perso |
| [ ] | nxo | `<leader>a` |  [terraform] | LazyVim (extra ai.claudecode) |
| [x] | n | `<leader>cp` | Markdown Preview [markdown] | LazyVim (extra lang.elixir) |
| [x] | nxo | `<leader>e` |  [terraform] | perso |
| [x] | n | `<leader>gc` | Conventional Commit [gitcommit] | perso |
| [x] | n | `<leader>ja` | JS: Async function template [javascript] | perso |
| [x] | n | `<leader>jc` | JS: Component template [javascript] | perso |
| [x] | n | `<leader>jce` | JS: console.error [javascript] | perso |
| [x] | n | `<leader>jci` | JS: console.info [javascript] | perso |
| [x] | n | `<leader>jcl` | JS: console.log [javascript] | perso |
| [x] | n | `<leader>jcw` | JS: console.warn [javascript] | perso |
| [x] | n | `<leader>jdb` | JS: Toggle breakpoint [javascript] | perso |
| [x] | n | `<leader>jdc` | JS: Continue [javascript] | perso |
| [x] | n | `<leader>jdi` | JS: Step into [javascript] | perso |
| [x] | n | `<leader>jdl` | JS: Run last [javascript] | perso |
| [x] | n | `<leader>jdo` | JS: Step out [javascript] | perso |
| [x] | n | `<leader>jdr` | JS: Open REPL [javascript] | perso |
| [x] | n | `<leader>jds` | JS: Step over [javascript] | perso |
| [x] | n | `<leader>jf` | JS: Function template [javascript] | perso |
| [x] | n | `<leader>jle` | JS: Fix all ESLint issues [javascript] | perso |
| [x] | n | `<leader>jnb` | JS: npm run build [javascript] | perso |
| [x] | n | `<leader>jnd` | JS: npm run dev [javascript] | perso |
| [x] | n | `<leader>jni` | JS: npm install [javascript] | perso |
| [x] | n | `<leader>jnr` | JS: npm run [javascript] | perso |
| [x] | n | `<leader>jnt` | JS: npm test [javascript] | perso |
| [x] | n | `<leader>jta` | JS: Run all tests in file [javascript] | perso |
| [x] | n | `<leader>jtc` | JS: TypeScript class template [javascript] | perso |
| [x] | n | `<leader>jti` | JS: TypeScript interface template [javascript] | perso |
| [x] | n | `<leader>jtn` | JS: Run nearest test [javascript] | perso |
| [x] | n | `<leader>jto` | JS: Open test output [javascript] | perso |
| [x] | n | `<leader>jts` | JS: Toggle test summary [javascript] | perso |
| [x] | n | `<leader>jtw` | JS: Watch tests [javascript] | perso |
| [x] | nxo | `<leader>k` |  [terraform] | perso |
| [x] | nxo | `<leader>l` |  [terraform] | LazyVim |
| [x] | n | `<leader>mc` | MD: Corriger tous les problèmes [markdown] | perso |
| [x] | n | `<leader>mf` | MD: Format avec Prettier [markdown] | perso |
| [x] | n | `<leader>ml` | MD: Lint avec markdownlint [markdown] | perso |
| [x] | nxo | `<leader>o` |  [terraform] | perso |
| [x] | n | `<leader>pc` | PHP: Class template [php] | perso |
| [x] | n | `<leader>pdB` | PHP: Conditional breakpoint [php] | perso |
| [x] | n | `<leader>pdb` | PHP: Toggle breakpoint [php] | perso |
| [x] | n | `<leader>pdc` | PHP: Continue debugging [php] | perso |
| [x] | n | `<leader>pdi` | PHP: Step into [php] | perso |
| [x] | n | `<leader>pdo` | PHP: Step out [php] | perso |
| [x] | n | `<leader>pdr` | PHP: Open REPL [php] | perso |
| [x] | n | `<leader>pds` | PHP: Step over [php] | perso |
| [x] | n | `<leader>pdt` | PHP: Terminate debugging [php] | perso |
| [x] | n | `<leader>pe` | PHP: Doctrine Entity template [php] | perso |
| [x] | n | `<leader>pf` | PHP: Function template [php] | perso |
| [x] | n | `<leader>plc` | PHP: Format with CS Fixer [php] | perso |
| [x] | n | `<leader>plf` | PHP: Format with LSP [php] | perso |
| [x] | n | `<leader>pll` | PHP: Run PHPStan [php] | perso |
| [x] | n | `<leader>pr` | PHP: Repository template [php] | perso |
| [x] | n | `<leader>ps` | PHP: Service template [php] | perso |
| [x] | n | `<leader>pta` | PHP: Run all tests in file [php] | perso |
| [x] | n | `<leader>ptn` | PHP: Run nearest test [php] | perso |
| [x] | n | `<leader>pto` | PHP: Show test output [php] | perso |
| [x] | n | `<leader>pts` | PHP: Toggle test summary [php] | perso |
| [x] | n | `<leader>pv` | PHP: Insert header with strict types [php] | perso |
| [x] | n | `<leader>v3` | Vue: Composition API template [javascript] | perso |
| [x] | n | `<leader>vc` | Vue: Code actions [javascript] | perso |
| [x] | n | `<leader>vr` | Vue: Rename [javascript] | perso |
| [x] | n | `<leader>vs` | Vue: SFC template [javascript] | perso |
| [x] | n | `<leader>yb` | JS: yarn build [javascript] | perso |
| [x] | n | `<leader>yd` | JS: yarn dev [javascript] | perso |
| [x] | n | `<leader>yi` | JS: yarn install [javascript] | perso |
| [x] | n | `<leader>yr` | JS: yarn run [javascript] | perso |
| [x] | n | `<leader>yt` | JS: yarn test [javascript] | perso |
| [x] | i | `>` |  [javascript] | LazyVim |
| [x] | i | `>` |  [markdown] | LazyVim |
| [x] | i | `>` |  [php] | LazyVim |
| [x] | i | `>` |  [twig] | LazyVim |
| [x] | i | `>` |  [typescript] | LazyVim |
| [x] | i | `>` |  [vue] | LazyVim |
| [x] | i | `>` |  [xml] | LazyVim |
| [x] | nxo | `[A` | Prev Parameter End [dockerfile] | LazyVim |
| [x] | nxo | `[A` | Prev Parameter End [java] | LazyVim |
| [x] | nxo | `[A` | Prev Parameter End [javascript] | LazyVim |
| [x] | nxo | `[A` | Prev Parameter End [json] | LazyVim |
| [x] | nxo | `[A` | Prev Parameter End [kotlin] | LazyVim |
| [x] | nxo | `[A` | Prev Parameter End [lua] | LazyVim |
| [x] | nxo | `[A` | Prev Parameter End [markdown] | LazyVim |
| [x] | nxo | `[A` | Prev Parameter End [php] | LazyVim |
| [x] | nxo | `[A` | Prev Parameter End [twig] | LazyVim |
| [x] | nxo | `[A` | Prev Parameter End [typescript] | LazyVim |
| [x] | nxo | `[A` | Prev Parameter End [vue] | LazyVim |
| [x] | nxo | `[A` | Prev Parameter End [yaml] | LazyVim |
| [x] | nxo | `[C` | Prev Class End [dockerfile] | LazyVim |
| [x] | nxo | `[C` | Prev Class End [java] | LazyVim |
| [x] | nxo | `[C` | Prev Class End [javascript] | LazyVim |
| [x] | nxo | `[C` | Prev Class End [json] | LazyVim |
| [x] | nxo | `[C` | Prev Class End [kotlin] | LazyVim |
| [x] | nxo | `[C` | Prev Class End [lua] | LazyVim |
| [x] | nxo | `[C` | Prev Class End [markdown] | LazyVim |
| [x] | nxo | `[C` | Prev Class End [php] | LazyVim |
| [x] | nxo | `[C` | Prev Class End [twig] | LazyVim |
| [x] | nxo | `[C` | Prev Class End [typescript] | LazyVim |
| [x] | nxo | `[C` | Prev Class End [vue] | LazyVim |
| [x] | nxo | `[C` | Prev Class End [yaml] | LazyVim |
| [x] | nxo | `[F` | Prev Function End [dockerfile] | LazyVim |
| [x] | nxo | `[F` | Prev Function End [java] | LazyVim |
| [x] | nxo | `[F` | Prev Function End [javascript] | LazyVim |
| [x] | nxo | `[F` | Prev Function End [json] | LazyVim |
| [x] | nxo | `[F` | Prev Function End [kotlin] | LazyVim |
| [x] | nxo | `[F` | Prev Function End [lua] | LazyVim |
| [x] | nxo | `[F` | Prev Function End [markdown] | LazyVim |
| [x] | nxo | `[F` | Prev Function End [php] | LazyVim |
| [x] | nxo | `[F` | Prev Function End [twig] | LazyVim |
| [x] | nxo | `[F` | Prev Function End [typescript] | LazyVim |
| [x] | nxo | `[F` | Prev Function End [vue] | LazyVim |
| [x] | nxo | `[F` | Prev Function End [yaml] | LazyVim |
| [x] | nxo | `[a` | Prev Parameter Start [dockerfile] | LazyVim |
| [x] | nxo | `[a` | Prev Parameter Start [java] | LazyVim |
| [x] | nxo | `[a` | Prev Parameter Start [javascript] | LazyVim |
| [x] | nxo | `[a` | Prev Parameter Start [json] | LazyVim |
| [x] | nxo | `[a` | Prev Parameter Start [kotlin] | LazyVim |
| [x] | nxo | `[a` | Prev Parameter Start [lua] | LazyVim |
| [x] | nxo | `[a` | Prev Parameter Start [markdown] | LazyVim |
| [x] | nxo | `[a` | Prev Parameter Start [php] | LazyVim |
| [x] | nxo | `[a` | Prev Parameter Start [twig] | LazyVim |
| [x] | nxo | `[a` | Prev Parameter Start [typescript] | LazyVim |
| [x] | nxo | `[a` | Prev Parameter Start [vue] | LazyVim |
| [x] | nxo | `[a` | Prev Parameter Start [yaml] | LazyVim |
| [x] | nxo | `[c` | Prev Class Start [dockerfile] | LazyVim |
| [x] | nxo | `[c` | Prev Class Start [java] | LazyVim |
| [x] | nxo | `[c` | Prev Class Start [javascript] | LazyVim |
| [x] | nxo | `[c` | Prev Class Start [json] | LazyVim |
| [x] | nxo | `[c` | Prev Class Start [kotlin] | LazyVim |
| [x] | nxo | `[c` | Prev Class Start [lua] | LazyVim |
| [x] | nxo | `[c` | Prev Class Start [markdown] | LazyVim |
| [x] | nxo | `[c` | Prev Class Start [php] | LazyVim |
| [x] | nxo | `[c` | Prev Class Start [twig] | LazyVim |
| [x] | nxo | `[c` | Prev Class Start [typescript] | LazyVim |
| [x] | nxo | `[c` | Prev Class Start [vue] | LazyVim |
| [x] | nxo | `[c` | Prev Class Start [yaml] | LazyVim |
| [x] | nxo | `[f` | Prev Function Start [dockerfile] | LazyVim |
| [x] | nxo | `[f` | Prev Function Start [java] | LazyVim |
| [x] | nxo | `[f` | Prev Function Start [javascript] | LazyVim |
| [x] | nxo | `[f` | Prev Function Start [json] | LazyVim |
| [x] | nxo | `[f` | Prev Function Start [kotlin] | LazyVim |
| [x] | nxo | `[f` | Prev Function Start [lua] | LazyVim |
| [x] | nxo | `[f` | Prev Function Start [markdown] | LazyVim |
| [x] | nxo | `[f` | Prev Function Start [php] | LazyVim |
| [x] | nxo | `[f` | Prev Function Start [twig] | LazyVim |
| [x] | nxo | `[f` | Prev Function Start [typescript] | LazyVim |
| [x] | nxo | `[f` | Prev Function Start [vue] | LazyVim |
| [x] | nxo | `[f` | Prev Function Start [yaml] | LazyVim |
| [x] | nx | `\r` | Run Lua [lua] | LazyVim |
| [x] | nxo | `]A` | Next Parameter End [dockerfile] | LazyVim |
| [x] | nxo | `]A` | Next Parameter End [java] | LazyVim |
| [x] | nxo | `]A` | Next Parameter End [javascript] | LazyVim |
| [x] | nxo | `]A` | Next Parameter End [json] | LazyVim |
| [x] | nxo | `]A` | Next Parameter End [kotlin] | LazyVim |
| [x] | nxo | `]A` | Next Parameter End [lua] | LazyVim |
| [x] | nxo | `]A` | Next Parameter End [markdown] | LazyVim |
| [x] | nxo | `]A` | Next Parameter End [php] | LazyVim |
| [x] | nxo | `]A` | Next Parameter End [twig] | LazyVim |
| [x] | nxo | `]A` | Next Parameter End [typescript] | LazyVim |
| [x] | nxo | `]A` | Next Parameter End [vue] | LazyVim |
| [x] | nxo | `]A` | Next Parameter End [yaml] | LazyVim |
| [x] | nxo | `]C` | Next Class End [dockerfile] | LazyVim |
| [x] | nxo | `]C` | Next Class End [java] | LazyVim |
| [x] | nxo | `]C` | Next Class End [javascript] | LazyVim |
| [x] | nxo | `]C` | Next Class End [json] | LazyVim |
| [x] | nxo | `]C` | Next Class End [kotlin] | LazyVim |
| [x] | nxo | `]C` | Next Class End [lua] | LazyVim |
| [x] | nxo | `]C` | Next Class End [markdown] | LazyVim |
| [x] | nxo | `]C` | Next Class End [php] | LazyVim |
| [x] | nxo | `]C` | Next Class End [twig] | LazyVim |
| [x] | nxo | `]C` | Next Class End [typescript] | LazyVim |
| [x] | nxo | `]C` | Next Class End [vue] | LazyVim |
| [x] | nxo | `]C` | Next Class End [yaml] | LazyVim |
| [x] | nxo | `]F` | Next Function End [dockerfile] | LazyVim |
| [x] | nxo | `]F` | Next Function End [java] | LazyVim |
| [x] | nxo | `]F` | Next Function End [javascript] | LazyVim |
| [x] | nxo | `]F` | Next Function End [json] | LazyVim |
| [x] | nxo | `]F` | Next Function End [kotlin] | LazyVim |
| [x] | nxo | `]F` | Next Function End [lua] | LazyVim |
| [x] | nxo | `]F` | Next Function End [markdown] | LazyVim |
| [x] | nxo | `]F` | Next Function End [php] | LazyVim |
| [x] | nxo | `]F` | Next Function End [twig] | LazyVim |
| [x] | nxo | `]F` | Next Function End [typescript] | LazyVim |
| [x] | nxo | `]F` | Next Function End [vue] | LazyVim |
| [x] | nxo | `]F` | Next Function End [yaml] | LazyVim |
| [x] | nxo | `]a` | Next Parameter Start [dockerfile] | LazyVim |
| [x] | nxo | `]a` | Next Parameter Start [java] | LazyVim |
| [x] | nxo | `]a` | Next Parameter Start [javascript] | LazyVim |
| [x] | nxo | `]a` | Next Parameter Start [json] | LazyVim |
| [x] | nxo | `]a` | Next Parameter Start [kotlin] | LazyVim |
| [x] | nxo | `]a` | Next Parameter Start [lua] | LazyVim |
| [x] | nxo | `]a` | Next Parameter Start [markdown] | LazyVim |
| [x] | nxo | `]a` | Next Parameter Start [php] | LazyVim |
| [x] | nxo | `]a` | Next Parameter Start [twig] | LazyVim |
| [x] | nxo | `]a` | Next Parameter Start [typescript] | LazyVim |
| [x] | nxo | `]a` | Next Parameter Start [vue] | LazyVim |
| [x] | nxo | `]a` | Next Parameter Start [yaml] | LazyVim |
| [x] | nxo | `]c` | Next Class Start [dockerfile] | LazyVim |
| [x] | nxo | `]c` | Next Class Start [java] | LazyVim |
| [x] | nxo | `]c` | Next Class Start [javascript] | LazyVim |
| [x] | nxo | `]c` | Next Class Start [json] | LazyVim |
| [x] | nxo | `]c` | Next Class Start [kotlin] | LazyVim |
| [x] | nxo | `]c` | Next Class Start [lua] | LazyVim |
| [x] | nxo | `]c` | Next Class Start [markdown] | LazyVim |
| [x] | nxo | `]c` | Next Class Start [php] | LazyVim |
| [x] | nxo | `]c` | Next Class Start [twig] | LazyVim |
| [x] | nxo | `]c` | Next Class Start [typescript] | LazyVim |
| [x] | nxo | `]c` | Next Class Start [vue] | LazyVim |
| [x] | nxo | `]c` | Next Class Start [yaml] | LazyVim |
| [x] | nxo | `]f` | Next Function Start [dockerfile] | LazyVim |
| [x] | nxo | `]f` | Next Function Start [java] | LazyVim |
| [x] | nxo | `]f` | Next Function Start [javascript] | LazyVim |
| [x] | nxo | `]f` | Next Function Start [json] | LazyVim |
| [x] | nxo | `]f` | Next Function Start [kotlin] | LazyVim |
| [x] | nxo | `]f` | Next Function Start [lua] | LazyVim |
| [x] | nxo | `]f` | Next Function Start [markdown] | LazyVim |
| [x] | nxo | `]f` | Next Function Start [php] | LazyVim |
| [x] | nxo | `]f` | Next Function Start [twig] | LazyVim |
| [x] | nxo | `]f` | Next Function Start [typescript] | LazyVim |
| [x] | nxo | `]f` | Next Function Start [vue] | LazyVim |
| [x] | nxo | `]f` | Next Function Start [yaml] | LazyVim |

## Raccourcis — autres
| ✔ | Mode | Touche | Description | Origine |
|---|------|--------|-------------|---------|
| [x] | i | `"` | Closeopen action for '""' pair | LazyVim |
| [x] | i | `'` | Closeopen action for "''" pair | LazyVim |
| [x] | i | `(` | Open action for "()" pair | LazyVim |
| [x] | i | `)` | Close action for "()" pair | LazyVim |
| [x] | nxoi | `,` |  | LazyVim |
| [x] | i | `.` |  | LazyVim |
| [x] | nxoi | `;` |  | LazyVim |
| [x] | i | `<BS>` | MiniPairs <BS> | LazyVim |
| [x] | ni | `<C-B>` | Scroll Backward | plugin lazy.nvim |
| [x] | ni | `<C-F>` | Scroll Forward | plugin lazy.nvim |
| [x] | nx | `<Down>` | Down | LazyVim |
| [x] | nx | `<Up>` | Up | LazyVim |
| [x] | n | `<leader>D` | Toggle DBUI | LazyVim (extra lang.sql) |
| [x] | n | `<leader>Da` | DB: Add connection | perso |
| [x] | n | `<leader>Dq` | DB: Last query info | perso |
| [x] | n | `<leader>Du` | DB: Toggle UI | perso |
| [x] | n | `<leader>H` | Manuel (navigateur) | LazyVim (extra editor.harpoon2) |
| [x] | n | `<leader>K` | Show keymaps documentation | perso |
| [ ] | n | `<leader>L` | LazyVim Changelog | LazyVim |
| [x] | n | `<leader>M` | Manuel (Neovim) | perso |
| [x] | n | `<leader>jpc` | JS: Hide package info | perso |
| [x] | n | `<leader>jpd` | JS: Delete package | perso |
| [x] | n | `<leader>jpi` | JS: Install package | perso |
| [x] | n | `<leader>jps` | JS: Show package info | perso |
| [x] | n | `<leader>jpt` | JS: Toggle package info | perso |
| [x] | n | `<leader>jpu` | JS: Update package | perso |
| [x] | n | `<leader>jpv` | JS: Change package version | perso |
| [ ] | n | `<leader>l` | Lazy | LazyVim |
| [ ] | n | `<leader>n` | Notification History | LazyVim |
| [x] | n | `<leader>pE` | PHPActor Expand Class | perso |
| [x] | n | `<leader>pT` | PHPActor Transform | perso |
| [x] | n | `<leader>pi` | PHPActor Import Class | perso |
| [x] | n | `<leader>pm` | PHPActor Context Menu | perso |
| [x] | n | `<leader>pn` | PHPActor New Class | perso |
| [x] | n | `<leader>ql` | Restore Last Session | LazyVim |
| [x] | n | `<leader>qq` | Quit All | LazyVim |
| [x] | n | `<leader>qs` | Restore Session | LazyVim |
| [x] | n | `<leader>yP` | Copy absolute path | perso |
| [x] | n | `<leader>yp` | Copy relative path | perso |
| [x] | nxo | `F` |  | LazyVim (extra editor.leap) |
| [x] | nxo | `T` |  | LazyVim (extra editor.leap) |
| [x] | i | `[` | Open action for "[]" pair | LazyVim |
| [x] | n | `[s` | Previous spelling error | plugin which-key.nvim |
| [x] | i | `]` | Close action for "[]" pair | LazyVim |
| [x] | n | `]s` | Next spelling error | plugin which-key.nvim |
| [x] | i | ``` | Closeopen action for "``" pair | LazyVim |
| [x] | xo | `a` | Around textobject | perso |
| [x] | xo | `al` | Around last textobject | LazyVim |
| [x] | xo | `an` | Around next textobject | LazyVim |
| [x] | nxo | `f` |  | LazyVim |
| [x] | xo | `i` | Inside textobject | LazyVim |
| [x] | xo | `il` | Inside last textobject | LazyVim |
| [x] | xo | `in` | Inside next textobject | LazyVim |
| [x] | nx | `j` | Down | LazyVim |
| [x] | nx | `k` | Up | LazyVim |
| [x] | x | `p` |  | perso |
| [x] | nxo | `t` |  | LazyVim |
| [x] | n | `z=` | Spelling suggestions | plugin which-key.nvim |
| [x] | n | `zg` | Add word to dictionary | plugin which-key.nvim |
| [x] | n | `zw` | Mark word as incorrect | plugin which-key.nvim |
| [x] | i | `{` | Open action for "{}" pair | LazyVim |
| [x] | i | `}` | Close action for "{}" pair | LazyVim |

## Plugins
| ✔ | Plugin | Origine | Rôle |
|---|--------|---------|------|
| [x] | catppuccin | perso | <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/logos/export |
| [x] | fzf-lua | perso | “because you can and you love fzf”  - [@junegunn](https://github.com/junegunn) |
| [x] | neotest | perso | A framework for interacting with tests within NeoVim. |
| [x] | neotest-java | perso | using [JUnit](https://github.com/junit-team/junit5). |
| [x] | neotest-jest | perso | This plugin provides a [jest](https://github.com/jestjs/jest) adapter for the [Neotest](ht |
| [x] | neotest-phpunit | perso | This plugin provides a [PHPUnit](https://phpunit.de) adapter for the [Neotest](https://git |
| [x] | neotest-vitest | perso | This plugin provides a [Vitest](https://vitest.dev/) adapter for the [Neotest](https://git |
| [x] | nvim-dap | perso | `nvim-dap` is a Debug Adapter Protocol client implementation for [Neovim][1]. |
| [x] | nvim-dap-ui | perso | A UI for [nvim-dap](https://github.com/mfussenegger/nvim-dap) which provides a |
| [x] | nvim-dap-virtual-text | perso | This plugin adds virtual text support to [nvim-dap](https://github.com/mfussenegger/nvim-d |
| [x] | nvim-lint | perso | An asynchronous linter plugin for Neovim (>= 0.9.5) complementary to the |
| [x] | nvim-lspconfig | perso | nvim-lspconfig is a collection of LSP server configurations for the [Nvim LSP client](http |
| [x] | nvim-nio | perso | A library for asynchronous IO in Neovim, inspired by the asyncio library in Python. The li |
| [x] | nvim-treesitter | perso | <img src="https://github.com/nvim-treesitter/nvim-treesitter/assets/2361214/0513b223-c902- |
| [x] | nvim-ts-autotag | perso | Use treesitter to **autoclose** and **autorename** html tag |
| [x] | nvim-web-devicons | perso | Provides [Nerd Font](https://www.nerdfonts.com/) [^1] icons (glyphs) for use by *Neovim* p |
| [x] | nvimtrainer | perso | A starter template for [LazyVim](https://github.com/LazyVim/LazyVim). |
| [x] | phpactor | perso | ======== |
| [ ] | syntastic | perso |  |
| [x] | vim-dadbod | perso |  |
| [x] | vim-dadbod-completion | perso | Database auto completion powered by [vim-dadbod](https://github.com/tpope/vim-dadbod). |
| [x] | vim-dadbod-ui | perso | Simple UI for [vim-dadbod](https://github.com/tpope/vim-dadbod). |
| [x] | vim-terraform | perso | This plugin, along with others like it, is now maintained by the |
| [x] | vim-terraform-completion | perso | **IMPORTANT: This plugin now allow version based completion** |
| [x] | nvim-ansible | LazyVim (extra lang.ansible) | ```bash |
| [x] | blink.cmp | LazyVim (cœur) | <h2 align="center">Blink Completion (blink.cmp)</h2> |
| [x] | blink.compat | LazyVim (cœur) | **blink.compat** is a source provider for [blink.cmp](https://github.com/Saghen/blink.cmp) |
| [x] | bufferline.nvim | LazyVim (cœur) | bufferline.nvim |
| [ ] | codeium.nvim | LazyVim (cœur) | <img width="300" alt="Windsurf" src="windsurf.png"/> |
| [x] | conform.nvim | LazyVim (cœur) | Lightweight yet powerful formatter plugin for Neovim |
| [x] | diffview.nvim | LazyVim (cœur) | Single tabpage interface for easily cycling through diffs for all modified files |
| [x] | flash.nvim | LazyVim (cœur) | `flash.nvim` lets you navigate your code with search labels, |
| [x] | friendly-snippets | LazyVim (cœur) | Snippets collection for a set of different programming languages. |
| [x] | gitsigns.nvim | LazyVim (cœur) | Deep buffer integration for Git |
| [x] | grug-far.nvim | LazyVim (cœur) | **F**ind **A**nd **R**eplace plugin for neovim |
| [x] | kulala.nvim | LazyVim (cœur) | A fully-featured ⚡️ HTTP/GraphQL/gRPC/Websocket-client 🐼 |
| [ ] | lazy.nvim | LazyVim (cœur) | <a href="https://lazy.folke.io/installation">Install</a> |
| [ ] | lazydev.nvim | LazyVim (cœur) | **lazydev.nvim** is a plugin that properly configures [LuaLS](https://luals.github.io/) |
| [ ] | LazyVim | LazyVim (cœur) | <img src="https://user-images.githubusercontent.com/292349/213446185-2db63fd5-8c84-459c-9f |
| [x] | lualine.nvim | LazyVim (cœur) | A blazing fast and easy to configure Neovim statusline written in Lua. |
| [x] | markdown-preview.nvim | LazyVim (cœur) | > Powered by ❤️ |
| [ ] | mason-lspconfig.nvim | LazyVim (cœur) | <code>mason-lspconfig</code> bridges <a |
| [x] | mason-nvim-dap.nvim | LazyVim (cœur) | I co-founded a company based in NYC. If you are looking for a job or are interested in lea |
| [x] | mason.nvim | LazyVim (cœur) | <img src="https://user-images.githubusercontent.com/6705160/177613416-0c0354d2-f431-40d8-8 |
| [x] | mini.ai | LazyVim (cœur) | - It enhances some builtin textobjects (like `a(`, `a)`, `a'`, and more), creates new ones |
| [ ] | mini.icons | LazyVim (cœur) | See more details in [Features](#features) and [Documentation](doc/mini-icons.txt). |
| [x] | mini.pairs | LazyVim (cœur) | See more details in [Features](#features) and [Documentation](doc/mini-pairs.txt). |
| [ ] | neo-tree.nvim | LazyVim (cœur) | Neo-tree is a Neovim plugin to browse the file system and other tree like |
| [ ] | noice.nvim | LazyVim (cœur) | Highly experimental plugin that completely replaces the UI for `messages`, `cmdline` and t |
| [ ] | nui.nvim | LazyVim (cœur) | UI Component Library for Neovim. |
| [x] | nvim-treesitter-textobjects | LazyVim (cœur) | Syntax aware text-objects, select, move, swap, and peek support. |
| [x] | oil.nvim | LazyVim (cœur) | A [vim-vinegar](https://github.com/tpope/vim-vinegar) like file explorer that lets you edi |
| [x] | package-info.nvim | LazyVim (cœur) | - Display latest dependency versions as virtual text |
| [x] | persistence.nvim | LazyVim (cœur) | **Persistence** is a simple lua plugin for automated session management. |
| [x] | persistent-breakpoints.nvim | LazyVim (cœur) | persistent-breakpoints is a lua plugin for Neovim to save the [nvim-dap](https://github.co |
| [x] | php.vim | LazyVim (cœur) | ======= |
| [x] | plenary.nvim | LazyVim (cœur) | --- |
| [x] | refactoring.nvim | LazyVim (cœur) | <h1>refactoring.nvim</h1> |
| [x] | render-markdown.nvim | LazyVim (cœur) | Improve viewing Markdown in Neovim |
| [x] | SchemaStore.nvim | LazyVim (cœur) | A Neovim plugin that provides the [SchemaStore](https://github.com/SchemaStore/schemastore |
| [x] | sidekick.nvim | LazyVim (cœur) | **sidekick.nvim** is your Neovim AI sidekick that integrates Copilot LSP's |
| [ ] | snacks.nvim | LazyVim (cœur) | A collection of small QoL plugins for Neovim. |
| [ ] | telescope-cc.nvim | LazyVim (cœur) | A Telescope integration of [Conventional Commits](https://www.conventionalcommits.org/). |
| [ ] | telescope-terraform-doc.nvim | LazyVim (cœur) | `telescope-terraform-doc.nvim` is an extension for [telescope.nvim](https://github.com/nvi |
| [ ] | telescope.nvim | LazyVim (cœur) | Gaze deeply into unknown regions using the power of the moon. |
| [x] | todo-comments.nvim | LazyVim (cœur) | **todo-comments** is a lua plugin for Neovim >= 0.8.0 to highlight and search for todo com |
| [x] | toggleterm.nvim | LazyVim (cœur) | toggleterm.nvim |
| [x] | neotest-pest | LazyVim (extra lang.php) | This plugin provides a [Pest](https://pestphp.com) adapter for the [Neotest](https://githu |
| [ ] | tokyonight.nvim | LazyVim (cœur) | A dark and light [Neovim](https://github.com/neovim/neovim) theme written in |
| [x] | trouble.nvim | LazyVim (cœur) | A pretty list for showing diagnostics, references, telescope results, quickfix and locatio |
| [x] | ts-comments.nvim | LazyVim (cœur) | Tiny plugin to enhance Neovim's native comments: |
| [x] | nvim-jdtls | LazyVim (extra lang.java) | Extensions for the built-in [Language Server Protocol][1] support in [Neovim][2] (>= 0.6.0 |
| [x] | which-key.nvim | LazyVim (cœur) | **WhichKey** helps you remember your Neovim keymaps, by showing available keybindings |
| [x] | yank-for-claude.nvim | LazyVim (cœur) | A Neovim plugin that yanks code references in Claude AI's preferred format (`@filename#L10 |
