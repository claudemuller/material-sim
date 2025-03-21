package sandsim

import "core:fmt"
import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

MAX_SCREEN_WIDTH :: 1024
MAX_SCREEN_HEIGHT :: 768

PARTICLE_SIZE :: 3
BRUSH_SIZE :: 10
GRAVITY :: 0.006

NUM_PARTICLES_IN_ROW :: MAX_SCREEN_WIDTH / PARTICLE_SIZE
NUM_PARTICLES_IN_COL :: MAX_SCREEN_HEIGHT / PARTICLE_SIZE
TOTAL_NUM_PARTICLES :: NUM_PARTICLES_IN_ROW * NUM_PARTICLES_IN_COL

input: Input

grid: [TOTAL_NUM_PARTICLES]Particle

main :: proc() {
	screen_width: i32 = NUM_PARTICLES_IN_ROW * PARTICLE_SIZE
	screen_height: i32 = NUM_PARTICLES_IN_COL * PARTICLE_SIZE

	rl.InitWindow(screen_width, screen_height, "Sand Simulation")
	defer rl.CloseWindow()
	rl.SetTargetFPS(500)
	rl.SetExitKey(.ESCAPE)

	setup()

	for !rl.WindowShouldClose() {
		process_input()
		update()
		render()
	}
}

setup :: proc() {
	ui_setup()
}

update :: proc() {
	ui_update()

	dt := rl.GetFrameTime()

	if .LEFT in input.mouse.btns {
		mouseCol := i32(input.mouse.px_pos.x / PARTICLE_SIZE)
		mouseRow := i32(input.mouse.px_pos.y / PARTICLE_SIZE)
		extent := i32(math.floor_f32(BRUSH_SIZE / 2))
		// material_type := MaterialType[selected_material_idx]

		for i in -extent ..= extent {
			for j in -extent ..= extent {
				if (rand.float32() > 0.05) {
					continue
				}

				x := mouseCol + i
				y := mouseRow + j

				// gx = x
				// gy = y

				if within_grid(int(y) * NUM_PARTICLES_IN_ROW + int(x)) {
					p := &grid[y * i32(NUM_PARTICLES_IN_ROW) + x]

					switch selected_material_idx {
					case 1:
						p.colour = vary_colour(SAND_COLOUR)
						p.material = .SAND

					case 2:
						p.colour = vary_colour(WATER_COLOUR)
						p.material = .WATER

					case 3:
						p.colour = vary_colour(WOOD_COLOUR)
						p.material = .WOOD
					}
				}
			}
		}
	}

	// static float accumulator;
	// accumulator += dt;
	//
	// while (accumulator >= GRAVITY) {
	//     accumulator -= GRAVITY;

	#reverse for p, i in grid {
		below := i + NUM_PARTICLES_IN_ROW

		switch (p.material) {
		case .NONE:

		case .SAND:
			below_left := below - 1
			below_right := below + 1

			if !within_grid(below) || !within_grid(below_left) || !within_grid(below_right) do break

			if is_empty(below) do swap(i, below)
			else if is_empty(below_left) do swap(i, below_left)
			else if is_empty(below_right) do swap(i, below_right)

		case .WATER:
			left := i - 1
			right := i + 1

			if !within_grid(below) || !within_grid(left) || !within_grid(right) do break

			if is_empty(below) do swap(i, below)
			else if is_empty(left) do swap(i, left)
			else if is_empty(right) do swap(i, right)

		case .WOOD:

		case .SMOKE:
		}
	}
	// }
}

render :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.LIGHTGRAY)

	for p, i in grid {
		if (p.material != .NONE) {
			x := i32(i % NUM_PARTICLES_IN_ROW)
			y := i32(i / NUM_PARTICLES_IN_ROW)
			rl.DrawRectangle(
				x * PARTICLE_SIZE,
				y * PARTICLE_SIZE,
				PARTICLE_SIZE,
				PARTICLE_SIZE,
				p.colour,
			)
		}
	}

	ui_draw()

	// Debug
	// rl.DrawText(
	// 	fmt.ctprintf("x:%v\ny:%v", gx, gy),
	// 	i32(input.mouse.px_pos.x),
	// 	i32(input.mouse.px_pos.y),
	// 	20,
	// 	rl.BLACK,
	// )

	rl.EndDrawing()
}

vary_colour :: proc(c: rl.Color) -> rl.Color {
	hsv := rl.ColorToHSV(c)
	saturation := f32(rand.int_max(4) - 2) / 10
	// Lightness
	value := f32(rand.int_max(3) - 1) / 10

	hsv.y += saturation
	hsv.z += value

	return rl.ColorFromHSV(hsv.x, hsv.y, hsv.z)
}

within_grid :: proc {
	within_grid_i,
	within_grid_xy,
}

within_grid_i :: proc(i: int) -> bool {
	return i >= 0 && i < TOTAL_NUM_PARTICLES
}
within_grid_xy :: proc(x, y: int) -> bool {
	return x >= 0 && x < NUM_PARTICLES_IN_ROW && y >= 0 && y < NUM_PARTICLES_IN_COL
}

swap :: proc(i, j: int) {
	grid[i], grid[j] = grid[j], grid[i]
}

is_empty :: proc(i: int) -> bool {
	return grid[i].material == .NONE
}
