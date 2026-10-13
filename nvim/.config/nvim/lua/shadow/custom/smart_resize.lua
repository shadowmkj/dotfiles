local helper = require("shadow.custom.helper")

local M = {}

function M.smart_resize()
	print("Directional Resize Mode: [h/j/k/l] Move border. Press Esc to exit.")

	while true do
		vim.cmd("redraw")
		local char = vim.fn.getchar(0)
		if char == 0 then
			char = vim.fn.getchar()
		end
		local key = type(char) == "number" and vim.fn.nr2char(char) or char

		if key == "h" then
			-- If at right edge, pushing left grows it. If at left edge, pushing left shrinks it.
			if helper.is_at_edge("l") then
				vim.cmd("vertical resize +3")
			else
				vim.cmd("vertical resize -3")
			end
		elseif key == "l" then
			-- Pushing right grows a left window, but shrinks a right window.
			if helper.is_at_edge("l") then
				vim.cmd("vertical resize -3")
			else
				vim.cmd("vertical resize +3")
			end
		elseif key == "j" then
			-- If at the bottom edge, pulling down shrinks it. If at top edge, pulling down grows it.
			if helper.is_at_edge("j") then
				vim.cmd("resize -3")
			else
				vim.cmd("resize +3")
			end
		elseif key == "k" then
			-- Pulling up grows a bottom window, but shrinks a top window.
			if helper.is_at_edge("j") then
				vim.cmd("resize +3")
			else
				vim.cmd("resize -3")
			end
		elseif key == "\27" or key == "" then
			vim.cmd('echo ""')
			break
		else
			vim.cmd('echo ""')
			break
		end
	end
end

M.resize = M.smart_resize

setmetatable(M, {
	__call = function(_, ...)
		return M.smart_resize(...)
	end,
})

return M
