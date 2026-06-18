; Specify nested languages that live within a `justfile`

; ================ Always applicable ================

((comment) @injection.content
  (#set! injection.language "comment"))

; Highlight the RHS of `=~` as regex
((regex
  (_) @injection.content)
  (#set! injection.language "regex"))

; ================ Global defaults ================

; Default recipe lines to be bash, but exclude interpolation nodes
; This prevents bash's rainbow brackets from interfering with just's {{ }} markers
; Use injection.combined to combine all recipe lines so bash can parse multi-line constructs
(file
  [
    (setting "shell" @_setting)
    (setting
      name: (identifier) @_setting)
  ]*
  (recipe
    .
    name: (identifier)
    (recipe_body
      !shebang
      (recipe_line) @injection.content
      (#set! injection.language "bash")
      (#set! injection.combined)))
  [
    (setting "shell" @_setting)
    (setting
      name: (identifier) @_setting)
  ]*
  (#not-eq? @_setting "shell")
  (#not-eq? @_setting "default-script"))

(external_command
  (content) @injection.content
  (#set! injection.language "bash"))

; ================ Global language specified ================
; Global language is set with something like one of the following:
;
;    set shell := ["bash", "-c", ...]
;    set shell := ["pwsh.exe"]
;
; We can extract the first item of the array, but we can't extract the language
; name from the string with something like regex. So instead we special case
; two things: powershell, which is likely to come with a `.exe` attachment that
; we need to strip, and everything else which hopefully has no extension. We
; separate this with a `#match?`.
;
; Unfortunately, there also isn't a way to allow arbitrary nesting or
; alternatively set "global" capture variables. So we can set this for item-
; level external commands, but not for e.g. external commands within an
; expression without getting _really_ annoying. Should at least look fine since
; they default to bash. Limitations...
; See https://github.com/tree-sitter/tree-sitter/issues/880 for more on that.

(file
  (setting "shell" ":=" "[" . (string) @_langstr
    (#match? @_langstr ".*(powershell|pwsh|cmd).*")
    (#set! injection.language "powershell"))
  (assignment
    (expression
      (value
        (external_command
          (content) @injection.content)))))

(file
  (setting "shell" ":=" "[" . (string) @_langstr
    (#eq? @_langstr "\"nu\"")
    (#set! injection.language "nu"))
  (assignment
    (expression
      (value
        (external_command
          (content) @injection.content)))))

(file
  (setting "shell" ":=" "[" . (string) @injection.language
    (#not-match? @injection.language ".*(powershell|pwsh|cmd).*")
    (#not-eq? @injection.language "\"nu\""))
  (assignment
    (expression
      (value
        (external_command
          (content) @injection.content)))))

; ================ Recipe language specified - Helix only ================

; Set highlighting for recipes that specify a language using builtin shebang matching
(recipe_body
  (shebang_line) @injection.shebang
  (recipe_line) @injection.content
  (#set! injection.combined))

; ================ Recipe shell specified ================

; These recipe-body rules override upstream's unanchored set-shell matches.
; [script] recipes are still overridden by the script-interpreter rules below.
(file
  [
    (setting "shell" @_setting)
    (setting
      name: (identifier) @_setting)
  ]*
  (setting "shell" ":=" "[" . (string) @_langstr
    (#match? @_langstr ".*(powershell|pwsh|cmd).*")
    (#set! injection.language "powershell"))
  [
    (setting "shell" @_setting)
    (setting
      name: (identifier) @_setting)
  ]*
  (recipe
    .
    name: (identifier)
    (recipe_body
      !shebang
      (recipe_line) @injection.content
      (#set! injection.combined)))
  [
    (setting "shell" @_setting)
    (setting
      name: (identifier) @_setting)
  ]*
  (#not-eq? @_setting "default-script"))

(file
  [
    (setting "shell" @_setting)
    (setting
      name: (identifier) @_setting)
  ]*
  (setting "shell" ":=" "[" . (string) @_langstr
    (#eq? @_langstr "\"nu\"")
    (#set! injection.language "nu"))
  [
    (setting "shell" @_setting)
    (setting
      name: (identifier) @_setting)
  ]*
  (recipe
    .
    name: (identifier)
    (recipe_body
      !shebang) @injection.content
    (#not-match? @injection.content "^\\s*@")
    (#set! injection.include-children))
  [
    (setting "shell" @_setting)
    (setting
      name: (identifier) @_setting)
  ]*
  (#not-eq? @_setting "default-script"))

(file
  [
    (setting "shell" @_setting)
    (setting
      name: (identifier) @_setting)
  ]*
  (setting "shell" ":=" "[" . (string) @injection.language
    (#not-match? @injection.language ".*(powershell|pwsh|cmd).*")
    (#not-eq? @injection.language "\"nu\""))
  [
    (setting "shell" @_setting)
    (setting
      name: (identifier) @_setting)
  ]*
  (recipe
    .
    name: (identifier)
    (recipe_body
      !shebang
      (recipe_line) @injection.content
      (#set! injection.combined)))
  [
    (setting "shell" @_setting)
    (setting
      name: (identifier) @_setting)
  ]*
  (#not-eq? @_setting "default-script"))

; ================ Default script specified ================

; With default-script enabled, plain recipes use script-interpreter too.
; Match both setting orders because just allows settings anywhere in the file.
(file
  (setting
    name: (identifier) @_script_interpreter
    ":="
    "["
    .
    (string) @_langstr
    (#eq? @_script_interpreter "script-interpreter")
    (#match? @_langstr ".*(powershell|pwsh|cmd).*")
    (#set! injection.language "powershell"))
  [
    (setting
      name: (identifier) @_default_script
      .
      (#eq? @_default_script "default-script"))
    (setting
      name: (identifier) @_default_script
      (boolean) @_default_script_value
      (#eq? @_default_script "default-script")
      (#eq? @_default_script_value "true"))
  ]
  (recipe
    (recipe_body
      !shebang
      (recipe_line) @injection.content
      (#set! injection.combined))))

(file
  (setting
    name: (identifier) @_script_interpreter
    ":="
    "["
    .
    (string) @_langstr
    (#eq? @_script_interpreter "script-interpreter")
    (#eq? @_langstr "\"nu\"")
    (#set! injection.language "nu"))
  [
    (setting
      name: (identifier) @_default_script
      .
      (#eq? @_default_script "default-script"))
    (setting
      name: (identifier) @_default_script
      (boolean) @_default_script_value
      (#eq? @_default_script "default-script")
      (#eq? @_default_script_value "true"))
  ]
  (recipe
    (recipe_body
      !shebang) @injection.content
    (#not-match? @injection.content "^\\s*@")
    (#set! injection.include-children)))

(file
  [
    (setting
      name: (identifier) @_default_script
      .
      (#eq? @_default_script "default-script"))
    (setting
      name: (identifier) @_default_script
      (boolean) @_default_script_value
      (#eq? @_default_script "default-script")
      (#eq? @_default_script_value "true"))
  ]
  (setting
    name: (identifier) @_script_interpreter
    ":="
    "["
    .
    (string) @_langstr
    (#eq? @_script_interpreter "script-interpreter")
    (#match? @_langstr ".*(powershell|pwsh|cmd).*")
    (#set! injection.language "powershell"))
  (recipe
    (recipe_body
      !shebang
      (recipe_line) @injection.content
      (#set! injection.combined))))

(file
  [
    (setting
      name: (identifier) @_default_script
      .
      (#eq? @_default_script "default-script"))
    (setting
      name: (identifier) @_default_script
      (boolean) @_default_script_value
      (#eq? @_default_script "default-script")
      (#eq? @_default_script_value "true"))
  ]
  (setting
    name: (identifier) @_script_interpreter
    ":="
    "["
    .
    (string) @_langstr
    (#eq? @_script_interpreter "script-interpreter")
    (#eq? @_langstr "\"nu\"")
    (#set! injection.language "nu"))
  (recipe
    (recipe_body
      !shebang) @injection.content
    (#not-match? @injection.content "^\\s*@")
    (#set! injection.include-children)))

(file
  (setting
    name: (identifier) @_script_interpreter
    ":="
    "["
    .
    (string) @injection.language
    (#eq? @_script_interpreter "script-interpreter")
    (#not-match? @injection.language ".*(powershell|pwsh|cmd).*")
    (#not-eq? @injection.language "\"nu\""))
  [
    (setting
      name: (identifier) @_default_script
      .
      (#eq? @_default_script "default-script"))
    (setting
      name: (identifier) @_default_script
      (boolean) @_default_script_value
      (#eq? @_default_script "default-script")
      (#eq? @_default_script_value "true"))
  ]
  (recipe
    (recipe_body
      !shebang
      (recipe_line) @injection.content
      (#set! injection.combined))))

(file
  [
    (setting
      name: (identifier) @_default_script
      .
      (#eq? @_default_script "default-script"))
    (setting
      name: (identifier) @_default_script
      (boolean) @_default_script_value
      (#eq? @_default_script "default-script")
      (#eq? @_default_script_value "true"))
  ]
  (setting
    name: (identifier) @_script_interpreter
    ":="
    "["
    .
    (string) @injection.language
    (#eq? @_script_interpreter "script-interpreter")
    (#not-match? @injection.language ".*(powershell|pwsh|cmd).*")
    (#not-eq? @injection.language "\"nu\""))
  (recipe
    (recipe_body
      !shebang
      (recipe_line) @injection.content
      (#set! injection.combined))))

; ================ Script interpreter specified ================

; Highlight [script] recipes using the global script-interpreter setting.
(file
  (setting
    name: (identifier) @_setting
    ":="
    "["
    .
    (string) @_langstr
    (#eq? @_setting "script-interpreter")
    (#match? @_langstr ".*(powershell|pwsh|cmd).*")
    (#set! injection.language "powershell"))
  (recipe
    (attribute
      name: (identifier) @_script) @_script_attribute
    (recipe_body
      !shebang
      (recipe_line) @injection.content
      (#eq? @_script "script")
      (#eq? @_script_attribute "script")
      (#set! injection.combined))))

(file
  (setting
    name: (identifier) @_setting
    ":="
    "["
    .
    (string) @_langstr
    (#eq? @_setting "script-interpreter")
    (#eq? @_langstr "\"nu\"")
    (#set! injection.language "nu"))
  (recipe
    (attribute
      name: (identifier) @_script) @_script_attribute
    (recipe_body
      !shebang) @injection.content
      (#eq? @_script "script")
      (#eq? @_script_attribute "script")
      (#not-match? @injection.content "^\\s*@")
      (#set! injection.include-children)))

(file
  (setting
    name: (identifier) @_setting
    ":="
    "["
    .
    (string) @injection.language
    (#eq? @_setting "script-interpreter")
    (#not-match? @injection.language ".*(powershell|pwsh|cmd).*")
    (#not-eq? @injection.language "\"nu\""))
  (recipe
    (attribute
      name: (identifier) @_script) @_script_attribute
    (recipe_body
      !shebang
      (recipe_line) @injection.content
      (#eq? @_script "script")
      (#eq? @_script_attribute "script")
      (#set! injection.combined))))
