local function get_python_path()
    local venv = vim.fn.getenv("VIRTUAL_ENV")
    if venv and venv ~= vim.NIL then
        return tostring(venv) .. "/bin/python"
    end

    local conda_prefix = vim.fn.getenv("CONDA_PREFIX")
    if conda_prefix and conda_prefix ~= vim.NIL then
        return tostring(conda_prefix) .. "/bin/python"
    end

    return vim.fn.system("python -c 'import sys; print(sys.executable)'"):gsub("\n", "")
end

local function get_pyright_client(bufnr)
    for _, client in pairs(vim.lsp.get_active_clients({ bufnr = bufnr })) do
        if client.name == "pyright" or client.name == "basedpyright" then
            return client
        end
    end
    return nil
end

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        vim.defer_fn(function()
            local buf = args.buf
            if not vim.api.nvim_buf_is_valid(buf) then
                return
            end
            local client = get_pyright_client(buf)
            if not client then
                return
            end

            local python_path = get_python_path()
            vim.cmd("PyrightSetPythonPath " .. python_path)
            vim.notify("Set python path to " .. python_path, vim.log.levels.INFO)
        end, 500)
    end,
})
