local all_resistances = {
			{
				type = 'physical',
				percent = 100
			},
			{
				type = 'impact',
				percent = 100
			},
			{
				type = 'poison',
				percent = 100
			},
			{
				type = 'explosion',
				percent = 100
			},
			{
				type = 'fire',
				percent = 100
			},
			{
				type = 'laser',
				percent = 100
			},
			{
				type = 'acid',
				percent = 100
			},
			{
				type = 'electric',
				percent = 100
			}
		}

data:extend{
	{
		type = 'electric-energy-interface',
		name = 'personal-transformer-input-entity',
		icon = '__base__/graphics/icons/power-armor.png',
		icon_size = 32,
		flags = { 'placeable-off-grid', 'not-on-map' },
		minable = nil,
		max_health = 500,
		resistances = all_resistances,
		collision_box = {{ -0.2, -0.2 }, { 0.2, 0.2 }},
		selection_box = {{ -0.01, -0.01 }, { 0.01, 0.01 }},
		collision_mask = {
			layers =
			{ }
		},
		alert_icon_scale = 0,
		energy_source =
		{
			type = 'electric',
			buffer_capacity = '20kJ',
			usage_priority = 'secondary-input',
			input_flow_limit = '200kW',
			output_flow_limit = '0kW'
		},
		picture =
		{
			layers =
			{
				{
					filename = '__PersonalTransformer2__/graphics/empty.png',
					priority = "high",
					frames = 1,
					width = 32,
					height = 32
				}
			}
		}
	},
	{
		type = 'accumulator',
		name = 'personal-transformer-output-entity',
		icon = '__base__/graphics/icons/power-armor.png',
		icon_size = 32,
		flags = { 'placeable-off-grid', 'not-on-map' },
		minable = nil,
		max_health = 500,
		resistances = all_resistances,
		collision_box = {{ -0.2, -0.2 }, { 0.2, 0.2 }},
		selection_box = {{ -0.01, -0.01 }, { 0.01, 0.01 }},
		collision_mask = {
			layers =
			{ }
		},
		alert_icon_scale = 0,
		energy_source =
		{
			type = 'electric',
			buffer_capacity = '20kJ',
			usage_priority = 'tertiary',
			input_flow_limit = '0kW',
			output_flow_limit = '200kW'
		},
		charge_cooldown = 30,
		discharge_cooldown = 60,
		picture =
		{
			layers =
			{
				{
					filename = '__PersonalTransformer2__/graphics/empty.png',
					priority = "high",
					frames = 1,
					width = 32,
					height = 32
				}
			}
		}
	},
	{
		type = 'electric-energy-interface',
		name = 'personal-transformer-mk2-input-entity',
		icon = '__base__/graphics/icons/power-armor.png',
		icon_size = 32,
		flags = { 'placeable-off-grid', 'not-on-map' },
		minable = nil,
		max_health = 500,
		resistances = all_resistances,
		collision_box = {{ -0.2, -0.2 }, { 0.2, 0.2 }},
		selection_box = {{ -0.01, -0.01 }, { 0.01, 0.01 }},
		collision_mask = {
			layers =
			{ }
		},
		alert_icon_scale = 0,
		energy_source =
		{
			type = 'electric',
			buffer_capacity = '100kJ',
			usage_priority = 'secondary-input',
			input_flow_limit = '1MW',
			output_flow_limit = '0kW'
		},
		picture =
		{
			layers =
			{
				{
					filename = '__PersonalTransformer2__/graphics/empty.png',
					priority = "high",
					frames = 1,
					width = 32,
					height = 32
				}
			}
		}
	},
	{
		type = 'accumulator',
		name = 'personal-transformer-mk2-output-entity',
		icon = '__base__/graphics/icons/power-armor.png',
		icon_size = 32,
		flags = { 'placeable-off-grid', 'not-on-map' },
		minable = nil,
		max_health = 500,
		resistances = all_resistances,
		collision_box = {{ -0.2, -0.2 }, { 0.2, 0.2 }},
		selection_box = {{ -0.01, -0.01 }, { 0.01, 0.01 }},
		collision_mask = {
			layers =
			{ }
		},
		alert_icon_scale = 0,
		energy_source =
		{
			type = 'electric',
			buffer_capacity = '100kJ',
			usage_priority = 'tertiary',
			input_flow_limit = '0kW',
			output_flow_limit = '1MW'
		},
		charge_cooldown = 30,
		discharge_cooldown = 60,
		picture =
		{
			layers =
			{
				{
					filename = '__PersonalTransformer2__/graphics/empty.png',
					priority = "high",
					frames = 1,
					width = 32,
					height = 32
				}
			}
		}
	},
	{
		type = 'electric-energy-interface',
		name = 'personal-transformer-mk3-input-entity',
		icon = '__base__/graphics/icons/power-armor.png',
		icon_size = 32,
		flags = { 'placeable-off-grid', 'not-on-map' },
		minable = nil,
		max_health = 500,
		resistances = all_resistances,
		collision_box = {{ -0.2, -0.2 }, { 0.2, 0.2 }},
		selection_box = {{ -0.01, -0.01 }, { 0.01, 0.01 }},
		collision_mask = {
			layers =
			{ }
		},
		alert_icon_scale = 0,
		energy_source =
		{
			type = 'electric',
			buffer_capacity = '400kJ',
			usage_priority = 'secondary-input',
			input_flow_limit = '4MW',
			output_flow_limit = '0kW'
		},
		picture =
		{
			layers =
			{
				{
					filename = '__PersonalTransformer2__/graphics/empty.png',
					priority = "high",
					frames = 1,
					width = 32,
					height = 32
				}
			}
		}
	},
	{
		type = 'accumulator',
		name = 'personal-transformer-mk3-output-entity',
		icon = '__base__/graphics/icons/power-armor.png',
		icon_size = 32,
		flags = { 'placeable-off-grid', 'not-on-map' },
		minable = nil,
		max_health = 500,
		resistances = all_resistances,
		collision_box = {{ -0.2, -0.2 }, { 0.2, 0.2 }},
		selection_box = {{ -0.01, -0.01 }, { 0.01, 0.01 }},
		collision_mask = {
			layers =
			{ }
		},
		alert_icon_scale = 0,
		energy_source =
		{
			type = 'electric',
			buffer_capacity = '400kJ',
			usage_priority = 'tertiary',
			input_flow_limit = '0kW',
			output_flow_limit = '4MW'
		},
		charge_cooldown = 30,
		discharge_cooldown = 60,
		picture =
		{
			layers =
			{
				{
					filename = '__PersonalTransformer2__/graphics/empty.png',
					priority = "high",
					frames = 1,
					width = 32,
					height = 32
				}
			}
		}
	}
}