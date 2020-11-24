local _GLOBAL = {
  mod = {
    namespace = "c7",
    name = "chat_accessibility",
    title = "Chat Accessibility",
    sep = ":",
    settings = {
      types_names = {
        ["startup"] = "startup",
        ["runtime-global"] = "global",
        ["runtime-per-user"] = "player",
      },
      default_values = {
        ["bool-setting"] = false,
        ["int-setting"] = 0,
        ["double-setting"] = 0.0,
        ["string-setting"] = "",
      },
      default_order = "a",
    }
  }
}

_GLOBAL.get_startup_setting = function (setting_name)
  return settings.startup[_GLOBAL.setting_name(setting_name, "startup")].value
end

_GLOBAL.get_global_setting = function (setting_name)
  return settings.global[_GLOBAL.setting_name(setting_name, "runtime-global")].value
end

_GLOBAL.get_player_setting = function (player_index, setting_name)
  return game.players[player_index].mod_settings[_GLOBAL.setting_name(setting_name, "runtime-per-user")].value
end

_GLOBAL.setting_name = function (name, type)
  local mod = _GLOBAL.mod

  return table.concat({
    mod.namespace,
    mod.name,
    "settings",
    mod.settings.types_names[type],
    name
  }, mod.sep)
end

_GLOBAL.setting_default_value = function (setting)
  local mod = _GLOBAL.mod

  -- skip setting default value if there's already one set
  for property, _ in pairs(setting) do
    if property == "default_value" then
      return setting
    end
  end

  for property, setting_type in pairs(setting) do
    if property == "type" then
      setting.default_value = mod.settings.default_values[setting_type]
    end
  end

  return setting
end

_GLOBAL.setting_localise = function (setting)
  local mod = _GLOBAL.mod
  local localised_setting_name = table.concat({
    mod.namespace,
    mod.name,
    setting.name
  }, mod.sep)

  setting.localised_name = {
    table.concat({
      "mod-setting-name",
      localised_setting_name
    }, ".")
  }

  -- apply richtext formatting to setting if set
  setting = _GLOBAL.setting_richtext(setting)

  setting.localised_description = {
    table.concat({
      "mod-setting-description",
      localised_setting_name
    }, ".")
  }

  return setting
end

_GLOBAL.setting_order = function(setting)
  local mod = _GLOBAL.mod

  if type(setting.order) == "nil" then
    setting.order = mod.settings.default_order
  end

  return setting
end

--@TODO: yikes
_GLOBAL.setting_richtext = function(setting)
  local richtext_format = function(type, property, str)
    if type == "start" then
      return string.format("[" .. property .. "=%s]%s", setting[property], str)
    end

    return string.format("%s[/" .. property .. "]", str)
  end

  local richtext_start = ""
  local richtext_end = ""

  if not(type(setting.color) == "nil") then
    richtext_start = richtext_format("start", "color", richtext_start)
    richtext_end = richtext_format("end", "color", richtext_end)
  end

  if not(type(setting.font) == "nil") then
    richtext_start = richtext_format("start", "font", richtext_start)
    richtext_end = richtext_format("end", "font", richtext_end)
  end

  setting.localised_name = {
    setting.localised_name[1],
    richtext_start,
    richtext_end
  }

  -- remove non-standard "color" and "font" properties
  setting.color = nil
  setting.font = nil

  return setting
end

_GLOBAL.settings = function (global_properties, settings)
  -- set global properties & normalize default values
  for global_property, global_value in pairs(global_properties) do
    for i, _ in pairs(settings) do
      settings[i][global_property] = global_value
    end
  end

  -- transform setting
  for i, _ in pairs(settings) do
    -- set localise strings (name and description)
    settings[i] = _GLOBAL.setting_localise(settings[i])

    -- set default value if there's none set already
    settings[i] = _GLOBAL.setting_default_value(settings[i])

    -- set default order if there's none set already
    settings[i] = _GLOBAL.setting_order(settings[i])

    for property, value in pairs(settings[i]) do
      -- set setting name according to mod settings
      if property == "name" then
        settings[i].name = _GLOBAL.setting_name(value, settings[i].setting_type)
      end
    end
  end

  return settings
end

if type(global) == "nil" then
  return _GLOBAL
end

for key, value in pairs(_GLOBAL) do
  global[key] = value
end
