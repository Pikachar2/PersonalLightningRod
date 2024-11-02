require('prototypes.entity')
require('prototypes.equipment')
require('prototypes.item')
require('prototypes.recipe')
require('prototypes.shortcuts')
require('prototypes.technology')


if not settings.startup["personal-transformer2-allow-non-armor"].value then
-- This loop is for adding the 'armor-transformer' category to each grid found in armors.
-- This allows us to not allow equipment with the 'armor-transformer' category to be placed in grids without the 'armor-transformer' tag.
	for _, armor in pairs (data.raw.armor) do
--	  log('\n\n')
--	  log('ARMOR LOOP: ')
--	  log (serpent.block (armor))

	  if armor.equipment_grid then
		local found = 0
		local grid = data.raw['equipment-grid'][armor.equipment_grid]
	--	log('\n\n')
	--	log('GRID: ')
	--    log (serpent.block (grid))
		if type (grid.equipment_categories) == 'string' and grid.equipment_categories == 'armor' then
		  found = 1
	--    log ('found string type')
		elseif type (grid.equipment_categories) == 'table' and #grid.equipment_categories > 0 then
		  for _, category in pairs (grid.equipment_categories) do
			if category == "armor" and found ~= 2 then
			  found = 1
	--          log ('found table type')
			elseif category == 'armor-transformer' then
			  found = 2 -- measure to ensure that it doesn't add the category if it's already there
			end
		  end
		end
		if found == 1 then
	--      log ('If Found....')
		  grid.equipment_categories = grid.equipment_categories and grid.equipment_categories[1] and grid.equipment_categories or {grid.equipment_categories}
		  table.insert (grid.equipment_categories, "armor-transformer")
	--	    log('\n\n')
	--	    log('GRID2: ')
	--      log ('second log: '..serpent.block (grid))
		end
	  end
	end
end

data:extend(
{
  {
    type = "equipment-category",
    name = "armor-transformer"
  }
}
)

-- Mk1
data.raw["battery-equipment"]["personal-transformer-equipment"].energy_source.input_flow_limit = settings.startup["personal-transformer-mk1-flow-limit"].value .. "kW"
data.raw["battery-equipment"]["personal-transformer-equipment"].energy_source.output_flow_limit = settings.startup["personal-transformer-mk1-flow-limit"].value .. "kW"
data.raw["battery-equipment"]["personal-transformer-equipment"].energy_source.buffer_capacity = settings.startup["personal-transformer-mk1-flow-limit"].value/10 .. "kJ"
data.raw["electric-energy-interface"]["personal-transformer-input-entity"].energy_source.input_flow_limit = settings.startup["personal-transformer-mk1-flow-limit"].value .. "kW"
data.raw["electric-energy-interface"]["personal-transformer-input-entity"].energy_source.buffer_capacity = settings.startup["personal-transformer-mk1-flow-limit"].value/10 .. "kJ"
data.raw["accumulator"]["personal-transformer-output-entity"].energy_source.output_flow_limit = settings.startup["personal-transformer-mk1-flow-limit"].value .. "kW"
data.raw["accumulator"]["personal-transformer-output-entity"].energy_source.buffer_capacity = settings.startup["personal-transformer-mk1-flow-limit"].value/10 .. "kJ"
-- Mk2
data.raw["battery-equipment"]["personal-transformer-mk2-equipment"].energy_source.input_flow_limit = settings.startup["personal-transformer-mk2-flow-limit"].value .. "kW"
data.raw["battery-equipment"]["personal-transformer-mk2-equipment"].energy_source.output_flow_limit = settings.startup["personal-transformer-mk2-flow-limit"].value .. "kW"
data.raw["battery-equipment"]["personal-transformer-mk2-equipment"].energy_source.buffer_capacity = settings.startup["personal-transformer-mk2-flow-limit"].value/10 .. "kJ"
data.raw["electric-energy-interface"]["personal-transformer-mk2-input-entity"].energy_source.input_flow_limit = settings.startup["personal-transformer-mk2-flow-limit"].value .. "kW"
data.raw["electric-energy-interface"]["personal-transformer-mk2-input-entity"].energy_source.buffer_capacity = settings.startup["personal-transformer-mk2-flow-limit"].value/10 .. "kJ"
data.raw["accumulator"]["personal-transformer-mk2-output-entity"].energy_source.output_flow_limit = settings.startup["personal-transformer-mk2-flow-limit"].value .. "kW"
data.raw["accumulator"]["personal-transformer-mk2-output-entity"].energy_source.buffer_capacity = settings.startup["personal-transformer-mk2-flow-limit"].value/10 .. "kJ"
-- Mk3
data.raw["battery-equipment"]["personal-transformer-mk3-equipment"].energy_source.input_flow_limit = settings.startup["personal-transformer-mk3-flow-limit"].value .. "kW"
data.raw["battery-equipment"]["personal-transformer-mk3-equipment"].energy_source.output_flow_limit = settings.startup["personal-transformer-mk3-flow-limit"].value .. "kW"
data.raw["battery-equipment"]["personal-transformer-mk3-equipment"].energy_source.buffer_capacity = settings.startup["personal-transformer-mk3-flow-limit"].value/10 .. "kJ"
data.raw["electric-energy-interface"]["personal-transformer-mk3-input-entity"].energy_source.input_flow_limit = settings.startup["personal-transformer-mk3-flow-limit"].value .. "kW"
data.raw["electric-energy-interface"]["personal-transformer-mk3-input-entity"].energy_source.buffer_capacity = settings.startup["personal-transformer-mk3-flow-limit"].value/10 .. "kJ"
data.raw["accumulator"]["personal-transformer-mk3-output-entity"].energy_source.output_flow_limit = settings.startup["personal-transformer-mk3-flow-limit"].value .. "kW"
data.raw["accumulator"]["personal-transformer-mk3-output-entity"].energy_source.buffer_capacity = settings.startup["personal-transformer-mk3-flow-limit"].value/10 .. "kJ"

