local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local rep = require("luasnip.extras").rep
local fmt = require("luasnip.extras.fmt").fmt

local function cp_template(trig, desc)
	return s(
		{ trig = trig, dscr = desc or "C++ Competitive Programming Template" },
		fmt(
			[[
#include <bits/stdc++.h>

using namespace std;
using vi = vector<int>;

void solve() {{
    int n;
    cin >> n;
    {}
}}

int main() {{
    ios::sync_with_stdio(false);
    cin.tie(0);

    int t;
    cin >> t;
    while (t--)
        solve();
}}
]],
			{
				i(0),
			}
		)
	)
end

local function matrix_snippet(trig, desc)
	return s(
		{ trig = trig, dscr = desc or "Read 2D matrix / grid of size n x m" },
		fmt(
			[[
int {1}, {2};
cin >> {3} >> {4};
vector<vector<{5}>> {6}({7}, vector<{8}>({9}));
for (int i = 0; i < {10}; i++) {{
    for (int j = 0; j < {11}; j++) {{
        cin >> {12}[i][j];
    }}
}}
{13}
]],
			{
				i(1, "n"),
				i(2, "m"),
				rep(1),
				rep(2),
				i(3, "int"),
				i(4, "a"),
				rep(1),
				rep(3),
				rep(2),
				rep(1),
				rep(2),
				rep(4),
				i(0),
			}
		)
	)
end

return {
	cp_template("cpp", "C++ template with solve() and fast I/O"),
	cp_template("cp", "Competitive programming template with solve() loop"),
	cp_template("template", "C++ boilerplate template"),
	cp_template("solve", "C++ solve() boilerplate template"),

	matrix_snippet("mat", "Read 2D matrix of size n x m"),
	matrix_snippet("matrix", "Read 2D matrix of size n x m"),
	matrix_snippet("grid", "Read 2D grid of size n x m"),
	matrix_snippet("readmat", "Read 2D matrix of size n x m"),
}
