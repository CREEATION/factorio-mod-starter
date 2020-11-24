local _ = require("global")

-------------------------------------------
-- startup:
-- data:extend(_.settings())

-------------------------------------------
-- runtime-global:
-- data:extend(_.settings())

-------------------------------------------
-- runtime-per-user:
data:extend(
  _.settings(
    -- properties applied to all settings
    {
      setting_type = "runtime-per-user",
    },
    -- settings
    {
      -- [checkbox] enable/disable mod
      {
        type = "bool-setting",
        name = "enable",
        default_value = true,
        order = "-",
        font = "heading-2",
      },
    }
  )
)
