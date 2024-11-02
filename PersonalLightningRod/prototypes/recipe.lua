data:extend{
	{
		type = 'recipe',
		name = 'personal-transformer-equipment',
		energy_required = 10,
		ingredients =
		{
			{type = "item", name = "steel-plate", amount = 10},
			{type = "item", name = "battery", amount = 5},
			{type = "item", name = "copper-cable", amount = 100}
		},
		enabled = false,
        results = {{type = "item", name = "personal-transformer-equipment", amount = 1}}
	},
	{
		type = 'recipe',
		name = 'personal-transformer-mk2-equipment',
		energy_required = 10,
		ingredients =
		{
			{type = "item", name = "low-density-structure", amount = 10},
			{type = "item", name = "processing-unit", amount = 20},
			{type = "item", name = "personal-transformer-equipment", amount = 5}
		},
		enabled = false,
        results = {{type = "item", name = "personal-transformer-mk2-equipment", amount = 1}}
	},
	{
		type = 'recipe',
		name = 'personal-transformer-mk3-equipment',
		energy_required = 10,
		ingredients =
		{
			{type = "item", name = "low-density-structure", amount = 50},
			{type = "item", name = "processing-unit", amount = 100},
			{type = "item", name = "accumulator", amount = 10},
			{type = "item", name = "personal-transformer-mk2-equipment", amount = 5}
		},
		enabled = false,
        results = {{type = "item", name = "personal-transformer-mk3-equipment", amount = 1}}
	}
}