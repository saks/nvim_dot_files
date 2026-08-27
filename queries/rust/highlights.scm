; extends

; `use { foo, Bar }` — lowercase names are functions, not plain variables.
(use_list
  (identifier) @function
  (#lua-match? @function "^[a-z]")
  (#set! priority 110))
