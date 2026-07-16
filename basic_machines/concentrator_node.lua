--[[

	TechAge
	=======

	Copyright (C) 2019-2026 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Tube Concentrator Node (directionless, like the pipe junction)

]]--

local S = techage.S
local Tube = techage.Tube

local size1 = 1/8
local size2 = 2/8
local size3 = 13/32
local Boxes = {
	{
		{-size1, -size1,  size1, size1,  size1, 0.5 },
		{-size2, -size2,  size3, size2,  size2, 0.5 },
	},
	{
		{-size1, -size1, -size1, 0.5, size1, size1},
		{ size3, -size2, -size2, 0.5, size2,  size2},
	},
	{
		{-size1, -size1, -0.5,  size1,  size1,  size1},
		{-size2, -size2, -0.5,  size2,  size2, -size3},
	},
	{
		{-0.5,  -size1, -size1,  size1,  size1, size1},
		{-0.5,  -size2, -size2, -size3,  size2, size2},
	},
	{
		{-size1, -0.5,  -size1, size1,  size1, size1},
		{-size2, -0.5,  -size2, size2, -size3, size2},
	},
	{
		{-size1, -size1, -size1, size1,  0.5,  size1},
		{-size2, size3,  -size2, size2,  0.5,  size2},
	}
}

local names_ta2 = networks.register_junction("techage:tube_concentrator_node", 1/8, Boxes, Tube, {
	description = S("Tube Concentrator Node"),
	tiles = {"techage_tube_junction.png"},
	use_texture_alpha = techage.CLIP,
	is_ground_content = false,
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3, techage_trowel = 1},
	sounds = default.node_sound_metal_defaults(),

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local name = "techage:tube_concentrator_node" .. networks.junction_type(pos, Tube)
		minetest.swap_node(pos, {name = name, param2 = 0})
		Tube:after_place_node(pos)
	end,
	tubelib2_on_update2 = function(pos, dir1, tlib2, node)
		local name = "techage:tube_concentrator_node" .. networks.junction_type(pos, Tube)
		minetest.swap_node(pos, {name = name, param2 = 0})
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Tube:after_dig_node(pos)
	end,
}, 25)

for _, name in ipairs(names_ta2) do
	Tube:set_valid_sides(name, {"B", "R", "F", "L", "D", "U"})
end

local names_ta4 = networks.register_junction("techage:ta4_tube_concentrator_node", 1/8, Boxes, Tube, {
	description = S("TA4 Tube Concentrator Node"),
	tiles = {"techage_tubeta4_junction.png"},
	use_texture_alpha = techage.CLIP,
	is_ground_content = false,
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3, techage_trowel = 1},
	sounds = default.node_sound_metal_defaults(),

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local name = "techage:ta4_tube_concentrator_node" .. networks.junction_type(pos, Tube)
		minetest.swap_node(pos, {name = name, param2 = 0})
		Tube:after_place_node(pos)
	end,
	tubelib2_on_update2 = function(pos, dir1, tlib2, node)
		local name = "techage:ta4_tube_concentrator_node" .. networks.junction_type(pos, Tube)
		minetest.swap_node(pos, {name = name, param2 = 0})
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Tube:after_dig_node(pos)
	end,
}, 25)

for _, name in ipairs(names_ta4) do
	Tube:set_valid_sides(name, {"B", "R", "F", "L", "D", "U"})
end

minetest.register_craft({
	output = "techage:tube_concentrator_node25 2",
	recipe = {
		{"", "techage:tubeS", ""},
		{"techage:tubeS", "", "techage:tubeS"},
		{"", "techage:tubeS", ""},
	},
})

minetest.register_craft({
	output = "techage:ta4_tube_concentrator_node25 2",
	recipe = {
		{"", "techage:ta4_tubeS", ""},
		{"techage:ta4_tubeS", "", "techage:ta4_tubeS"},
		{"", "techage:ta4_tubeS", ""},
	},
})
