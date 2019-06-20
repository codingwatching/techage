--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA3 Coal Power Station Firebox

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

local firebox = techage.firebox

local CYCLE_TIME = 2

local function firehole(pos, on)
	local param2 = minetest.get_node(pos).param2
	local pos2 = techage.get_pos(pos, 'F')
	if on == true then
		minetest.swap_node(pos2, {name="techage:coalfirehole_on", param2 = param2})
	elseif on == false then
		minetest.swap_node(pos2, {name="techage:coalfirehole", param2 = param2})
	else
		minetest.swap_node(pos2, {name="air"})
	end
end	

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	print("firebox burn_cycles = "..(mem.burn_cycles or 0))
	if mem.running then
		-- trigger generator and provide power ratio 0..1
		local ratio = techage.transfer(
			{x=pos.x, y=pos.y+2, z=pos.z}, 
			nil,  -- outdir
			"trigger",  -- topic
			(mem.power_level or 4)/4.0,  -- payload
			nil,  -- network
			{"techage:coalboiler_top"}  -- nodenames
		)
		mem.burn_cycles = (mem.burn_cycles or 0) - math.max((ratio or 0.02), 0.02)
		if mem.burn_cycles <= 0 then
			local taken = firebox.get_fuel(pos) 
			if taken then
				mem.burn_cycles = firebox.Burntime[taken:get_name()] / CYCLE_TIME
				mem.burn_cycles_total = mem.burn_cycles
			else
				mem.running = false
				firehole(pos, false)
				M(pos):set_string("formspec", firebox.formspec(mem))
				return false
			end
		end
		return true
	end
end

local function start_firebox(pos, mem)
	if not mem.running then
		mem.running = true
		node_timer(pos, 0)
		firehole(pos, true)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end
end

minetest.register_node("techage:coalfirebox", {
	description = I("TA3 Coal Power Station Firebox"),
	inventory_image = "techage_coal_boiler_inv.png",
	tiles = {"techage_coal_boiler_mesh_top.png"},
	drawtype = "mesh",
	mesh = "techage_boiler_large.obj",
	selection_box = {
		type = "fixed",
		fixed = {-13/32, -16/32, -13/32, 13/32, 16/32, 13/32},
	},

	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),

	on_timer = node_timer,
	can_dig = firebox.can_dig,
	allow_metadata_inventory_put = firebox.allow_metadata_inventory,
	allow_metadata_inventory_take = firebox.allow_metadata_inventory,
	on_receive_fields = firebox.on_receive_fields,
	on_rightclick = firebox.on_rightclick,
	
	on_construct = function(pos)
		local mem = tubelib2.init_mem(pos)
		mem.running = false
		mem.burn_cycles = 0
		mem.power_level = 4
		local meta = M(pos)
		meta:set_string("formspec", firebox.formspec(mem))
		local inv = meta:get_inventory()
		inv:set_size('fuel', 1)
		firehole(pos, false)
	end,

	on_destruct = function(pos)
		firehole(pos, nil)
	end,

	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local mem = tubelib2.get_mem(pos)
		start_firebox(pos, mem)
		M(pos):set_string("formspec", firebox.formspec(mem))
	end,
})

minetest.register_node("techage:coalfirehole", {
	description = I("TA3 Coal Power Station Firebox"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_coal_boiler.png",
		"techage_coal_boiler.png",
		"techage_coal_boiler.png",
		"techage_coal_boiler.png",
		"techage_coal_boiler.png",
		"techage_coal_boiler.png^techage_appl_firehole.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-6/16, -6/16,  6/16,  6/16, 6/16,  12/16},
		},
	},

	paramtype2 = "facedir",
	pointable = false,
	diggable = false,
	is_ground_content = false,
	groups = {not_in_creative_inventory=1},
})

minetest.register_node("techage:coalfirehole_on", {
	description = I("TA3 Coal Power Station Firebox"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_coal_boiler.png^[colorize:black:80",
		"techage_coal_boiler.png^[colorize:black:80",
		"techage_coal_boiler.png^[colorize:black:80",
		"techage_coal_boiler.png^[colorize:black:80",
		"techage_coal_boiler.png^[colorize:black:80",
		{
			image = "techage_coal_boiler4.png^[colorize:black:80^techage_appl_firehole4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.4,
			},
		},
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-6/16, -6/16,  6/16,  6/16, 6/16,  12/16},
		},
	},
	paramtype2 = "facedir",
	light_source = 8,
	pointable = false,
	diggable = false,
	is_ground_content = false,
	groups = {not_in_creative_inventory=1},
})

techage.register_node({"techage:coalfirebox"}, {
	on_pull_item = function(pos, in_dir, num)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.get_items(inv, "fuel", num)
	end,
	on_push_item = function(pos, in_dir, stack)
		if firebox.Burntime[stack:get_name()] then
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local mem = tubelib2.get_mem(pos)
			start_firebox(pos, mem)
			return techage.put_items(inv, "fuel", stack)
		end
		return false
	end,
	on_unpull_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.put_items(inv, "fuel", stack)
	end,
	on_recv_message = function(pos, topic, payload)
		if topic == "state" then
			local meta = minetest.get_meta(pos)
			return techage.get_inv_state(meta, "fuel")
		else
			return "unsupported"
		end
	end,
})


minetest.register_craft({
	output = "techage:coalfirebox",
	recipe = {
		{'default:stone', 'default:stone', 'default:stone'},
		{'default:steel_ingot', '', 'default:steel_ingot'},
		{'default:stone', 'default:stone', 'default:stone'},
	},
})

minetest.register_lbm({
	label = "[techage] Power Station firebox",
	name = "techage:steam_engine",
	nodenames = {"techage:coalfirebox"},
	run_at_every_load = true,
	action = function(pos, node)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end
})


