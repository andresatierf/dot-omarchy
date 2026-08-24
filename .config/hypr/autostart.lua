-- Extra autostart processes.
-- Migrated from autostart.conf when Omarchy 4 moved to Lua config.
--
-- The "[workspace N silent]" prefix is Hyprland's exec rule syntax, carried
-- over verbatim from the old exec-once lines: the app opens on that workspace
-- without pulling focus to it.

o.exec_on_start("[workspace 4 silent] uwsm-app -- spotify")
o.exec_on_start("[workspace 4 silent] uwsm-app -- obsidian")

o.exec_on_start("[workspace 5 silent] omarchy-launch-webapp https://discord.com/channels/@me")
o.exec_on_start("[workspace 5 silent] omarchy-launch-webapp https://web.whatsapp.com/")
o.exec_on_start("[workspace 7 silent] omarchy-launch-webapp https://plex.satierf.dev")

o.launch_on_start("kdeconnectd")
o.launch_on_start("kdeconnect-indicator")
