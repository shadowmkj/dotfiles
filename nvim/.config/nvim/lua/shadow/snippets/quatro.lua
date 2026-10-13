local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
	-- 1. Quarto / Markdown Code Cell (for .qmd / .md)
	-- Expands into: ```{python}\n ... \n```
	s("py", {
		t({ "```{python}", "" }),
		i(1, "# code here"),
		t({ "", "```" }),
	}),

	-- 2. Quarto Cell with options (#| label, #| echo)
	s("pyopt", {
		t({ "```{python}", "#| label: " }),
		i(1, "cell-label"),
		t({ "", "#| echo: " }),
		i(2, "true"),
		t({ "", "", "" }),
		i(3, "# code here"),
		t({ "", "```" }),
	}),

	-- 3. Percent-style Cell for standard .py scripts
	-- Expands into: # %% <title>\n <code>
	s("cell", {
		t("# %% "),
		i(1, "Cell Title"),
		t({ "", "" }),
		i(0),
	}),

	-- 4. Fast print: pr -> print("...")
	s("pr", {
		t('print("'),
		i(1, "message"),
		t('")'),
	}),

	-- 5. Debug print: pd -> print(f"var = {var}")
	s(
		"pd",
		fmt([[print(f"{} = {{{}}}") ]], {
			i(1, "var"),
			rep(1),
		})
	),

	-- 6. Type inspect: pt -> print(f"var = {var} (type: {type(var)})")
	s(
		"pt",
		fmt([[print(f"{} = {{{}}} (type: {{type({})}})") ]], {
			i(1, "var"),
			rep(1),
			rep(1),
		})
	),
}
