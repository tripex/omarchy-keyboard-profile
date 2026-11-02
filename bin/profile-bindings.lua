-- Print each keyboard profile's own bindings as "profile<TAB>keys<TAB>description".
-- Runs the real profile file against stubs, like omarchy-menu-keybindings does
-- with the whole config, so the list can't drift from what Hyprland gets bound.

local MODIFIERS = { "SUPER", "SHIFT", "CTRL", "ALT" }

local noop
noop = setmetatable({}, {
  __index = function()
    return noop
  end,
  __call = function()
    return noop
  end,
})

-- "SUPER + ALT + L" reads "SUPER ALT + L" in the keybindings menu.
local function menu_keys(keys)
  local held = {}
  local key = ""

  for part in string.gmatch(keys, "[^+]+") do
    local value = part:gsub("^%s+", ""):gsub("%s+$", "")
    local upper = value:upper()
    if upper == "SUPER" or upper == "SHIFT" or upper == "CTRL" or upper == "ALT" then
      held[upper] = true
    else
      key = value
    end
  end

  local mods = {}
  for _, modifier in ipairs(MODIFIERS) do
    if held[modifier] then
      mods[#mods + 1] = modifier
    end
  end

  if #mods == 0 then
    return key
  end
  return table.concat(mods, " ") .. " + " .. key
end

hl = noop
o = noop
package.loaded["default.hypr.paths"] = { home = "", config_home = "", state_home = "" }

local config_home = os.getenv("XDG_CONFIG_HOME")
if config_home == nil or config_home == "" then
  config_home = os.getenv("HOME") .. "/.config"
end

local profiles = dofile(config_home .. "/hypr/keyboard-profile.lua")

for _, name in ipairs({ "mac", "windows" }) do
  o = {
    bind = function(keys, description)
      print(table.concat({ name, menu_keys(keys), description or "" }, "\t"))
    end,
  }
  profiles[name].bindings()
end
