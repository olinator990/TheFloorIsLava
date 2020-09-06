--control.lua

require "config"
require "globals"
local Func = require "functionality"

script.on_nth_tick(10,
 function (e)
	for index,player in pairs(game.connected_players) do  --loop through all online players on the server

	-- check if player stands on non-manmade tiling
	if not player.surface.get_tile(player.position).valid then return nil end
	undertile = player.surface.get_tile(player.position).name
	if player.character and not(undertile == "stone-path" or string.find("concrete", undertile) or string.find("road", undertile)) then
		-- "road" covers mods such as Klonan's transport drones

		local env_damage = Config.environment_damage
		if player.vehicle then
			env_damage = Config.environment_damage * Config.vehicle_damage_modifier
		end

		-- do damage
		player.character.damage(env_damage, player.force, "fire")

		-- if last position is nil, set it to zeros to avoid errors
		if not Temporary.last_position then
			Temporary.last_position[index] = {x=0, y=0}
		end

		-- if player is standing still, light a fire underneath player
		if Temporary.last_position[index] and
			player.position.x == Temporary.last_position[index].x and
			player.position.y == Temporary.last_position[index].y then
			player.surface.create_entity{name="fire-flame", position=player.position, force="neutral"}
		end

		-- keep track of position every 3rd second to see if player stands still
		Temporary.last_position[index] = {x=player.position.x, y=player.position.y}
	end
	end
 end
)




script.on_event
(defines.events.on_player_changed_surface,
 function(event)
    Func.let_player_start(event.player_index)
 end
)

script.on_event
(defines.events.on_cutscene_cancelled,
 function(event)
    Func.let_player_start(event.player_index)
 end
)



