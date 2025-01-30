return {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    event = "BufReadPost",
    config = function()
        local mc = require("multicursor-nvim")

        mc.setup()

        local set = vim.keymap.set

        -- Add or skip cursor above/below the main cursor.
        set({ "n", "v" }, "<leader>mk", function()
            mc.lineAddCursor(-1)
        end, { desc = "Add cursor above" })

        set({ "n", "v" }, "<leader>mj", function()
            mc.lineAddCursor(1)
        end, { desc = "Add cursor below" })

        set({ "n", "v" }, "<leader>mK", function()
            mc.lineSkipCursor(-1)
        end, { desc = "Skip cursor above" })

        set({ "n", "v" }, "<leader>mJ", function()
            mc.lineSkipCursor(1)
        end, { desc = "Skip cursor below" })

        -- Add or skip adding a new cursor by matching word/selection
        set({ "n", "v" }, "<leader>mn", function()
            mc.matchAddCursor(1)
        end, { desc = "Add cursor on next matched word or selection" })

        set({ "n", "v" }, "<leader>ms", function()
            mc.matchSkipCursor(1)
        end, { desc = "Skip cursor on next matched word or selection" })

        set({ "n", "v" }, "<leader>mp", function()
            mc.matchAddCursor(-1)
        end, { desc = "Add cursor on previous matched word or selection" })

        set({ "n", "v" }, "<leader>mS", function()
            mc.matchSkipCursor(-1)
        end, { desc = "Skip cursor on previous matched word or selection" })

        -- Add all matches in the document
        set({ "n", "v" }, "<leader>ma", mc.matchAllAddCursors, { desc = "Add cursor on all matched words or selections" })

        -- Rotate the main cursor.
        set({ "n", "v" }, "<leader>mh", mc.prevCursor, { desc = "Rotate main cursor to previous" })
        set({ "n", "v" }, "<leader>ml", mc.nextCursor, { desc = "Rotate main cursor to next" })

        -- Delete the main cursor.
        set({ "n", "v" }, "<leader>mx", mc.deleteCursor, { desc = "Delete main cursor" })

        -- Add and remove cursors with control + left click.
        set("n", "<C-leftmouse>", mc.handleMouse, { desc = "Add cursor with mouse" })

        -- Easy way to add and remove cursors using the main cursor.
        set({ "n", "v" }, "<C-q>", mc.toggleCursor, { desc = "Add or remove a cursor with main cursor" })

        -- Exit Multicursor mode
        set("n", "<C-e>", function()
            if not mc.cursorsEnabled() then
                mc.enableCursors()
            elseif mc.hasCursors() then
                mc.clearCursors()
            end
        end)

        -- bring back cursors if you accidentally clear them
        set("n", "<leader>mr", mc.restoreCursors, { desc = "Restore all cursors" })

        -- Align cursor columns.
        set("n", "<leader>mA", mc.alignCursors, { desc = "Align cursor columns" })

        -- Append/insert for each line of visual selections.
        set("v", "I", mc.insertVisual, { desc = "Insert for each line of visual selections" })
        set("v", "A", mc.appendVisual, { desc = "Append for each line of visual selections" })

        -- match new cursors within visual selections by regex.
        set("v", "m", mc.matchCursors, { desc = "Match new cursors within visual selections by regex" })

        -- Jumplist support
        set({ "v", "n" }, "<C-i>", mc.jumpForward, { desc = "Jump forward" })
        set({ "v", "n" }, "<C-o>", mc.jumpBackward, { desc = "Jump backward" })

        -- Customize how cursors look.
        local hl = vim.api.nvim_set_hl
        hl(0, "MultiCursorCursor", { link = "Cursor" })
        hl(0, "MultiCursorVisual", { link = "Visual" })
        hl(0, "MultiCursorSign", { link = "SignColumn" })
        hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
        hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
        hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
    end
}
