local function get_theme()
    local theme = os.getenv("THEME")
    if not theme then
        return nil
    end
    theme = string.lower(theme)
    local results = {}
    for part in string.gmatch(theme, "([^%-]+)") do
        table.insert(results, part)
    end
    return results[1], results[2]
end

local theme, theme_variant = get_theme()

if not theme then
    theme = "catppuccin"
    theme_variant = "-macchiato"
end

if theme == "catppuccin" then
    if not theme_variant then
        theme_variant = "macchiato"
    end
    theme_variant = "-" .. theme_variant
end

if theme == "tokyonight" then
    if not theme_variant then
        theme_variant = "moon"
    end
    theme_variant = "-" .. theme_variant
end

if theme == "dracula" then
    theme_variant = ""
end

vim.cmd("colorscheme " .. theme .. theme_variant)
