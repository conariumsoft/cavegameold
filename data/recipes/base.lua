recipe("none", {{"tag:plank", 3}},  {{"PLATFORM_TILE", 3}})
recipe("none", {{"tag:plank", 10}}, {{"WORKBENCH", 1}})
recipe("none", {{"tag:plank", 1 }}, {{"TORCH_TILE", 4}})
recipe("none", {{"tag:plank", 10},  {"TORCH_TILE", 3}}, {{"CAMPFIRE", 1}})

recipe("none", {{"BAMBOO_TILE", 3}}, {{"PAPER", 6}})
recipe("none", {{"SULPHUR_TILE", 4}, {"PAPER", 4}}, {{"TNT_TILE", 1}})

recipe("none", {
	{"SULPHUR_TILE", 4},
	{"IRON_INGOT", 1}
}, {
	{"BOMB", 4},
})

recipe("none", {
	{"GOO", 4},
	{"tag:plank", 1}
}, {
	{"GLOWSTICK", 8}
})

recipe("none", {
	{"BOMB", 1},
	{"GOO", 2}
}, {
	{"STICKY_BOMB", 1}
})

recipe("none", {
	{"TNT_TILE", 4}
}, {
	{"DYNAMITE", 1},
})