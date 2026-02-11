Name = "rbw"
NamePretty = "Bitwarden (rbw)"
Icon = "dialog-password"
Cache = true
SearchName = true

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

local function build_rbw_args(name, user, folder)
    local args = shell_escape(name)
    if user and user ~= "" then
        args = args .. " " .. shell_escape(user)
    end
    if folder and folder ~= "" then
        args = args .. " --folder " .. shell_escape(folder)
    end
    return args
end

function GetEntries()
    local entries = {}

    local handle = io.popen("rbw list --fields folder,name,user 2>/dev/null")
    if not handle then
        return entries
    end

    for line in handle:lines() do
        local folder, name, user = line:match("^(.-)\t(.-)\t(.*)$")
        if name then
            local rbw_args = build_rbw_args(name, user, folder)
            local get_pass = "rbw get " .. rbw_args
            local get_totp = "rbw code " .. rbw_args
            local escaped_user = (user and user ~= "") and shell_escape(user) or "''"

            local display = ""
            if folder and folder ~= "" then
                display = folder .. "/" .. name
            else
                display = name
            end

            local subtext = ""
            if user and user ~= "" then
                subtext = user
            end

            table.insert(entries, {
                Text = display,
                Subtext = subtext,
                Value = rbw_args,
                SubMenu = "rbw_details",
                Actions = {
                    autotype = "sleep 0.3 && wtype -- " .. escaped_user .. " && wtype -k Tab && sleep 0.2 && wtype -- \"$(" .. get_pass .. ")\"",
                    typeusername = "sleep 0.3 && wtype -- " .. escaped_user,
                    typepassword = type_cmd(get_pass),
                    typetotp = type_cmd(get_totp),
                    copyusername = "wl-copy -- " .. escaped_user .. " && { sleep 10 && wl-copy --clear; } &",
                    copypassword = copy_cmd(get_pass),
                    copytotp = copy_cmd(get_totp),
                    syncvault = "rbw sync && notify-send 'rbw' 'Vault synced'",
                },
            })
        end
    end

    handle:close()

    return entries
end
