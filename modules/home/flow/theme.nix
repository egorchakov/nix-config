{
  config,
  lib,
  self,
}:
let
  base = fromTOML (
    builtins.readFile "${self.inputs.stylix.inputs.base16-helix}/templates/base16.mustache"
  );
  helix = removeAttrs (base // config.programs.helix.themes.stylix-brighter-comments) [
    "inherits"
    "palette"
  ];
  color = value: {
    color = config.lib.stylix.colors.withHashtag.${value} or value;
    alpha = 255;
  };
  style =
    value:
    let
      attrs = if builtins.isString value then { fg = value; } else value;
      modifiers = attrs.modifiers or [ ];
      reversed = builtins.elem "reversed" modifiers;
    in
    lib.optionalAttrs (attrs ? fg) { fg = color attrs.fg; }
    // lib.optionalAttrs (attrs ? bg) { bg = color attrs.bg; }
    // lib.optionalAttrs (modifiers != [ ] && !reversed) {
      fs =
        {
          underlined = "underline";
          crossed_out = "strikethrough";
        }
        .${builtins.head modifiers} or (builtins.head modifiers);
    }
    // lib.optionalAttrs (attrs ? underline) { fs = "undercurl"; }
    // lib.optionalAttrs reversed {
      fg = color (attrs.bg or helix."ui.background".bg);
      bg = color attrs.fg;
    };
  styles = lib.mapAttrs (_: style) helix;
  editor = styles."ui.text" // styles."ui.background";
  ansi = {
    black = "base00";
    red = "base08";
    green = "base0B";
    yellow = "base0A";
    blue = "base0D";
    magenta = "base0E";
    cyan = "base0C";
    white = "base05";
    bright_black = "base03";
    bright_red = "base08";
    bright_green = "base0B";
    bright_yellow = "base0A";
    bright_blue = "base0D";
    bright_magenta = "base0E";
    bright_cyan = "base0C";
    bright_white = "base07";
  };
in
{
  name = "helix";
  description = "Helix Stylix theme with brighter comments";
  type = config.stylix.polarity;
  inherit editor;
  scope_type = "tree_sitter";
  tokens = lib.mapAttrsToList (scope: style: { inherit scope style; }) (
    lib.filterAttrs (name: _: !lib.hasPrefix "ui." name) styles
    // lib.mapAttrs (_: scope: styles.${scope}) {
      boolean = "constant";
      number = "constant.numeric";
      float = "constant.numeric";
      character = "constant";
      "string.escape" = "constant.character.escape";
      property = "variable.other.member";
      field = "variable.other.member";
      "variable.member" = "variable.other.member";
      module = "namespace";
      method = "function";
      conditional = "keyword";
      repeat = "keyword";
      exception = "keyword";
      include = "keyword";
      storageclass = "keyword";
      "markup.strong" = "markup.bold";
      "markup.emphasis" = "markup.italic";
      "text.title" = "markup.heading.1";
      "text.literal" = "markup.raw";
      "text.strong" = "markup.bold";
      "text.emphasis" = "markup.italic";
      "text.uri" = "markup.link.url";
    }
  );
  ansi_palette =
    map
      (
        name:
        map (channel: lib.toInt config.lib.stylix.colors."${ansi.${name}}-rgb-${channel}") [
          "r"
          "g"
          "b"
        ]
      )
      [
        "black"
        "red"
        "green"
        "yellow"
        "blue"
        "magenta"
        "cyan"
        "white"
        "bright_black"
        "bright_red"
        "bright_green"
        "bright_yellow"
        "bright_blue"
        "bright_magenta"
        "bright_cyan"
        "bright_white"
      ];
}
// lib.mapAttrs (_: scope: editor // styles.${scope}) {
  editor_cursor = "ui.cursor";
  editor_cursor_primary = "ui.cursor.primary";
  editor_cursor_secondary = "ui.cursor";
  editor_line_highlight = "ui.cursorline.primary";
  editor_error = "error";
  editor_warning = "warning";
  editor_information = "info";
  editor_hint = "hint";
  editor_match = "ui.cursor.match";
  editor_selection = "ui.selection";
  editor_whitespace = "ui.virtual.whitespace";
  editor_gutter = "ui.linenr";
  editor_gutter_active = "ui.linenr.selected";
  editor_gutter_modified = "diff.delta";
  editor_gutter_added = "diff.plus";
  editor_gutter_deleted = "diff.minus";
  editor_widget = "ui.menu";
  editor_widget_border = "ui.linenr";
  statusbar = "ui.statusline";
  statusbar_hover = "ui.menu.selected";
  scrollbar = "ui.menu.scroll";
  scrollbar_hover = "ui.linenr.selected";
  scrollbar_active = "ui.menu.selected";
  sidebar = "ui.background";
  panel = "ui.popup";
  input = "ui.menu";
  input_border = "ui.linenr";
  input_placeholder = "ui.linenr";
  input_option_active = "ui.menu.selected";
  input_option_hover = "ui.cursorline.primary";
  tab_active = "ui.bufferline.active";
  tab_inactive = "ui.bufferline";
  tab_selected = "ui.menu.selected";
  tab_unfocused_active = "ui.statusline.inactive";
  tab_unfocused_inactive = "ui.bufferline";
}
// lib.mapAttrs' (name: value: lib.nameValuePair "ansi_${name}" (color value)) ansi
