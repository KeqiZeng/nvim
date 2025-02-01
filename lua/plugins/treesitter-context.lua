return {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        max_lines = 12,
        multiline_threshold = 4,
        separator = "─",
    }
}
