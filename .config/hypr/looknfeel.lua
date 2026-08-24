-- Change the default Omarchy look'n'feel.
-- Migrated from looknfeel.conf when Omarchy 4 moved to Lua config.

hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 6,
    border_size = 2,
    layout = "master",
  },

  decoration = {
    rounding = 4,
  },

  master = {
    new_status = "slave",
    new_on_top = true,
    special_scale_factor = 0.95,
  },
})

-- Slow the workspace switch slightly: animation = workspaces, 1, 1.5, default
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.5, bezier = "default" })
