if true then
    return {}
end
return {
    -- "qompile",
    -- dev = true,
    -- dir = "~/Documents/Desk/Apps/qompile",
    -- config = function()
    --     require("qompile").setup({})
    -- end

    "shadowmkj/qompile.nvim",
    config = function()
        require("qompile").setup()
    end,

}
