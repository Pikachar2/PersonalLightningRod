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
		type = "lightning-attractor",
		name = "personal-lightning-rod",
		efficiency = 0.4,
		range_elongation = 5.0,
		icon = "__space-age__/graphics/icons/lightning-collector.png",
		icon_size = 32,
		flags = { 'placeable-off-grid', 'not-on-map' },
		minable = nil,
		max_health = 500,
		corpse = nil,
		dying_explosion = nil,
--		factoriopedia_simulation = simulations.factoriopedia_lightning_collector,
		alert_icon_scale = 0,
		energy_source =
		{
			type = "electric",
			buffer_capacity = "1000MJ",
			usage_priority = "primary-output",
			output_flow_limit = "1000MJ",
--			input_flow_limit = '200kW',
			drain = "2.5MJ"
		},
		resistances = all_resistances,
		collision_box = {{ -0.2, -0.2 }, { 0.2, 0.2 }},
		selection_box = {{ -0.01, -0.01 }, { 0.01, 0.01 }},
		collision_mask = {
			layers =
			{ }
		},
		lightning_strike_offset = {0, -4.8},
		damaged_trigger_effect = hit_effects.entity({{-0.5, -2.5}, {0.5, 0.5}}),
--		drawing_box_vertical_extension = 4.5,
--		impact_category = "metal",
--		open_sound = sounds.electric_large_open,
--		close_sound = sounds.electric_large_close,

		chargable_graphics = require("__space-age__.prototypes.entity.lightning-collector-graphics"),
--[[
		water_reflection =
		{
		  pictures =
		  {
			filename = "__space-age__/graphics/entity/lightning-collector/lightning-collector-reflection.png",
			priority = "extra-high",
			width = 20,
			height = 28,
			shift = util.by_pixel(0, 55),
			variation_count = 1,
			scale = 5
		  },
		  rotate = false,
		  orientation_to_variation = false
		},

		working_sound =
		{
		  main_sounds =
		  {
			{
			  sound = {filename = "__space-age__/sound/entity/lightning-attractor/lightning-attractor-charge.ogg", volume = 0.7},
			  match_volume_to_activity = true,
			  activity_to_volume_modifiers = {offset = 2, inverted = true},
			},
			{
			  sound = {filename = "__space-age__/sound/entity/lightning-attractor/lightning-attractor-discharge.ogg", volume = 0.8},
			  match_volume_to_activity = true,
			  activity_to_volume_modifiers = {offset = 1},
			}
		  },
		  max_sounds_per_type = 3,
		  audible_distance_modifier = 0.5,
		}
--]]
  }
}