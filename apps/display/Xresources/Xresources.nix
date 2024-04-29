theme: imports:
let
  importString = builtins.concatStringsSep
    "\n"
    (map (f: ''#include "${f}"'') imports)
  ;
in ''
Xft.dpi: 96

*.foreground:  ${theme.foreground}
*.background:  ${theme.background}
*.cursorColor: ${theme.foreground}
*.fading:      0
*.fadeColor:   ${theme.color8}

*.color0:      ${theme.color0}
*.color1:      ${theme.color1}
*.color2:      ${theme.color2}
*.color3:      ${theme.color3}
*.color4:      ${theme.color4}
*.color5:      ${theme.color5}
*.color6:      ${theme.color6}
*.color7:      ${theme.color7}
*.color8:      ${theme.color8}
*.color9:      ${theme.color9}
*.color10:     ${theme.color10}
*.color11:     ${theme.color11}
*.color12:     ${theme.color12}
*.color13:     ${theme.color13}
*.color14:     ${theme.color14}
*.color15:     ${theme.color15}

${importString}
''
