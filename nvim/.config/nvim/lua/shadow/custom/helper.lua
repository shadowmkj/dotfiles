local M = {}

-- Helper function to check if a window is at a specific edge
-- direction can be 'h' (left), 'j' (bottom), 'k' (top), 'l' (right)
function M.is_at_edge(direction)
	return vim.fn.winnr() == vim.fn.winnr(direction)
end

return M
