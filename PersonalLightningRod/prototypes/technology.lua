data:extend{
	{
		type = 'technology',
		name = 'personal-transformer-equipment',
		icon = '__PersonalTransformer2__/graphics/technology/personal-transformer.png',
		icon_size = 32,
		unit =
		{
			count = 150,
			ingredients =
			{
				{ 'automation-science-pack', 1 },
				{ 'logistic-science-pack', 1 },
				{ 'chemical-science-pack', 1 }
			},
			time = 15
		},
		prerequisites = { 'solar-panel-equipment', 'battery', 'chemical-science-pack' },
		effects =
		{
			{
				type = 'unlock-recipe',
				recipe = 'personal-transformer-equipment'
			}
		}
	},
	{
		type = 'technology',
		name = 'personal-transformer-mk2-equipment',
		icon = '__PersonalTransformer2__/graphics/technology/personal-transformer2.png',
		icon_size = 32,
		unit =
		{
			count = 250,
			ingredients =
			{
				{ 'automation-science-pack', 1 },
				{ 'logistic-science-pack', 1 },
				{ 'chemical-science-pack', 1 },
				{ 'production-science-pack', 1 }
			},
			time = 30
		},
		prerequisites = { 'electric-energy-accumulators', 'low-density-structure', 'personal-transformer-equipment', 'production-science-pack' },
		effects =
		{
			{
				type = 'unlock-recipe',
				recipe = 'personal-transformer-mk2-equipment'
			}
		}
	},
	{
		type = 'technology',
		name = 'personal-transformer-mk3-equipment',
		icon = '__PersonalTransformer2__/graphics/technology/personal-transformer3.png',
		icon_size = 32,
		unit =
		{
			count = 500,
			ingredients =
			{
				{ 'automation-science-pack', 1 },
				{ 'logistic-science-pack', 1 },
				{ 'chemical-science-pack', 1 },
				{ 'production-science-pack', 1 },
				{ 'utility-science-pack', 1 }
			},
			time = 30
		},
		prerequisites = { 'personal-transformer-mk2-equipment', 'utility-science-pack' },
		effects =
		{
			{
				type = 'unlock-recipe',
				recipe = 'personal-transformer-mk3-equipment'
			}
		}
	}
}