function shell_escape(s)
    return "'" .. s:gsub("'", "'\\''") .. "'"
end

function mask(s)
    if #s <= 1 then return s end
    return s:sub(1, 1) .. string.rep("*", #s - 1)
end

function jq(filter, file)
    local h = io.popen("jq -r " .. shell_escape(filter) .. " " .. shell_escape(file) .. " 2>/dev/null")
    if not h then return "" end
    local out = h:read("*a") or ""
    h:close()
    return out:gsub("%s+$", "")
end

function copy_value(val)
    return "wl-copy -- " .. shell_escape(val) .. " && { sleep 10 && wl-copy --clear; } &"
end

function type_value(val)
    return "sleep 0.3 && wtype -- " .. shell_escape(val)
end

function copy_cmd(cmd)
    return "wl-copy -- \"$(" .. cmd .. ")\" && { sleep 10 && wl-copy --clear; } &"
end

function type_cmd(cmd)
    return "sleep 0.3 && wtype -- \"$(" .. cmd .. ")\""
end
