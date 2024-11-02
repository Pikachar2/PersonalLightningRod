--local my_types = {"car", "spider-vehicle"}
local my_types = {"car", "spider-vehicle", "locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon"}
local grid
storage.grid_vehicles = storage.grid_vehicles or {}
-- storage.grid_draw = storage.grid_draw or {}
-- storage.grid_lightning_rod_entities = storage.grid_lightning_rod_entities or {}
-- storage.grid_energy_draw = storage.grid_energy_draw or {}

-- storage.lightning_rod_data = storage.lightning_rod_data or {}

log ('migrations starting...')
for s, surface in pairs(game.surfaces) do
	for v, vehicle in pairs(surface.find_entities_filtered{type = my_types}) do
		if vehicle and vehicle.valid then
			log ('on_configuration_changed valid vehicle --- vehicle.unit_number: ' .. serpent.block(vehicle.unit_number))
			grid = vehicle.grid
			if grid and grid.valid then
				storage.grid_vehicles[grid.unique_id] = vehicle
			end
		end
	end
end
log ('storage.grid_vehicles = '.. serpent.block(storage.grid_vehicles))
