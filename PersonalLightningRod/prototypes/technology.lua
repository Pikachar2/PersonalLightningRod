data:extend{
	{
		type = 'technology',
		name = 'personal-lightning-rod-equipment',
		icon = '__space-age__/graphics/icons/lightning-collector.png',
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
				recipe = 'personal-lightning-rod-equipment'
			}
		}
	}
}