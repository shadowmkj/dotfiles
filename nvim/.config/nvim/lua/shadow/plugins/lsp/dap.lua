return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
            "jay-babu/mason-nvim-dap.nvim",
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            dapui.setup()
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end

            dap.adapters.codelldb = {
                type = "executable",
                -- command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
                command = "/Users/milan/.local/share/nvim/mason/bin/codelldb"
            }

            dap.configurations.rust = {
                {
                    name = "Debug Rust",
                    type = "codelldb",
                    request = "launch",
                    program = function()
                        return vim.fn.getcwd() .. "/target/debug/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                },
            }
            vim.keymap.set('n', '<leader>dc', dap.continue)
            vim.keymap.set('n', '<leader>bp', dap.toggle_breakpoint)
            vim.keymap.set('n', '<leader>de', dap.terminate)
            local function set_debug_keymaps()
                local opts = { noremap = true, silent = true }
                vim.keymap.set('n', 'dn', dap.step_over)
                vim.keymap.set('n', 'di', dap.step_into)
                vim.keymap.set('n', 'do', dap.step_out)
            end

            local function clear_debug_keymaps()
                pcall(vim.keymap.del, 'n', '<leader>do')
                pcall(vim.keymap.del, 'n', '<leader>di')
                pcall(vim.keymap.del, 'n', '<leader>dn')
            end
            dap.listeners.after.event_initialized["debug_keymaps"] = function()
                set_debug_keymaps()
            end

            dap.listeners.before.event_terminated["debug_keymaps"] = function()
                clear_debug_keymaps()
            end

            dap.listeners.before.event_exited["debug_keymaps"] = function()
                clear_debug_keymaps()
            end
        end,
    },
    {
        "rcarriga/nvim-dap-ui",
    },
    -- {
    --     "jay-babu/mason-nvim-dap.nvim",
    --     dependencies = {
    --         "mason-org/mason.nvim",
    --         "mfussenegger/nvim-dap",
    --     },
    --     config = function()
    --         require("mason-nvim-dap").setup({
    --             ensure_installed = { "codelldb" },
    --             automatic_installation = true,
    --             handlers = {},
    --         })
    --     end,
    -- },
}
