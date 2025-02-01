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

vim.api.nvim_create_autocmd({ "FileType", "LspAttach" }, {
    callback = function(args)
        local buf = args.buf
        if not vim.api.nvim_buf_is_valid(buf) then
            return
        end

        if args.event == "FileType" and args.match == "python" then
            vim.b[buf].is_python = true
        elseif args.event == "LspAttach" then
            local client = get_pyright_client(buf)
            if client then
                vim.b[buf].pyright_attached = true
            end
        end

        if vim.b[buf].python_path_already_set then
            return
        end

        -- defer setting python path
        vim.defer_fn(function()
            if not vim.api.nvim_buf_is_valid(buf) then
                return
            end
            if vim.b[buf].is_python and vim.b[buf].pyright_attached then
                local python_path = get_python_path()
                vim.notify("Set python path to " .. python_path, vim.log.levels.INFO)
                local client = get_pyright_client(buf)
                if not client then
                    return
                end
                vim.cmd("PyrightSetPythonPath " .. python_path)

                vim.b[buf].python_path_already_set = true
            end
        end, 200)
    end,
})
