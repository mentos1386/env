-- Copilot provider
require("copilot").setup({
	suggestion = { enabled = false },
	panel = { enabled = false },
	filetypes = {
		javascript = true,
		typescript = true,
		rust = true,
		go = true,
		yaml = true,
		python = true,
		css = true,
		tmpl = true,
		tf = true,
		terraform = true,
	},
})
require("copilot_cmp").setup()

-- Codeium provider
require("codeium").setup({})

-- Git providers
require("cmp_git").setup()

local cmp = require("cmp")
local lspkind = require("lspkind")
lspkind.init({
	symbol_map = { Copilot = "", Codeium = "" },
})
vim.opt.completeopt = "menu,menuone,noselect"
cmp.setup({
	formatting = {
		fields = { "abbr", "kind" },
		format = lspkind.cmp_format({
			mode = "symbol_text",
			maxwidth = function()
				return math.min(40, math.floor(vim.o.columns * 0.4))
			end,
			ellipsis_char = "...",
			before = function(entry, item)
				item.menu = ""
				return item
			end,
		}),
	},
	snippet = {
		-- REQUIRED - you must specify a snippet engine
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
			-- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
			-- require('snippy').expand_snippet(args.body) -- For `snippy` users.
			-- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
		end,
	},
	window = {
		-- completion = cmp.config.window.bordered(),
		-- documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-e>"] = cmp.mapping.abort(),
		["<Tab>"] = cmp.mapping(function(fallback)
			-- This little snippet will confirm with tab, and if no entry is selected, will confirm the first item
			if cmp.visible() then
				local entry = cmp.get_selected_entry()
				if not entry then
					cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
				else
					cmp.confirm()
				end
			else
				fallback()
			end
		end, { "i", "s", "c" }),
	}),
	sources = cmp.config.sources({
		{ name = "copilot", max_item_count = 2 },
		{ name = "codeium", max_item_count = 2 },
		{ name = "nvim_lsp", max_item_count = 10 },
		{ name = "git", max_item_count = 5 },
		-- { name = 'vsnip' }, -- For vsnip users.
		-- { name = 'luasnip' }, -- For luasnip users.
		-- { name = 'ultisnips' }, -- For ultisnips users.
		-- { name = 'snippy' }, -- For snippy users.
	}, {
		{ name = "buffer", max_item_count = 5 },
	}),
})

-- Set configuration for specific filetype.
cmp.setup.filetype("gitcommit", {
	sources = cmp.config.sources({
		{ name = "git" },
	}, {
		{ name = "buffer" },
	}),
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ "/", "?" }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
})

-- LSP
require("mason").setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})
require("mason-lspconfig").setup({
	ensure_installed = {
		"typos_lsp", -- all
		"angularls", -- angular
		"ansiblels", -- ansible
		"bashls", -- bash
		"buf_ls", -- buf
		"cssls", -- css
		"denols", -- deno
		"dockerls", -- docker
		"docker_compose_language_service", -- docker-compose
		"eslint", -- eslint
		"elixirls", -- elixir
		"gopls", -- golang
		"graphql", -- graphql
		"html", -- html
		"htmx", -- htmx
		"helm_ls", -- helm
		"jsonls", -- json
		"ts_ls", -- javascript/typescript
		"marksman", -- markdown
		"vale_ls", -- markdown/prose
		"swift_mesonls", -- meson
		"prismals", -- prisma
		"pyright", -- python
		"rust_analyzer", -- rust
		"taplo", -- toml
		"terraformls", -- terraform
		"tflint", -- terraform
		"yamlls", -- yaml
		"nil_ls", -- nix
	},
	automatic_installation = true,
})

require("mason-lspconfig").setup_handlers({
	function(server_name)
		-- DenoLSP and TSServer should not be run
		-- at the same time.
		-- https://docs.deno.com/runtime/manual/getting_started/setup_your_environment#neovim-06-using-the-built-in-language-server
		if server_name == "denols" then
			require("lspconfig")[server_name].setup({
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
				root_dir = require("lspconfig.util").root_pattern("deno.json", "deno.jsonc"),
			})
			return
		end
		if server_name == "tsserver" then
			require("lspconfig")[server_name].setup({
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
				root_dir = require("lspconfig.util").root_pattern("package.json"),
				single_file_support = false,
			})
			return
		end
		require("lspconfig")[server_name].setup({
			capabilities = require("cmp_nvim_lsp").default_capabilities(),
		})
	end,
})

-- Formatter
local util = require("formatter.util")
require("formatter").setup({
	logging = true,
	log_level = vim.log.levels.WARN,
	-- All formatter configurations are opt-in
	filetype = {
		lua = {
			require("formatter.filetypes.lua").stylua,
		},
		javascript = {
			require("formatter.filetypes.javascript").prettier,
		},
		typescript = {
			require("formatter.filetypes.typescript").prettier,
		},
		json = {
			require("formatter.filetypes.json").prettier,
		},
		graphql = {
			require("formatter.filetypes.graphql").prettier,
		},
		html = {
			require("formatter.filetypes.html").prettier,
		},
		template = {
			function()
				local prettierForGoTemplate = require("formatter.defaults.prettier")()
				table.insert(prettierForGoTemplate.args, "--plugin")
				table.insert(prettierForGoTemplate.args, "prettier-plugin-go-template")
				return prettierForGoTemplate
			end,
		},
		css = {
			require("formatter.filetypes.css").prettier,
		},
		rust = {
			require("formatter.filetypes.rust").rustfmt,
		},
		go = {
			require("formatter.filetypes.go").gofmt,
		},
		python = {
			require("formatter.filetypes.python").black,
		},
		elixir = {
			require("formatter.filetypes.elixir").mix_format,
		},
		sh = {
			require("formatter.filetypes.sh").shfmt,
		},
		proto = {
			require("formatter.filetypes.proto").buf_format,
		},
		nix = {
			require("formatter.filetypes.nix").nixfmt,
		},
		terraform = {
			--require("formatter.filetypes.terraform").terraformfmt,
			function()
				return {
					exe = "tofu",
					args = { "fmt", "-" },
					stdin = true,
				}
			end,
		},

		-- Use the special "*" filetype for defining formatter configurations on
		-- any filetype
		["*"] = {
			-- "formatter.filetypes.any" defines default configurations for any
			-- filetype
			require("formatter.filetypes.any").remove_trailing_whitespace,
		},
	},
})
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
augroup("__formatter__", { clear = true })
autocmd("BufWritePost", {
	group = "__formatter__",
	command = ":FormatWrite",
})

require("trouble").setup({})

-- Git
require("neogit").setup({})
