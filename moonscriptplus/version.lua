local version = "0.1.0"
return {
  version = version,
  print_version = function()
    return print("MoonScript Plus version " .. tostring(version))
  end
}
