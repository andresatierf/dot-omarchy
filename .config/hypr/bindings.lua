-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Passwords: replace Omarchy's default 1Password binding with the rbw picker.
hl.unbind("SUPER + SHIFT + SLASH")
-- Swap the command back to "omarchy-rbw" to use the menu-driven picker.
o.bind("SUPER + SHIFT + SLASH", "Passwords", "omarchy-shell shell toggle andre.rbw")

-- ---------------------------------------------------------------------------
-- Migrated from bindings.conf and bindings/tiling.conf when Omarchy 4 moved to
-- Lua config. Only the bindings that differ from Omarchy's defaults are kept
-- here; anything the defaults already provide identically was dropped.
-- ---------------------------------------------------------------------------

-- Applications ---------------------------------------------------------------

-- Super+Shift+E opened the file manager here, not Omarchy's Email web app.
hl.unbind("SUPER + SHIFT + E")
o.bind("SUPER + SHIFT + E", "File manager", "uwsm-app -- nautilus --new-window")

-- Omarchy puts Activity on Super+Ctrl+T; this setup uses Super+Shift+T.
o.bind("SUPER + SHIFT + T", "Activity", { tui = "btop" })

-- Super+Shift+R ran `omarchy-walker-remmina`, which needs walker. Omarchy 4
-- removed walker, so the binding is left out until it is rewritten.

-- Windows --------------------------------------------------------------------

-- Close on Q rather than Omarchy's W (Super+W stays bound as well).
o.bind("SUPER + Q", "Close active window", hl.dsp.window.close())
o.bind("SUPER + SHIFT + Q", "Close all windows", "omarchy-hyprland-window-close-all")

-- Float toggle on S; Omarchy 4 uses S for the scratchpad and T for floating.
hl.unbind("SUPER + S")
o.bind("SUPER + S", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))

-- Fullscreen and full width are the other way round from Omarchy's defaults.
hl.unbind("SUPER + F")
hl.unbind("SUPER + ALT + F")
o.bind("SUPER + F", "Full width", hl.dsp.window.fullscreen({ mode = "maximized" }))
o.bind("SUPER + ALT + F", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- Vim-style navigation -------------------------------------------------------

-- Omarchy 4 drives focus, swapping and resizing from the arrow keys. These
-- reclaim HJKL, which means giving up the defaults that sit on J, K and L.
hl.unbind("SUPER + J") -- Toggle window split
hl.unbind("SUPER + K") -- Keybindings menu
hl.unbind("SUPER + L") -- Toggle workspace layout
o.bind("SUPER + H", "Move focus left", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + J", "Move focus down", hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + K", "Move focus up", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + L", "Move focus right", hl.dsp.focus({ direction = "r" }))

o.bind("SUPER + SHIFT + H", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + SHIFT + J", "Swap window down", hl.dsp.window.swap({ direction = "d" }))
o.bind("SUPER + SHIFT + K", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + SHIFT + L", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))

hl.unbind("SUPER + ALT + K") -- Tmux keybindings menu
o.bind("SUPER + ALT + H", "Expand window left", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
o.bind("SUPER + ALT + J", "Expand window down", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))
o.bind("SUPER + ALT + K", "Shrink window up", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
o.bind("SUPER + ALT + L", "Shrink window left", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))

-- The old binding was `resizeactive exact 50% 50%`. The Lua resize dispatcher
-- only takes pixel positions, so work the half-monitor size out at press time.
hl.unbind("SUPER + ALT + code:21") -- Shrink window left a little
o.bind("SUPER + ALT + code:21", "Restore window size", function()
  local monitor = hl.get_active_monitor()
  if not monitor then return end

  local width = monitor.width or (monitor.size and monitor.size.x)
  local height = monitor.height or (monitor.size and monitor.size.y)
  if not width or not height then return end

  hl.dispatch(hl.dsp.window.resize({
    x = math.floor(width / 2),
    y = math.floor(height / 2),
    relative = false,
  }))
end)

o.bind("SUPER + SHIFT + ALT + H", "Move workspace to left monitor", hl.dsp.workspace.move({ monitor = "l" }))
o.bind("SUPER + SHIFT + ALT + L", "Move workspace to right monitor", hl.dsp.workspace.move({ monitor = "r" }))

-- Workspaces -----------------------------------------------------------------

-- Scratchpad on the backtick; Omarchy 4 moved it to Super+S, which is floating here.
o.bind("SUPER + grave", "Toggle scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
o.bind("SUPER + ALT + grave", "Move window to scratchpad",
  hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))

-- Twelve special workspaces on the function keys. Not an Omarchy default.
for index = 1, 12 do
  local special = "f" .. tostring(index)
  o.bind("SUPER + F" .. index, "Switch to special workspace " .. index,
    hl.dsp.workspace.toggle_special(special))
  o.bind("SUPER + SHIFT + F" .. index, "Move window to special workspace " .. index,
    hl.dsp.window.move({ workspace = "special:" .. special, follow = false }))
end

-- Groups ---------------------------------------------------------------------

-- NOTE: bindings/tiling.conf bound BOTH "move window into group" and "move
-- grouped window focus" to Super+Alt+Left/Right, so both fired on one press.
-- That is carried over as-is; Omarchy's default puts grouped focus on
-- Super+Ctrl+Left/Right, which is still bound if you prefer it.
o.bind("SUPER + ALT + LEFT", "Move grouped window focus left", hl.dsp.group.prev())
o.bind("SUPER + ALT + RIGHT", "Move grouped window focus right", hl.dsp.group.next())
