data:extend
{
  {
    type = "bool-setting",
    name = "personal-transformer2-allow-non-armor",
    setting_type = "startup",
    default_value = false,
    per_user = false,
    order = "a1"
  },
  {
    type = "int-setting",
    name = "personal-transformer2-tick-delay",
    setting_type = "runtime-global",
	minimum_value = 1,
	maximum_value = 60,
    default_value = 1,
    per_user = false,
    order = "a2"
  },
  {
    type = "double-setting",
    name = "personal-transformer-mk1-flow-limit",
    setting_type = "startup",
	minimum_value = 0,
    default_value = 200,
    per_user = false,
    order = "a2"
  },
  {
    type = "double-setting",
    name = "personal-transformer-mk2-flow-limit",
    setting_type = "startup",
	minimum_value = 0,
    default_value = 1000,
    per_user = false,
    order = "a2"
  },
  {
    type = "double-setting",
    name = "personal-transformer-mk3-flow-limit",
    setting_type = "startup",
	minimum_value = 0,
    default_value = 4000,
    per_user = false,
    order = "a2"
  }
}