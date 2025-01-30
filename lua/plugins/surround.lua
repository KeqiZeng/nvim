return {
    "kylechui/nvim-surround",
    version = "*",
    event = "BufReadPost",
    config = function()
        require("nvim-surround").setup({
            -- The general rule is that if the key ends in "_line", the delimiter pair is added
            -- on new lines. If the key ends in "_cur", the surround is performed around the
            -- current line.
            keymaps = {
                normal = "ys",
                normal_cur = "yss",
                normal_line = "yS",
                normal_cur_line = "ySS",
                delete = "ds",
                change = "cs",
                change_line = "cS",
                visual = false,
                visual_line = false,
                insert = false,
                insert_line = false,
            },
            move_cursor = "sticky",
        })
    end
}
