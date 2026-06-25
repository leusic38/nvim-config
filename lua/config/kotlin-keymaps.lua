-- Kotlin-specific keymaps
-- Loaded automatically when editing Kotlin files

local wk = require("which-key")

-- Testing keymaps (prefix: <leader>kt)
wk.add({
  { "<leader>k", group = "Kotlin" },
  { "<leader>kt", group = "Testing" },
  {
    "<leader>kta",
    function()
      require("neotest").run.run(vim.fn.expand("%"))
    end,
    desc = "Run all tests in file",
  },
  {
    "<leader>ktn",
    function()
      require("neotest").run.run()
    end,
    desc = "Run nearest test",
  },
  {
    "<leader>kts",
    function()
      require("neotest").summary.toggle()
    end,
    desc = "Toggle test summary",
  },
  {
    "<leader>kto",
    function()
      require("neotest").output.open({ enter = true })
    end,
    desc = "Show test output",
  },
  {
    "<leader>ktw",
    function()
      require("neotest").watch.toggle(vim.fn.expand("%"))
    end,
    desc = "Watch tests",
  },
})

-- Debugging keymaps (prefix: <leader>kd)
wk.add({
  { "<leader>kd", group = "Debug" },
  {
    "<leader>kdb",
    function()
      require("dap").toggle_breakpoint()
    end,
    desc = "Toggle breakpoint",
  },
  {
    "<leader>kdc",
    function()
      require("dap").continue()
    end,
    desc = "Continue",
  },
  {
    "<leader>kds",
    function()
      require("dap").step_over()
    end,
    desc = "Step over",
  },
  {
    "<leader>kdi",
    function()
      require("dap").step_into()
    end,
    desc = "Step into",
  },
  {
    "<leader>kdo",
    function()
      require("dap").step_out()
    end,
    desc = "Step out",
  },
  {
    "<leader>kdr",
    function()
      require("dap").repl.open()
    end,
    desc = "Open REPL",
  },
  {
    "<leader>kdt",
    function()
      require("dap").terminate()
    end,
    desc = "Terminate",
  },
})

-- LSP and Code Quality (prefix: <leader>kl)
wk.add({
  { "<leader>kl", group = "Code Quality" },
  {
    "<leader>klf",
    function()
      vim.lsp.buf.format({ async = true })
    end,
    desc = "Format with LSP",
  },
  {
    "<leader>klk",
    function()
      require("conform").format({ formatters = { "ktlint" }, async = true })
    end,
    desc = "Format with ktlint",
  },
  {
    "<leader>kll",
    function()
      require("lint").try_lint()
    end,
    desc = "Run ktlint",
  },
})

-- Gradle commands (prefix: <leader>kg)
wk.add({
  { "<leader>kg", group = "Gradle" },
  {
    "<leader>kgb",
    function()
      vim.cmd("terminal ./gradlew build")
    end,
    desc = "Gradle build",
  },
  {
    "<leader>kgt",
    function()
      vim.cmd("terminal ./gradlew test")
    end,
    desc = "Gradle test",
  },
  {
    "<leader>kgc",
    function()
      vim.cmd("terminal ./gradlew clean")
    end,
    desc = "Gradle clean",
  },
  {
    "<leader>kgr",
    function()
      local task = vim.fn.input("Gradle task: ")
      if task ~= "" then
        vim.cmd("terminal ./gradlew " .. task)
      end
    end,
    desc = "Gradle run task",
  },
  {
    "<leader>kgd",
    function()
      vim.cmd("terminal ./gradlew dependencies")
    end,
    desc = "Gradle dependencies",
  },
})

-- Maven commands (prefix: <leader>km)
wk.add({
  { "<leader>km", group = "Maven" },
  {
    "<leader>kmb",
    function()
      vim.cmd("terminal mvn compile")
    end,
    desc = "Maven build",
  },
  {
    "<leader>kmt",
    function()
      vim.cmd("terminal mvn test")
    end,
    desc = "Maven test",
  },
  {
    "<leader>kmc",
    function()
      vim.cmd("terminal mvn clean")
    end,
    desc = "Maven clean",
  },
  {
    "<leader>kmi",
    function()
      vim.cmd("terminal mvn install")
    end,
    desc = "Maven install",
  },
  {
    "<leader>kmp",
    function()
      vim.cmd("terminal mvn package")
    end,
    desc = "Maven package",
  },
})

-- Code snippets (prefix: <leader>k)
wk.add({
  {
    "<leader>kc",
    function()
      local lines = {
        "package " .. vim.fn.input("Package name: "),
        "",
        "class " .. vim.fn.input("Class name: ") .. " {",
        "    ",
        "}",
      }
      vim.api.nvim_put(lines, "l", true, true)
    end,
    desc = "Class template",
  },
  {
    "<leader>kf",
    function()
      local lines = {
        "fun " .. vim.fn.input("Function name: ") .. "() {",
        "    ",
        "}",
      }
      vim.api.nvim_put(lines, "l", true, true)
    end,
    desc = "Function template",
  },
  {
    "<leader>kD",
    function()
      local lines = {
        "data class " .. vim.fn.input("Data class name: ") .. "(",
        "    ",
        ")",
      }
      vim.api.nvim_put(lines, "l", true, true)
    end,
    desc = "Data class template",
  },
  {
    "<leader>ki",
    function()
      local lines = {
        "interface " .. vim.fn.input("Interface name: ") .. " {",
        "    ",
        "}",
      }
      vim.api.nvim_put(lines, "l", true, true)
    end,
    desc = "Interface template",
  },
  {
    "<leader>ko",
    function()
      local lines = {
        "object " .. vim.fn.input("Object name: ") .. " {",
        "    ",
        "}",
      }
      vim.api.nvim_put(lines, "l", true, true)
    end,
    desc = "Object template",
  },
  {
    "<leader>ke",
    function()
      local lines = {
        "enum class " .. vim.fn.input("Enum name: ") .. " {",
        "    ",
        "}",
      }
      vim.api.nvim_put(lines, "l", true, true)
    end,
    desc = "Enum template",
  },
  {
    "<leader>ks",
    function()
      local lines = {
        "sealed class " .. vim.fn.input("Sealed class name: ") .. " {",
        "    ",
        "}",
      }
      vim.api.nvim_put(lines, "l", true, true)
    end,
    desc = "Sealed class template",
  },
})

-- Spring Boot commands (prefix: <leader>kb)
wk.add({
  { "<leader>kb", group = "Spring Boot" },
  {
    "<leader>kbr",
    function()
      vim.cmd("terminal ./gradlew bootRun")
    end,
    desc = "Spring Boot run",
  },
  {
    "<leader>kbb",
    function()
      vim.cmd("terminal ./gradlew bootJar")
    end,
    desc = "Spring Boot build JAR",
  },
  {
    "<leader>kbt",
    function()
      vim.cmd("terminal ./gradlew bootTest")
    end,
    desc = "Spring Boot test",
  },
})

return {}
