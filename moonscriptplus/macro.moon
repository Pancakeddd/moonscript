class Macros
  new: =>
    @macros = {}

  add_macro: (name, value) =>
    @macros[name] = value

  is_macro: (name) =>
    return true if @macros[name]
    false

  get_macro: (name) =>
    return @macros[name]

m = Macros!

m