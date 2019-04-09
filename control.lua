--control.lua

require "config"

script.on_event
({defines.events.on_tick},
 function (e)
    if e.tick % 10 == 0 then --common trick to reduce how often this runs, we don't want it running every tick, just every 20 ticks, so three times per second
       for index,player in pairs(game.connected_players) do  --loop through all online players on the server

	  -- check if player stands on non-manamade tiling
	  undertile = player.surface.get_tile(player.position).name
	  if player.character and not(undertile == "stone-path" or string.find("concrete", undertile)) then
	     -- do damage
	     player.character.damage(5, player.force, "fire")


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
 end
)



function area_contains_starting_radius(area)
   local r = Config.beginning_path_radius
   return area.left_top.x < r and area.right_bottom.x > -r and
      area.left_top.y < r and area.right_bottom.y > -r
end


script.on_event
({defines.events.on_chunk_generated},
 function (event)

    -- only want to be changing tiles on the chunks near the starting point
    if area_contains_starting_radius(event.area) then
       log("calling" .. tostring(event.area.left_top.x) .."," .. tostring(event.area.left_top.y) .."  " .. tostring(event.area.right_bottom.x) .."," .. tostring(event.area.right_bottom.y))
       
       local changed_tiles = {}
       
       -- fill changed_tiles with tiles that are within a radius of the 0,0 position
       -- and designate them to be 'stone-path's
       local r = Config.beginning_path_radius
       for x = event.area.left_top.x, event.area.right_bottom.x do
	  for y = event.area.left_top.y, event.area.right_bottom.y do
	     if math.sqrt(x*x + y*y) < Config.beginning_path_radius then
		table.insert(changed_tiles, {name="stone-path", position={x, y}})
	     end
	  end
       end
       
       -- apply the stone path tiles
       if #changed_tiles > 0 then
	  event.surface.set_tiles(changed_tiles)
       end
    end
 end
)


script.on_event
(defines.events.on_player_created,
 function(event)
    local plr = game.players[event.player_index]

    -- give the player some bricks initially
    plr.insert({name="stone-brick", count=10})

    -- make sure the player isn't set on fire uppon world creation
    undertile = plr.surface.get_tile(plr.position).name
    if not(undertile == "stone-path" or string.find("concrete", undertile)) then
       plr.surface.set_tiles{{name="stone-path", position=plr.position}}
    end

    --
    Temporary.last_position[event.player_index] = {x=plr.position.x, y=plr.position.y}
 end
)