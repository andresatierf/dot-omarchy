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
    local has_totp = jq([=[if .data.totp != null then "1" else empty end]=], tmp)
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
    local fields_filter = [=[(.fields // [])[] | select(.value // "" != "") | "\(.type)\t\(.name)\t\(.value)"]=]
    local field_h = io.popen("jq -r " .. shell_escape(fields_filter) .. " " .. shell_escape(tmp) .. " 2>/dev/null")
    if field_h then
        for line in field_h:lines() do
            local ftype, fname, fvalue = line:match("^(%d+)\t(.-)\t(.+)$")
            if fname and fvalue then
                local subtext = ftype == "1" and mask(fvalue) or fvalue
                local icon = ftype == "1" and "channel-secure-symbolic" or "view-list-text"
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
