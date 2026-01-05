# vi: ft=gitconfig

[delta "current-theme"]
  # Diff line styles
  plus-style                    = "{{ color2 }}" "#232634"
  plus-non-emph-style           = "{{ color2 }}" "#232634"
  plus-emph-style               = "{{ color2 }}" "#2a3447"
  plus-empty-line-marker-style  = "{{ color2 }}" "#232634"

  minus-style                   = "{{ color1 }}" "#3b2636"
  minus-non-emph-style          = "{{ color1 }}" "#3b2636"
  minus-emph-style              = "{{ color1 }}" "#4a2f3f"
  minus-empty-line-marker-style = "{{ color1 }}" "#3b2636"

  zero-style                    = "{{ foreground }}" "{{ background }}"

  # Line number styles
  line-numbers-left-style       = "#7f849c"
  line-numbers-right-style      = "#7f849c"
  line-numbers-plus-style       = "{{ color2 }}"
  line-numbers-zero-style       = "#7f849c"
  line-numbers-minus-style      = "{{ color1 }}"

  # Commit styles
  commit-style                  = "{{ accent }}" bold
  commit-decoration-style       = "#45475a" box

  # File styles
  file-style                    = "{{ accent }}" bold
  file-decoration-style         = "{{ accent }}" ul

  # Hunk header styles
  hunk-header-style             = file line-number syntax
  hunk-header-decoration-style  = "#45475a" box
  hunk-header-file-style        = "{{ accent }}"
  hunk-header-line-number-style = "{{ color2 }}"

  # Misc styles
  inline-hint-style             = "#7f849c"
  whitespace-error-style        = "{{ color1 }}" reverse

  # Grep styles
  grep-file-style               = "{{ accent }}"
  grep-line-number-style        = "{{ color2 }}"
  grep-match-line-style         = "{{ color2 }}" "#232634"
  grep-match-word-style         = "{{ color2 }}" "#2a3447"
  grep-context-line-style       = "{{ foreground }}" "{{ background }}"


# accent = "#89b4fa"
# active_border_color = "#CBA6F7"
# active_tab_background = "#CBA6F7"
# 
# cursor = "#f5e0dc"
# foreground = "#cdd6f4"
# background = "#1e1e2e"
# selection_foreground = "#1e1e2e"
# selection_background = "#f5e0dc"
# 
# color0 = "#45475a"
# color1 = "#f38ba8"
# color2 = "#a6e3a1"
# color3 = "#f9e2af"
# color4 = "#89b4fa"
# color5 = "#f5c2e7"
# color6 = "#94e2d5"
# color7 = "#bac2de"
# color8 = "#585b70"
# color9 = "#f38ba8"
# color10 = "#a6e3a1"
# color11 = "#f9e2af"
# color12 = "#89b4fa"
# color13 = "#f5c2e7"
# color14 = "#94e2d5"
# color15 = "#a6adc8"
