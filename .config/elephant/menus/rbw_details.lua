Name = "rbw_details"
NamePretty = "Entry Details"
Icon = "dialog-password"
Parent = "rbw"
Cache = false
FixedOrder = true
HideFromProviderlist = true

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

function GetEntries()
    local entries = {}
    local rbw_args = lastMenuValue("rbw")
    if not rbw_args or rbw_args == "" then return entries end

    local tmp = os.tmpname()
    os.execute("rbw get --raw --full " .. rbw_args .. " > " .. shell_escape(tmp) .. " 2>/dev/null")

    local f = io.open(tmp, "r")
    if not f then return entries end
    local content = f:read("*a")
    f:close()
    if content == "" then os.remove(tmp) return entries end

    -- Autotype
    local autotype_seq = jq('[(.fields // [])[]] | map(select(.name == "_autotype")) | .[0].value // empty', tmp)
    if autotype_seq == "" then autotype_seq = "username:tab:password" end
    table.insert(entries, {
        Text = "Autotype",
        Subtext = autotype_seq,
        Icon = "input-keyboard",
        Actions = {
            type = autotype_cmd(rbw_args),
        },
    })

    -- Username
    local username = jq(".data.username // empty", tmp)
    if username ~= "" then
        table.insert(entries, {
            Text = "Username",
            Subtext = username,
            Icon = "avatar-default",
            Actions = {
                copy = copy_value(username),
                type = type_value(username),
            },
        })
    end

    -- Password
    local password = jq(".data.password // empty", tmp)
    if password ~= "" then
        table.insert(entries, {
            Text = "Password",
            Subtext = mask(password),
            Icon = "dialog-password",
            Actions = {
                copy = copy_value(password),
                type = type_value(password),
            },
        })
    end

    -- TOTP
    local has_totp = jq([=[if .data.totp then "1" else empty end]=], tmp)
    if has_totp == "1" then
        table.insert(entries, {
            Text = "TOTP",
            Subtext = "(generated on action)",
            Icon = "appointment-soon",
            Actions = {
                copy = copy_cmd("rbw code " .. rbw_args),
                type = type_cmd("rbw code " .. rbw_args),
            },
        })
    end

    -- Notes
    local notes = jq(".notes // empty", tmp)
    if notes ~= "" then
        table.insert(entries, {
            Text = "Notes",
            Subtext = notes:gsub("\n", " | "),
            Icon = "accessories-text-editor",
            Actions = {
                copy = copy_value(notes),
            },
        })
    end

    -- URIs
    local uri_h = io.popen("jq -r '(.data.uris // [])[] | .uri' " .. shell_escape(tmp) .. " 2>/dev/null")
    if uri_h then
        local i = 1
        for uri in uri_h:lines() do
            table.insert(entries, {
                Text = "URI " .. i,
                Subtext = uri,
                Icon = "web-browser",
                Actions = {
                    copy = copy_value(uri),
                },
            })
            i = i + 1
        end
        uri_h:close()
    end

    -- Custom fields
    local field_h = io.popen("jq -r '(.fields // [])[] | select(.value | length > 0) | .type, .name, .value' " .. shell_escape(tmp) .. " 2>/dev/null")
    if field_h then
        while true do
            local ftype = field_h:read("*l")
            if not ftype then break end
            local fname = field_h:read("*l")
            local fvalue = field_h:read("*l")
            if fname and fvalue then
                local subtext = ftype == "hidden" and mask(fvalue) or fvalue
                local icon = ftype == "hidden" and "channel-secure-symbolic" or "view-list-text"
                table.insert(entries, {
                    Text = fname,
                    Subtext = subtext,
                    Icon = icon,
                    Actions = {
                        copy = copy_value(fvalue),
                        type = type_value(fvalue),
                    },
                })
            end
        end
        field_h:close()
    end

    os.remove(tmp)
    return entries
end
