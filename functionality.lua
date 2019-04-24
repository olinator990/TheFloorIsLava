--functionality.lua


local Func = {}

local function area_within_radius(area, center)
   local r = Config.beginning_path_radius
   return area.left_top.x-center.x < r and area.right_bottom.x-center.x > -r and
      area.left_top.y-center.y < r and area.right_bottom.y-center.y > -r
end


local function make_brick_circle(area, center, surface)
   local changed_tiles = {}
   
   -- fill changed_tiles with tiles that are within a radius of the 0,0 position
   -- and designate them to be 'stone-path's
   local r = Config.beginning_path_radius
   for x = area.left_top.x - center.x, area.right_bottom.x - center.x do
      for y = area.left_top.y - center.y, area.right_bottom.y - center.y do
	 if math.sqrt(x*x + y*y) < Config.beginning_path_radius then
	    table.insert(changed_tiles, {name="stone-path", position={x+center.x, y+center.y}})
	 end
      end
   end
   
   -- apply the stone path tiles
   if #changed_tiles > 0 then
      surface.set_tiles(changed_tiles)
   end
end



function let_player_start(plr_ind)
    local plr = game.players[plr_ind]
   
   -- give the player some bricks initially
    plr.insert({name="stone-brick", count=10})

    -- make sure the player isn't set on fire uppon world creation
    if not plr.surface.get_tile(plr.position).valid then return nil end
    undertile = plr.surface.get_tile(plr.position).name
    if not(undertile == "stone-path" or string.find("concrete", undertile)) then
       plr.surface.set_tiles{{name="stone-path", position=plr.position}}
    end

    --
    Temporary.last_position[plr_ind] = {x=plr.position.x, y=plr.position.y}

    local r = Config.beginning_path_radius
    Func.make_brick_circle({left_top={x=plr.position.x-r, y=plr.position.y-r},
			    right_bottom={x=plr.position.x+r, y=plr.position.y+r}},
			   plr.position, plr.surface)
    
end



Func.area_within_radius = area_within_radius
Func.make_brick_circle = make_brick_circle
Func.let_player_start = let_player_start

return Func