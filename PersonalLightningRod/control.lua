local vehicle_armor_transformers = nil
local my_types = {"car", "spider-vehicle", "locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon"}

-- This is a delay constant for controlling how often the transformer script runs. The mod will behave reasonably for any value from 1 to 6.
-- Lower values are more UPS intensive but have finer updates, while higher values are less UPS intensive but have coarser updates.
local tickdelay = settings.global["personal-transformer2-tick-delay"].value


local mk1_draw = settings.startup["personal-transformer-mk1-flow-limit"].value * 1000
local mk2_draw = settings.startup["personal-transformer-mk2-flow-limit"].value * 1000
local mk3_draw = settings.startup["personal-transformer-mk3-flow-limit"].value * 1000

--local mk1_draw = 200000
--local mk2_draw = 1000000
--local mk3_draw = 4000000

-- grid_owner_type can be "player" or "entity"

local personal_transformer_mk1_name = "personal-transformer-equipment"
local personal_transformer_mk2_name = "personal-transformer-mk2-equipment"
local personal_transformer_mk3_name = "personal-transformer-mk3-equipment"
local isVehicleGridAllowed = settings.startup["personal-transformer2-allow-non-armor"].value;

local transformer_draw = {}
transformer_draw[personal_transformer_mk1_name] = mk1_draw
transformer_draw[personal_transformer_mk2_name] = mk2_draw
transformer_draw[personal_transformer_mk3_name] = mk3_draw

-- need grid_vehicles in order to reference vehicle by grid
storage.grid_vehicles = storage.grid_vehicles or {}
storage.transformer_data = storage.transformer_data or {}

local vehicle_event_filters = {
	{filter = "type", type = "car"},
	{filter = "type", type = "spider-vehicle"},
	{filter = "type", type = "locomotive"},
	{filter = "type", type = "cargo-wagon"},
	{filter = "type", type = "fluid-wagon"},
	{filter = "type", type = "artillery-wagon"}
}

local pt_entity_event_filters = {
	{filter = "name", name = "personal-transformer-input-entity"},
	{filter = "name", name = "personal-transformer-output-entity"},
	{filter = "name", name = "personal-transformer-mk2-input-entity"},
	{filter = "name", name = "personal-transformer-mk2-output-entity"},
	{filter = "name", name = "personal-transformer-mk3-input-entity"},
	{filter = "name", name = "personal-transformer-mk3-output-entity"}
}

local is_quality_enabled = script.active_mods["quality"] 


--[[
	storage.transformer_data[grid_id] = {
		grid_transformer_entities = {list of transformer entities},
		transformer_count[level] = someNum
		grid_owner_id = someNum
		grid_owner_type = player/entity
		max_grid_draw = someNum
		buffer = max_grid_draw/10
	}
--]]

script.on_init(
	function()
		storage.transformer_data = storage.transformer_data or {}
		-- log ('init --- storage.transformer_data = '.. serpent.dump(storage.transformer_data))
		-- I don't like this, but it wont work in on_init for some reason... need to figure that out once the rest is working
		if storage.transformer_data == nil then
			storage.transformer_data = {}
		end

		storage.grid_vehicles = storage.grid_vehicles or {}
		storage.vehicles = storage.vehicles or {}
	end
)

script.on_load(
	function()
--		log ('on_load --- mk1_draw: ' .. serpent.block(mk1_draw))
--		log ('on_load --- mk2_draw: ' .. serpent.block(mk2_draw))
--		log ('on_load --- mk3_draw: ' .. serpent.block(mk3_draw))

	end
)

script.on_configuration_changed(
	function(data)
	-- storage.grid_vehicles = {}
		log ('on_configuration_changed --- migrations starting...')
		log ('on_configuration_changed start --- storage.grid_vehicles = '.. serpent.block(storage.grid_vehicles))
		if storage.transformer_data == nil then
			storage.transformer_data = {}
		end
		storage.grid_vehicles = {}
		for s, surface in pairs(game.surfaces) do
			for v, vehicle in pairs(surface.find_entities_filtered{type = my_types}) do
				if vehicle and vehicle.valid then
					log ('on_configuration_changed valid vehicle --- vehicle.unit_number: ' .. serpent.block(vehicle.unit_number))
					grid = vehicle.grid
					if grid and grid.valid then
						log ('on_configuration_changed valid grid --- grid.unique_id: ' .. serpent.block(grid.unique_id))
						storage.grid_vehicles[grid.unique_id] = vehicle
					end
				end
			end
		end
		log ('on_configuration_changed end --- storage.transformer_data = '.. serpent.block(storage.transformer_data))
		log ('on_configuration_changed end --- storage.grid_vehicles = '.. serpent.block(storage.grid_vehicles))
	end
)

script.on_event(defines.events.on_equipment_inserted,
	function(event)
-- CHARACTER CODE
--		log ('on_equipment_inserted start --- ')
		local grid_id = event.grid.unique_id
		local player = isPlayerOwnerOfGrid(grid_id)
		
		if player ~= nil then
--log ('on_equipment_inserted --- event.equipment.quality.name = '.. serpent.block(event.equipment.quality.name))
			equipmentInserted(player, grid_id, event.equipment.name, "player", event.equipment.quality.name)
			return
		end

-- VEHICLE CODE
		if not isVehicleGridAllowed then
			return
		end
--log ('on_equipment_inserted vehicle grids allowed --- ')
		local valid_vehicle = storage.grid_vehicles[grid_id] -- and storage.grid_vehicles[grid_id].entity
--log ('on_equipment_inserted vehicle grid_id --- ' .. serpent.block(grid_id))
--log ('on_equipment_inserted grid_vehicles --- ' .. serpent.block(storage.grid_vehicles))
--log ('on_equipment_inserted vehicle --- ' .. serpent.block(valid_vehicle))
		if valid_vehicle and valid_vehicle.valid then
--log ('on_equipment_inserted valid vehicle --- ')
			equipmentInserted(valid_vehicle, grid_id, event.equipment.name, "entity", event.equipment.quality.name)
		end
	end
)

script.on_event(defines.events.on_equipment_removed,
	function(event)
--		log ('on_equipment_removed start --- ')
		local grid_id = event.grid.unique_id
		if storage.transformer_data[grid_id] == nil then
			return
		end

		if storage.transformer_data[grid_id].grid_owner_type == "player" or storage.transformer_data[grid_id].grid_owner_type == nil then
			equipmentRemoved(grid_id, event.equipment, event.count)
			return
		end
	
	-- VEHICLE CODE
		if not isVehicleGridAllowed then
			return
		end
		local valid_vehicle =  storage.grid_vehicles[grid_id] -- and storage.grid_vehicles[grid_id].entity
		
		if valid_vehicle and valid_vehicle.valid then
			if storage.transformer_data[grid_id].grid_owner_type == "entity" or storage.transformer_data[grid_id].grid_owner_type == nil then
				equipmentRemoved(grid_id, event.equipment, event.count)
				return
			end
		end
		
--		log ('on_removed end --- storage.transformer_data: ' .. serpent.block(storage.transformer_data))
	end
)

script.on_event(defines.events.on_player_armor_inventory_changed, 
	function(event)
--log ('on_player_armor_inventory_changed --- storage.transformer_data: ' .. serpent.block(storage.transformer_data))
		playerOrArmorChanged(event.player_index)
	end
)

script.on_event(defines.events.on_built_entity, 
	function(event)
--log ('on_built_entity --- ')
--log ('on_built_entity entity type --- '.. serpent.block(event.created_entity.type))
		new_vehicle_placed_event_wrapper(event)
	end
	-- {LuaPlayerBuiltEntityEventFilters = {"vehicle"}} -- incorrect way
	-- ,{{filter = "name", name = "vehicle"}}
, vehicle_event_filters
)

script.on_event(defines.events.on_robot_built_entity, 
	function(event)
--log ('on_robot_built_entity --- ')
		new_vehicle_placed_event_wrapper(event)
	end
	-- {LuaPlayerBuiltEntityEventFilters = {"vehicle"}} -- incorrect way
	-- ,{{filter = "name", name = "vehicle"}}
, vehicle_event_filters
)

script.on_event(defines.events.on_entity_cloned, 
	function(event)
--		log ('on_entity_cloned start --- ')
		new_vehicle_placed(event.destination)
		purgeOrphanedEntities()		
	end
	-- {LuaPlayerBuiltEntityEventFilters = {"vehicle"}} -- incorrect way
	-- ,{{filter = "name", name = "vehicle"}}
, vehicle_event_filters
)

script.on_event(defines.events.script_raised_built, 
	function(event)
--log ('script_raised_built --- ')
		new_vehicle_placed(event.entity)
	end
	-- {LuaPlayerBuiltEntityEventFilters = {"vehicle"}} -- incorrect way
	-- ,{{filter = "name", name = "vehicle"}}
, vehicle_event_filters
)

script.on_event(defines.events.script_raised_revive, 
	function(event)
--log ('script_raised_revive --- ')
		new_vehicle_placed(event.entity)
	end
	-- {LuaPlayerBuiltEntityEventFilters = {"vehicle"}} -- incorrect way
	-- ,{{filter = "name", name = "vehicle"}}
, vehicle_event_filters
)

script.on_event(defines.events.on_player_mined_entity, 
	function(event)
--		log ('on_player_mined_entity start --- ')
		entity_removed(event.entity)
	end
	-- {LuaPlayerBuiltEntityEventFilters = {"vehicle"}} -- incorrect way
	-- ,{{filter = "name", name = "vehicle"}}
, vehicle_event_filters
)

script.on_event(defines.events.on_robot_mined_entity, 
	function(event)
--		log ('on_robot_mined_entity start --- ')
		entity_removed(event.entity)
	end
	-- {LuaPlayerBuiltEntityEventFilters = {"vehicle"}} -- incorrect way
	-- ,{{filter = "name", name = "vehicle"}}
, vehicle_event_filters
)

script.on_event(defines.events.on_object_destroyed, 
	function(event)
		-- entity_removed(event.entity)
--	log ('on_entity_destroyed --- ')
	end
)

script.on_event(defines.events.on_entity_died, 
	function(event)
--		log ('on_entity_died start --- ')
		entity_removed(event.entity)
--		log ('on_entity_died end --- ')
	end

	-- {LuaPlayerBuiltEntityEventFilters = {"vehicle"}} -- incorrect way
	-- ,{{filter = "name", name = "vehicle"}}
, vehicle_event_filters
)

script.on_event(defines.events.script_raised_destroy, 
	function(event)
--		log ('script_raised_destroy start --- ')
		entity_removed(event.entity)
--		log ('script_raised_destroy end --- ')
	end
	-- {LuaPlayerBuiltEntityEventFilters = {"vehicle"}} -- incorrect way
	-- ,{{filter = "name", name = "vehicle"}}
, vehicle_event_filters
)

script.on_event(defines.events.on_player_changed_surface, 
	function(event)
		log ('on_player_changed_surface start --- ')
	-- Need to remove entities and re-add them on new surface
	-- Might want to only do this if character leaves surface, not player
		playerOrArmorChanged(event.player_index)
	end
)

script.on_event(defines.events.on_pre_player_died, 
	function(event)
--		log ('on_pre_player_died start --- ')
		playerOrArmorChanged(event.player_index)
--		log ('on_pre_player_died end --- ')
	end
)

script.on_event(defines.events.script_raised_teleported, 
	function(event)
--		log ('script_raised_teleported start --- ')
		entityTeleported(event.entity)
--		log ('script_raised_teleported end --- ')
	end
, vehicle_event_filters
)

script.on_event(defines.events.on_player_driving_changed_state, 
	function(event)
--		log ('on_player_driving_changed_state start --- ')
--		listCurrentAndAllPTEntities()
	end
)

script.on_event(defines.events.on_player_cheat_mode_enabled, 
	function(event)
--		log ('on_player_cheat_mode_enabled start --- ')
	end
)

script.on_event(defines.events.on_lua_shortcut,
	function(event)
--log ('on_player_driving_changed_state start --- ')
		if event.prototype_name == 'toggle-equipment-transformer-input' or event.prototype_name == 'toggle-equipment-transformer-output' then
			local player = game.players[event.player_index]
			if event.prototype_name == 'toggle-equipment-transformer-input' then
				player.set_shortcut_toggled('toggle-equipment-transformer-input', not player.is_shortcut_toggled('toggle-equipment-transformer-input'))
			elseif event.prototype_name == 'toggle-equipment-transformer-output' then
				player.set_shortcut_toggled('toggle-equipment-transformer-output', not player.is_shortcut_toggled('toggle-equipment-transformer-output'))
			end
		end
	end
)

script.on_event(defines.events.on_tick,
	function(event)
		
		tickdelay = settings.global["personal-transformer2-tick-delay"].value

		if event.tick % tickdelay ~= 0 then
			return
		end
		update_personal_transformer(tickdelay, storage.transformer_data)

		update_vehicle_transformer(tickdelay, storage.transformer_data)

	end)

function update_personal_transformer(tickdelay, transformer_data)
	local dt = tickdelay / 60
	for grid_id, transformer_data_values in pairs(storage.transformer_data) do
		if transformer_data_values.grid_owner_type == "player" then
			local max_draw = transformer_data_values.max_grid_draw
			local buffer = transformer_data_values.buffer
			local player = game.players[transformer_data_values.grid_owner_id]

			local max_draw_in = 0
			local max_draw_out = 0

			-- If a player has both toggles off, no need to check anything.
			if not player.is_shortcut_toggled('toggle-equipment-transformer-input') and not player.is_shortcut_toggled('toggle-equipment-transformer-output') then
				goto continue
			end

			if player.character ~= nil then
				-- teleport entities to player
				teleportEntitiesToPlayerPosition(player.position, transformer_data_values.grid_transformer_entities)
				local grid = player.character.grid
				if grid ~= nil then
				-- perform math
				
					for _, v in pairs(grid.equipment) do
--						if (v.prototype.type == "battery-equipment" or v.prototype.type == "generator-equipment") and v.prototype.energy_source ~= nil and v.prototype.energy_source.valid then
						if v.prototype.energy_source ~= nil and v.prototype.energy_source.valid then
							-- if energy source calculate max_draw_in/out from equipment with flow limit
							-- ie, what's the flow rate of the generators/batteries
							-- toggle off appropriate draw if toggle is off
							if player.is_shortcut_toggled('toggle-equipment-transformer-input') then
								local draw_in = math.max(math.min(v.prototype.energy_source.get_input_flow_limit() * tickdelay, v.prototype.energy_source.buffer_capacity - v.energy), 0)
								max_draw_in = max_draw_in + draw_in
							else
								max_draw_in = 0
							end
							if player.is_shortcut_toggled('toggle-equipment-transformer-output') then
								if v.prototype.type == "battery-equipment" or v.prototype.type == "generator-equipment" then
									local draw_out = math.min(v.prototype.energy_source.get_output_flow_limit() * tickdelay, v.energy)
									max_draw_out = max_draw_out + draw_out
--log ('update_personal_transformer --- equip: Name: ' .. serpent.block(v.prototype.name))
--log ('update_personal_transformer --- draw_out: ' .. serpent.block(draw_out))
								end
							else
								max_draw_out = 0
							end
						end
					end
--log ('update_personal_transformer ---   max_draw_out: ' .. serpent.block(max_draw_out))

					-- might wrap this in with the teleport to reduce amount of looping
					local avail_in = 0
					local request_out = 0
					for _, pt_entity in pairs(transformer_data_values.grid_transformer_entities) do
						if pt_entity.type == 'electric-energy-interface' then
							avail_in = avail_in + pt_entity.energy
						else
							request_out = request_out - pt_entity.energy
						end
					end
					request_out = request_out + buffer

					-- Power Calculations begin.
					local drain_in, drain_out, ratio_in, ratio_out = nil
					if avail_in == 0 then
						drain_in = 0
					else
						drain_in = math.min(math.max(max_draw_in / avail_in, 0), 1)
					end
					if request_out == 0 then
						drain_out = 0
					else
						drain_out = math.min(math.max(max_draw_out / request_out, 0), 1)
					end
					avail_in = math.min(avail_in, max_draw * dt)
					request_out = math.min(request_out, max_draw * dt)
					if max_draw_in == 0 then
						ratio_in = 0
					else
						ratio_in = math.min(math.max(avail_in / max_draw_in, 0), 1)
					end
					if max_draw_out == 0 then
						ratio_out = 0
					else
						ratio_out = math.min(math.max(request_out / max_draw_out, 0), 1)
					end
					-----
					for _, gt_entity in pairs(transformer_data_values.grid_transformer_entities) do
						if gt_entity.type == 'electric-energy-interface' then
							gt_entity.energy = gt_entity.energy * (1 - drain_in)
						else
							local entity_buffer = gt_entity.electric_buffer_size
							gt_entity.energy = entity_buffer - ((entity_buffer - gt_entity.energy) * (1 - drain_out))
						end
					end
					----
					for _, v in pairs(grid.equipment) do
						if v.name ~= equip_name and v.prototype.energy_source ~= nil and v.prototype.energy_source.valid then
							local draw_in = math.max(math.min(v.prototype.energy_source.get_input_flow_limit() * tickdelay, v.prototype.energy_source.buffer_capacity - v.energy), 0)
							local draw_out = math.min(v.prototype.energy_source.get_output_flow_limit() * tickdelay, v.energy)
							local dE = draw_in * ratio_in - draw_out * ratio_out
							v.energy = v.energy + dE
						end
					end
				end
			end
		end
		::continue::
	end
end

function update_vehicle_transformer(tickdelay, transformer_data)
	if not isVehicleGridAllowed then
		return
	end
	local dt = tickdelay / 60
	for grid_id, transformer_data_values in pairs(storage.transformer_data) do
		if transformer_data_values.grid_owner_type == "entity" then
			local max_draw = transformer_data_values.max_grid_draw
			local buffer = transformer_data_values.buffer
			local vehicle = storage.grid_vehicles[transformer_data_values.grid_owner_id]

			local max_draw_in = 0
			local max_draw_out = 0

			if vehicle and vehicle.valid then
				-- teleport entities to vehicle
--log ('update_vehicle_transformer --- storage.grid_vehicles = '.. serpent.block(storage.grid_vehicles))
--log ('update_vehicle_transformer --- storage.transformer_data: ' .. serpent.block(storage.transformer_data))
--log ('update_vehicle_transformer --- loop')
--log ('update_vehicle_transformer --- grid_id = '.. serpent.block(grid_id))
--log ('update_vehicle_transformer --- vehicle.position = '.. serpent.block(vehicle.position))
--log ('update_vehicle_transformer --- transformer_data_values.grid_transformer_entities = '.. serpent.block(transformer_data_values.grid_transformer_entities))
				teleportEntitiesToPlayerPosition(vehicle.position, transformer_data_values.grid_transformer_entities)
				local grid = vehicle.grid
				if grid ~= nil then
				-- perform math
					for _, v in pairs(grid.equipment) do
						if v.prototype.energy_source ~= nil and v.prototype.energy_source.valid then
							-- if energy source calculate max_draw_in/out from equipment with flow limit
							-- ie, what's the flow rate of the generators/batteries
							-- toggle off appropriate draw if toggle is off
							local draw_in = math.min(v.prototype.energy_source.get_input_flow_limit() * tickdelay, v.prototype.energy_source.buffer_capacity - v.energy)
							max_draw_in = max_draw_in + draw_in
							local draw_out = math.min(v.prototype.energy_source.get_output_flow_limit() * tickdelay, v.energy)
							max_draw_out = max_draw_out + draw_out
						end
					end

					-- might wrap this in with the teleport to reduce amount of looping
					local avail_in = 0
					local request_out = 0
					for _, pt_entity in pairs(transformer_data_values.grid_transformer_entities) do
						if pt_entity.type == 'electric-energy-interface' then
							avail_in = avail_in + pt_entity.energy
						else
							request_out = request_out - pt_entity.energy
						end
					end
					request_out = request_out + buffer

					-- Power Calculations begin.
					local drain_in, drain_out, ratio_in, ratio_out = nil
					if avail_in == 0 then
						drain_in = 0
					else
						drain_in = math.min(math.max(max_draw_in / avail_in, 0), 1)
					end
					if request_out == 0 then
						drain_out = 0
					else
						drain_out = math.min(math.max(max_draw_out / request_out, 0), 1)
					end
					avail_in = math.min(avail_in, max_draw * dt)
					request_out = math.min(request_out, max_draw * dt)
					if max_draw_in == 0 then
						ratio_in = 0
					else
						ratio_in = math.min(math.max(avail_in / max_draw_in, 0), 1)
					end
					if max_draw_out == 0 then
						ratio_out = 0
					else
						ratio_out = math.min(math.max(request_out / max_draw_out, 0), 1)
					end
					-----
					for _, gt_entity in pairs(transformer_data_values.grid_transformer_entities) do
						if gt_entity.type == 'electric-energy-interface' then
							gt_entity.energy = gt_entity.energy * (1 - drain_in)
						else
							local entity_buffer = gt_entity.electric_buffer_size
							gt_entity.energy = entity_buffer - ((entity_buffer - gt_entity.energy) * (1 - drain_out))
						end
					end
					----
					for _, v in pairs(grid.equipment) do
						if v.name ~= equip_name and v.prototype.energy_source ~= nil and v.prototype.energy_source.valid then
							local draw_in = math.min(v.prototype.energy_source.get_input_flow_limit() * tickdelay, v.prototype.energy_source.buffer_capacity - v.energy)
							local draw_out = math.min(v.prototype.energy_source.get_output_flow_limit() * tickdelay, v.energy)
							local dE = draw_in * ratio_in - draw_out * ratio_out
							v.energy = v.energy + dE
						end
					end
				end
			end
		end
	end
end

function is_personal_transformer_name_match(name)
	return name == personal_transformer_mk1_name or name == personal_transformer_mk2_name or name == personal_transformer_mk3_name
end

function insert_entity(equipment_name, grid_owner, grid_id, quality_name)
	if not is_quality_enabled then
		quality_name = "normal"
	end
	if is_personal_transformer_name_match(equipment_name) then
		local entity_input_name
		local entity_output_name
		if personal_transformer_mk1_name == equipment_name then
			entity_input_name = "personal-transformer-input-entity"
			entity_output_name = "personal-transformer-output-entity"
		elseif personal_transformer_mk2_name == equipment_name then
			entity_input_name = "personal-transformer-mk2-input-entity"
			entity_output_name = "personal-transformer-mk2-output-entity"
		elseif personal_transformer_mk3_name == equipment_name then
			entity_input_name = "personal-transformer-mk3-input-entity"
			entity_output_name = "personal-transformer-mk3-output-entity"
		end
		local input_entity = grid_owner.surface.create_entity
			{
				name = entity_input_name,
				position = grid_owner.position,
				force = grid_owner.force,
				quality = quality_name
			}
		table.insert(storage.transformer_data[grid_id].grid_transformer_entities, input_entity)
		local output_entity = grid_owner.surface.create_entity
			{
				name = entity_output_name,
				position = grid_owner.position,
				force = grid_owner.force,
				quality = quality_name
			}
		table.insert(storage.transformer_data[grid_id].grid_transformer_entities, output_entity)
--log ('insert_entity end --- ')
--log ('insert_entity --- input_entity.name: ' .. serpent.block(input_entity.name))
--log ('insert_entity --- input_entity.unit_number: ' .. serpent.block(input_entity.unit_number))
--log ('insert_entity --- input_entity.position: ' .. serpent.block(input_entity.position))
--log ('insert_entity --- output_entity.name: ' .. serpent.block(output_entity.name))
--log ('insert_entity --- output_entity.unit_number: ' .. serpent.block(output_entity.unit_number))
--log ('insert_entity --- output_entity.position: ' .. serpent.block(output_entity.position))
--listCurrentAndAllPTEntities()
	end
end

function remove_entity(equipment_name, grid_id)
	if is_personal_transformer_name_match(equipment_name) then

--listCurrentAndAllPTEntities()
	
		local entity_input_name
		local entity_output_name
		if personal_transformer_mk1_name == equipment_name then
			entity_input_name = "personal-transformer-input-entity"
			entity_output_name = "personal-transformer-output-entity"
		elseif personal_transformer_mk2_name == equipment_name then
			entity_input_name = "personal-transformer-mk2-input-entity"
			entity_output_name = "personal-transformer-mk2-output-entity"
		elseif personal_transformer_mk3_name == equipment_name then
			entity_input_name = "personal-transformer-mk3-input-entity"
			entity_output_name = "personal-transformer-mk3-output-entity"
		end

		local input_check = false
		local output_check = false
--log ('remove_entity --- START grid_id: ' .. serpent.block(grid_id))
--log ('remove_entity --- storage.transformer_data: ' .. serpent.block(storage.transformer_data))
--log ('remove_entity --- storage.transformer_data_entities1: ' .. serpent.block(storage.transformer_data[grid_id].grid_transformer_entities[1].name))
--log ('remove_entity --- storage.transformer_data_entities2: ' .. serpent.block(storage.transformer_data[grid_id].grid_transformer_entities[2].name))

		for index, entity in ipairs (storage.transformer_data[grid_id].grid_transformer_entities) do
--		for index = 1, count do
--			local entity = storage.transformer_data[grid_id].grid_transformer_entities[index]
--log ('remove_entity --- index: ' .. serpent.block(index))
--log ('remove_entity --- entity: ' .. serpent.block(entity))
--log ('remove_entity --- entity.name: ' .. serpent.block(entity.name))
--log ('remove_entity --- entity.unit_number: ' .. serpent.block(entity.unit_number))
			if (entity.name == entity_input_name) then
				local entity = table.remove(storage.transformer_data[grid_id].grid_transformer_entities, index)
--				log ('remove_entity --- entity: ' .. serpent.block(entity))
				entity.destroy()
				entity = nil
				input_check = true
				break
			end
		end

		for index, entity in ipairs (storage.transformer_data[grid_id].grid_transformer_entities) do
--			local entity = storage.transformer_data[grid_id].grid_transformer_entities[index]
--log ('remove_entity --- index: ' .. serpent.block(index))
--log ('remove_entity --- entity: ' .. serpent.block(entity))
--log ('remove_entity --- entity.name: ' .. serpent.block(entity.name))
--log ('remove_entity --- entity.name: ' .. serpent.block(entity.name))
--log ('remove_entity --- entity.unit_number: ' .. serpent.block(entity.unit_number))
			if (entity.name == entity_output_name) then
				local entity = table.remove(storage.transformer_data[grid_id].grid_transformer_entities, index)
--				log ('remove_entity --- entity: ' .. serpent.block(entity))
				entity.destroy()
				entity = nil
				output_check = true
				break
			end
		end
--		log ('remove_entity --- storage.transformer_data post removal: ' .. serpent.block(storage.transformer_data))
	end
--listCurrentAndAllPTEntities()

--log ('remove_entity --- grid_id: ' .. serpent.block(grid_id))
--log ('remove_entity --- END storage.transformer_data: ' .. serpent.block(storage.transformer_data))
end

function new_vehicle_placed_event_wrapper(event)
--log ('new_vehicle_placed_event_wrapper start --- event = '.. serpent.block(event))
	new_vehicle_placed(event.entity)
end

function new_vehicle_placed(entity)
--log ('new_vehicle_placed --- ')
	if not isVehicleGridAllowed then
		return
	end
--log ('new_vehicle_placed vehicles allowed --- ')
	-- add placed vehicle to vehicle list
	-- add draw total to draw list
--	log ('new_vehicle_placed start --- storage.grid_vehicles = '.. serpent.block(storage.grid_vehicles))
--	log ('new_vehicle_placed start --- created_entity = '.. serpent.block(entity))
--	log ('new_vehicle_placed start --- created_entity.type = '.. serpent.block(entity.type))
	-- local vehicle = event.created_entity
	local vehicle = entity
	local grid = vehicle.grid
--	log ('new_vehicle_placed --- vehicle = '.. serpent.block(vehicle))
--	log ('new_vehicle_placed --- grid = '.. serpent.block(grid))
	if grid and grid.valid then
		local grid_id = grid.unique_id
--log ('new_vehicle_placed --- grid_id = '.. serpent.block(grid_id))
		storage.grid_vehicles[grid_id] = vehicle
		local mk1_count = grid.count(personal_transformer_mk1_name)
		local mk2_count = grid.count(personal_transformer_mk2_name)
		local mk3_count = grid.count(personal_transformer_mk3_name)
		if mk1_count > 0 then
			for i = 1, mk1_count do
				equipmentInserted(vehicle, grid_id, personal_transformer_mk1_name, "entity", "legendary")
			end
		end
		if mk2_count > 0 then
			for i = 1, mk2_count do
				equipmentInserted(vehicle, grid_id, personal_transformer_mk2_name, "entity", "legendary")
			end
		end
		if mk3_count > 0 then
			for i = 1, mk3_count do
				equipmentInserted(vehicle, grid_id, personal_transformer_mk3_name, "entity", "legendary")
			end
		end
	end
--	log ('new_vehicle_placed end --- storage.transformer_data: ' .. serpent.block(storage.transformer_data))
--	log ('new_vehicle_placed end --- storage.grid_vehicles: ' .. serpent.block(storage.grid_vehicles))
end

function entity_removed(entity)
--	log ('entity_removed start --- storage.transformer_data: ' .. serpent.block(storage.transformer_data))
--	log ('entity_removed start --- storage.grid_vehicles: ' .. serpent.block(storage.grid_vehicles))
--	log ('entity_removed start --- entity.unit_number: ' .. serpent.block(entity.unit_number))
--	log ('entity_removed start --- entity.type: ' .. serpent.block(entity.type))
	
--	log ('entity_removed start --- vehicle_grid:4200: unit_number ' .. serpent.block(storage.grid_vehicles[4200].unit_number))
	if not isVehicleGridAllowed then
		return
	end
	local grid_id
	for index, vehicle_entity in pairs (storage.grid_vehicles) do 
		-- See: https://lua-api.factorio.com/latest/classes/LuaEntity.html#unit_number
--log ('entity_removed --- index ' .. serpent.block(index))
--		if entity.unit_number == vehicle_entity.unit_number then
		if entity == vehicle_entity then
--			log ('entity_removed --- entities match')
			grid_id = index
			storage.grid_vehicles[grid_id] = nil
			break
		end
	end
	
	if not grid_id then
--		log ('entity_removed --- grid_id is null')
--		log ('entity_removed end --- storage.transformer_data: ' .. serpent.block(storage.transformer_data))
--		log ('entity_removed end --- storage.grid_vehicles: ' .. serpent.block(storage.grid_vehicles))
		return
	end

--log ('entity_removed --- grid_id: ' .. serpent.block(grid_id))
	local transformer_data_values = storage.transformer_data[grid_id]
--log ('entity_removed --- storage.transformer_data[grid_id]: ' .. serpent.block(transformer_data_values))

	if transformer_data_values and transformer_data_values.grid_owner_type == "entity" and transformer_data_values.grid_owner_id == grid_id then
		for count_key, count_value in pairs(transformer_data_values.transformer_count) do
			if count_value > 0 then
				equipmentRemoved(grid_id, count_key, count_value)
			end
		end
	end
--	log ('entity_removed end --- storage.transformer_data: ' .. serpent.block(storage.transformer_data))
--	log ('entity_removed end --- storage.grid_vehicles: ' .. serpent.block(storage.grid_vehicles))
end

function isPlayerOwnerOfGrid(grid_id)
	for _, p in pairs(game.players) do
		if p.character ~= nil and p.character.grid ~= nil then
			local grid = p.character.grid
			if grid.unique_id == grid_id then
				return p
			end
		end
	end
	return nil
end

function teleportEntitiesToPlayerPosition(player_pos, grid_transformer_entities)
-- NOTE: teleport across surfaces only works for players, cars, and spidertrons
	for _, pt_entity in pairs(grid_transformer_entities) do
		if pt_entity.position ~= player_pos then
			pt_entity.teleport(player_pos)
		end
	end
end

function equipmentInserted(player, grid_id, equipment_name, grid_owner_type, quality_name)
--	local quality = equipment.equipment_name
--	log ('equipmentInserted before --- storage.transformer_data: ' .. serpent.block(storage.transformer_data))
	if is_personal_transformer_name_match(equipment_name) then
		if not storage.transformer_data[grid_id] then 
			storage.transformer_data[grid_id] = {}
			storage.transformer_data[grid_id].grid_transformer_entities = {}
		end
		insert_entity(equipment_name, player, grid_id, quality_name)

		if not storage.transformer_data[grid_id].transformer_count then 
			storage.transformer_data[grid_id].transformer_count = {}
			storage.transformer_data[grid_id].transformer_count[personal_transformer_mk1_name] = 0
			storage.transformer_data[grid_id].transformer_count[personal_transformer_mk2_name] = 0
			storage.transformer_data[grid_id].transformer_count[personal_transformer_mk3_name] = 0
		end
		storage.transformer_data[grid_id].transformer_count[equipment_name] = storage.transformer_data[grid_id].transformer_count[equipment_name] + 1

		if grid_owner_type == "player" then
			storage.transformer_data[grid_id].grid_owner_id = player.index
			toggleShortcutAvailable(player, true)
		elseif grid_owner_type == "entity" then
			storage.transformer_data[grid_id].grid_owner_id = grid_id
		end
		storage.transformer_data[grid_id].grid_owner_type = grid_owner_type

		if storage.transformer_data[grid_id].max_grid_draw == nil then
			storage.transformer_data[grid_id].max_grid_draw = 0
		end
		storage.transformer_data[grid_id].max_grid_draw = storage.transformer_data[grid_id].max_grid_draw + transformer_draw[equipment_name]
		storage.transformer_data[grid_id].buffer = storage.transformer_data[grid_id].max_grid_draw / 10
--	log ('equipmentInserted after --- storage.transformer_data after: ' .. serpent.block(storage.transformer_data))
	end
end

function equipmentRemoved(grid_id, equipment_name, count)
	if is_personal_transformer_name_match(equipment_name) then
--		log ('on_equipment_removed before --- storage.transformer_data: ' .. serpent.block(storage.transformer_data))
--		log ('on_equipment_removed --- grid_id: ' .. serpent.block(grid_id))
--		log ('on_equipment_removed --- count: ' .. serpent.block(count))
--		log ('on_equipment_removed --- equipment_name: ' .. serpent.block(equipment_name))
		for i = 1, count do 
			remove_entity(equipment_name, grid_id)
		end
--		log ('on_equipment_removed --- storage.transformer_data.transformer_count[array]: ' .. serpent.block(storage.transformer_data[grid_id].transformer_count[personal_transformer_mk3_name]))
		storage.transformer_data[grid_id].transformer_count[equipment_name] = storage.transformer_data[grid_id].transformer_count[equipment_name] - count
--		log ('on_equipment_removed post remove entity --- storage.transformer_data after: ' .. serpent.block(storage.transformer_data))
		storage.transformer_data[grid_id].max_grid_draw = storage.transformer_data[grid_id].max_grid_draw - (transformer_draw[equipment_name] * count)
		storage.transformer_data[grid_id].buffer = storage.transformer_data[grid_id].max_grid_draw / 10

		local total_count = storage.transformer_data[grid_id].transformer_count[personal_transformer_mk1_name] + storage.transformer_data[grid_id].transformer_count[personal_transformer_mk2_name] + storage.transformer_data[grid_id].transformer_count[personal_transformer_mk3_name]

		if total_count == 0 then
			if storage.transformer_data[grid_id].grid_owner_type == "player" then
				toggleShortcutAvailable(game.players[storage.transformer_data[grid_id].grid_owner_id], false)
			end
		
--			log ('If no more transformers --- Clear out object')
			storage.transformer_data[grid_id].transformer_count = nil
			storage.transformer_data[grid_id].grid_owner_id = nil
			storage.transformer_data[grid_id].grid_owner_type = nil
			storage.transformer_data[grid_id].max_grid_draw = nil
			storage.transformer_data[grid_id].buffer = nil
			storage.transformer_data[grid_id] = nil
		end
	end
--	log ('on_equipment_removed after --- grid_id: ' .. serpent.block(grid_id))
--	log ('on_equipment_removed after --- storage.transformer_data: ' .. serpent.block(storage.transformer_data))
end

function playerOrArmorChanged(player_index)
--log ('playerOrArmorChanged --- START --- storage.transformer_data: ' .. serpent.block(storage.transformer_data))
	local player = game.players[player_index]
--log ('playerOrArmorChanged --- player: ' .. serpent.block(player))
--log ('playerOrArmorChanged --- player.controller: ' .. serpent.block(player.controller_type))
	if player.character ~= nil then

		-- NOTE: may need to change this for SE when it's ready for 2.0
		if player.controller_type == defines.controllers.remote then
			return
		end

		toggleShortcutAvailable(player, true)
		-- Search table for previously equipped armor and remove it from the table
		for grid_id, transformer_data_values in pairs(storage.transformer_data) do
			if transformer_data_values.grid_owner_type == "player" and transformer_data_values.grid_owner_id == player_index then
				for count_key, count_value in pairs(transformer_data_values.transformer_count) do
					if count_value > 0 then
						equipmentRemoved(grid_id, count_key, count_value)
					end
				end
			end
		end
--log ('playerOrArmorChanged --- POST REMOVAL --- storage.transformer_data: ' .. serpent.block(storage.transformer_data))

		local grid = player.character.grid
		if grid ~= nil then
			local current_grid_id = player.character.grid.unique_id
			
			-- Get Number of PTs in new armor and add them all to the table
			-- prolly need to null check character and grid
			local mk1_count = grid.count(personal_transformer_mk1_name)
			local mk2_count = grid.count(personal_transformer_mk2_name)
			local mk3_count = grid.count(personal_transformer_mk3_name)

			for i = 1, mk1_count do
				equipmentInserted(player, current_grid_id, personal_transformer_mk1_name, "player", "legendary")
			end
			for i = 1, mk2_count do
				equipmentInserted(player, current_grid_id, personal_transformer_mk2_name, "player", "legendary")
			end
			for i = 1, mk3_count do
				equipmentInserted(player, current_grid_id, personal_transformer_mk3_name, "player", "legendary")
			end
			
			if mk1_count + mk2_count + mk3_count > 0 then
				toggleShortcutAvailable(player, true)
			else 
				toggleShortcutAvailable(player, false)
			end
		else
			toggleShortcutAvailable(player, false)
		end
	else
--		toggleShortcutAvailable(player, false)
	end

--log ('playerOrArmorChanged --- END --- storage.transformer_data: ' .. serpent.block(storage.transformer_data))
end

function entityTeleported(entity)
--log ('entityTeleported --- PRE REMOVAL --- storage.transformer_data: ' .. serpent.block(storage.transformer_data))
	entity_removed(entity)
--log ('entityTeleported --- POST REMOVAL --- storage.transformer_data: ' .. serpent.block(storage.transformer_data))
	new_vehicle_placed(entity)
--log ('entityTeleported --- END --- storage.transformer_data: ' .. serpent.block(storage.transformer_data))
end

function purgeOrphanedEntities()
--	log ('purgeOrphanedEntities --- all entities: ')
	if not isVehicleGridAllowed then
		return
	end

	local current_entities = {}
	for gd_id, transformer_data_values in pairs(storage.transformer_data) do
		for index, et in ipairs (transformer_data_values.grid_transformer_entities) do
--			log ('purgeOrphanedEntities --- entity.name: ' .. serpent.block(et.name))
--			log ('purgeOrphanedEntities --- entity.unit_number: ' .. serpent.block(et.unit_number))
			table.insert(current_entities, et)
		end
	end

	for _, surface in pairs(game.surfaces) do 
		for _, ent in pairs (surface.find_entities_filtered({name={"personal-transformer-input-entity", "personal-transformer-output-entity", "personal-transformer-mk2-input-entity", "personal-transformer-mk2-output-entity", "personal-transformer-mk3-input-entity", "personal-transformer-mk3-output-entity"}})) do 
			if not tableContains(current_entities, ent) then
				ent.destroy()
				ent = nil
			end
		end 
	end
--	log ('purgeOrphanedEntities --- AFTER: ')
--	listCurrentAndAllPTEntities()
end

function toggleShortcutAvailable(player, is_available)
	player.set_shortcut_available('toggle-equipment-transformer-input', is_available)
	player.set_shortcut_available('toggle-equipment-transformer-output', is_available)
end


-------- Utility Methods ---------
function tableContains(testTable, value)
	for i = 1, #testTable do
		if (testTable[i] == value) then
			return true
		end
	end
	return false
end

function listCurrentAndAllPTEntities()
	log ('listCurrentAndAllPTEntities --- all entities: ')
	for _, surface in pairs(game.surfaces) do 
		for _, ent in pairs (surface.find_entities_filtered({name={"personal-transformer-input-entity", "personal-transformer-output-entity", "personal-transformer-mk2-input-entity", "personal-transformer-mk2-output-entity", "personal-transformer-mk3-input-entity", "personal-transformer-mk3-output-entity"}})) do 
			log ('listCurrentAndAllPTEntities --- entity.name: ' .. serpent.block(ent.name))
			log ('listCurrentAndAllPTEntities --- entity.unit_number: ' .. serpent.block(ent.unit_number))
--			log ('listCurrentAndAllPTEntities --- entity.position: ' .. serpent.block(ent.position))
		end 
	end
	log ('listCurrentAndAllPTEntities --- currently listed entities: ')
	for gd_id, transformer_data_values in pairs(storage.transformer_data) do
		for index, et in ipairs (transformer_data_values.grid_transformer_entities) do
			log ('listCurrentAndAllPTEntities --- entity.name: ' .. serpent.block(et.name))
			log ('listCurrentAndAllPTEntities --- entity.unit_number: ' .. serpent.block(et.unit_number))
--			log ('listCurrentAndAllPTEntities --- entity.position: ' .. serpent.block(et.position))
		end
	end
	log ('listCurrentAndAllPTEntities --- grid_id: ' .. serpent.block(grid_id))
	log ('listCurrentAndAllPTEntities --- END storage.transformer_data: ' .. serpent.block(storage.transformer_data))
end

