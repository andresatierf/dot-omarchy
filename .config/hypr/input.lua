-- Keep only your personal input overrides here.
-- Migrated from input.conf when Omarchy 4 moved to Lua config.

hl.config({
  input = {
    kb_layout = "us",
    kb_variant = "altgr-intl",
    kb_options = "compose:caps", -- ,grp:alts_toggle
    repeat_rate = 40,
    repeat_delay = 600,
    numlock_by_default = true,

    touchpad = {
      natural_scroll = true,
      scroll_factor = 0.4,
    },
  },

  misc = {
    key_press_enables_dpms = true,  -- key press will trigger wake
    mouse_move_enables_dpms = true, -- mouse move will trigger wake
  },
})

-- App-specific touchpad scroll speeds.
o.window("kitty", { scroll_touchpad = 1.5 })

-- Three-finger horizontal swipe changes workspaces.
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
