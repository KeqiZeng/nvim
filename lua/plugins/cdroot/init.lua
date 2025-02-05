local M = {}

local project_root_markers = {
    ".git",
    ".hg",
    ".svn",
    ".bzr",
    ".clang_format",
    ".clang_tidy",
    "CMakeLists.txt",
    "pyproject.toml",
    "Cargo.toml",
}

local root = "/"

local function is_project_root(path)
    for _, file in ipairs(project_root_markers) do
        if vim.fn.glob(path .. "/" .. file) ~= "" then
            return true
        end
    end
    return false
end


local function get_project_root()
    local cwd = vim.fn.getcwd()
    while cwd ~= root do
        if is_project_root(cwd) then
            return cwd
        end
        cwd = vim.fn.fnamemodify(cwd, ":h")
    end
    return nil
end

local function cd_project_root()
    vim.schedule(function()
        local project_root = get_project_root()
        local cwd = vim.fn.getcwd()
        if project_root and cwd ~= project_root then
            vim.cmd("cd " .. project_root)
            vim.notify("Cd to project root: " .. project_root, vim.log.levels.INFO)
        end
    end)
end

function M.setup()
    cd_project_root()
    vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*",
        callback = cd_project_root,
    })
end

return M
