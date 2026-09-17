local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
	s(
		"ff",
		fmt([[\frac{{{}}}{{{}}}]], {
			i(1),
			i(2),
		})
	),

	s(
		"\\(",
		fmt([[\({}\)]], {
			i(1),
		})
	),
}
