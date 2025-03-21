package matsim

import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

Colour :: struct {
	saturation_min: f32,
	saturation_max: f32,
	value_min:      f32,
	value_max:      f32,
	colour:         rl.Color,
}

colours := [ColourType]Colour {
	.SAND = {
		saturation_min = 0.70,
		saturation_max = 0.75,
		value_min = 0.95,
		value_max = 1.0,
		colour = rl.Color{220, 177, 89, 255},
	},
	.WATER = {
		saturation_min = 0.70,
		saturation_max = 0.75,
		value_min = 0.95,
		value_max = 1.0,
		colour = rl.Color{116, 204, 244, 255},
	},
	.WOOD = {
		saturation_min = 0.70,
		saturation_max = 0.75,
		value_min = 0.95,
		value_max = 1.0,
		colour = rl.Color{139, 105, 20, 255},
	},
	.SMOKE = {
		saturation_min = 0.70,
		saturation_max = 0.75,
		value_min = 0.95,
		value_max = 1.0,
		colour = rl.Color{130, 130, 130, 255},
	},
}

ColourType :: enum {
	SAND,
	WATER,
	WOOD,
	SMOKE,
}


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

vary_colour :: proc(c: Colour) -> rl.Color {
	hsv := rl.ColorToHSV(c.colour)
	saturation := math.max(c.saturation_min, math.min(c.saturation_max, rand.float32()))
	// Lightness
	value := math.max(c.value_min, math.min(c.value_max, rand.float32()))

	hsv.y = saturation
	hsv.z = value

	return rl.ColorFromHSV(hsv.x, hsv.y, hsv.z)
}

// get_materials :: proc() -> []string {
// 	mats: [len(MaterialType)]string
// 	for k, i in MaterialType {
// 		mats[i] = materials[k]
// 	}
// 	return mats[:]
// }
