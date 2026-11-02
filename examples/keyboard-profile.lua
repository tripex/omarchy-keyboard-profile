-- Keyboard profiles: quick switch between a Mac and a Windows keyboard.
-- Switch with SUPER + ALT + L or the MAC/WIN widget in the bar. The chosen profile
-- applies to all keyboards and survives a reboot.
--
-- Put bindings in a profile's bindings function. They're only active while that
-- profile is chosen. Bindings for both keyboards belong in bindings.lua.
--
-- kb_layout, kb_variant and kb_options are optional. Leave them out to keep what
-- input.lua sets. Setting kb_options replaces Omarchy's default, so repeat
-- "compose:caps" if you want to keep the compose key.

local paths = require("default.hypr.paths")

local profiles = {
  mac = {
    -- kb_layout = "us",
    -- kb_variant = "mac",
    bindings = function()
      -- Command+Q closes the window, like on macOS.
      o.bind("SUPER + Q", "Close window", hl.dsp.window.close())
    end,
  },

  windows = {
    -- kb_layout = "us",
    -- Swap Alt and the Windows key, so they sit where they do on a Mac:
    -- kb_options = "compose:caps,altwin:swap_lalt_lwin",
    bindings = function()
      -- Alt+F4 closes the window, like on Windows.
      o.bind("ALT + F4", "Close window", hl.dsp.window.close())
    end,
  },
}

local function active_profile()
  local file = io.open(paths.state_home .. "/tripex-keyboard-profile/active", "r")
  if not file then
    return profiles.mac
  end

  local name = file:read("l")
  file:close()
  return profiles[name] or profiles.mac
end

local profile = active_profile()

hl.config({
  input = {
    kb_layout = profile.kb_layout,
    kb_variant = profile.kb_variant,
    kb_options = profile.kb_options,
  },
})

profile.bindings()

o.bind(
  "SUPER + ALT + L",
  "Switch keyboard (Mac/Windows)",
  paths.home .. "/.config/omarchy/plugins/tripex.keyboard-profile/bin/keyboard-profile toggle"
)

-- Read by the plugin's bin/profile-bindings.lua, so the bar can list both profiles.
return profiles
