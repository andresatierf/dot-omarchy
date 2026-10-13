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
o.bind("SUPER + SHIFT + SLASH", "Passwords", "omarchy-shell shell toggle io.github.andresatierf.rbw")

-- ---------------------------------------------------------------------------
-- Migrated from bindings.conf and bindings/tiling.conf when Omarchy 4 moved to
-- Lua config. Only the bindings that differ from Omarchy's defaults are kept
-- here; anything the defaults already provide identically was dropped.
-- ---------------------------------------------------------------------------

-- Applications ---------------------------------------------------------------

-- Super+Shift+R ran `omarchy-walker-remmina`, which needs walker. Omarchy 4
-- removed walker, so the binding is left out until it is rewritten.

-- Windows --------------------------------------------------------------------

-- Cycle the workspace layout through master, dwindle and scrolling instead of
-- Omarchy's dwindle/scrolling toggle.
hl.unbind("SUPER + L")
o.bind("SUPER + L", "Cycle workspace layout", "omarchy-hyprland-workspace-layout-cycle")

-- Resize the window to half the monitor. Sits beside Omarchy's Super+Home
-- (restore width) and Super+Alt+Home (save width). The Lua resize dispatcher
-- only takes pixel sizes, so work the half-monitor size out at press time.
o.bind("SUPER + SHIFT + Home", "Restore window size", function()
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
