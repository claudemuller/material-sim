package sandsim

import rl "vendor:raylib"

SAND_COLOUR :: rl.Color{220, 177, 89, 255}
WATER_COLOUR :: rl.Color{116, 204, 244, 255}
WOOD_COLOUR :: rl.Color{139, 105, 20, 255}

Particle :: struct {
	material: MaterialType,
	colour:   rl.Color,
}

MaterialType :: enum {
	NONE,
	SAND,
	WATER,
	WOOD,
	SMOKE,
}

materials :: [MaterialType]string {
	.NONE  = "None",
	.SAND  = "Sand",
	.WATER = "Water",
	.WOOD  = "Wood",
	.SMOKE = "Smoke",
}

material_options := []string{"None", "Sand", "Water", "Wood", "Smoke"}

// get_materials :: proc() -> []string {
// 	mats: [len(MaterialType)]string
// 	for k, i in MaterialType {
// 		mats[i] = materials[k]
// 	}
// 	return mats[:]
// }
