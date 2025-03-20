package sandsim

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

SAND_COLOUR :: rl.Color{220, 177, 89, 255}

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
}

update :: proc() {
	dt := rl.GetFrameTime()

	if .LEFT in input.mouse.btns {
		mouseCol := i32(input.mouse.px_pos.x / PARTICLE_SIZE)
		mouseRow := i32(input.mouse.px_pos.y / PARTICLE_SIZE)
		extent := i32(math.floor_f32(BRUSH_SIZE / 2))

		for i in -extent ..= extent {
			for j in -extent ..= extent {
				if (rand.float32() > 0.1) {
					continue
				}

				x := mouseCol + i
				y := mouseRow

				if within_cols(x) && within_rows(y) {
					p := &grid[y * i32(NUM_PARTICLES_IN_ROW) + x]
					p.colour = vary_colour(SAND_COLOUR)
					p.type = .SAND
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
		below_left := below - 1
		below_right := below + 1

		switch (p.type) {
		case .NONE:

		case .SAND:
			if below >= TOTAL_NUM_PARTICLES || below_left >= TOTAL_NUM_PARTICLES do break

			if is_empty(below) do swap(i, below)
			else if is_empty(below_left) do swap(i, below_left)
			else if is_empty(below_right) do swap(i, below_right)

		case .WATER:
		// moveWater(i, ParticleType::NONE);
		}
	}
	// }
}

render :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.LIGHTGRAY)

	for p, i in grid {
		if (p.type != .NONE) {
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

within_cols :: proc(i: i32) -> bool {
	return i >= 0 && i <= NUM_PARTICLES_IN_ROW
}

within_rows :: proc(i: i32) -> bool {
	return i >= 0 && i <= NUM_PARTICLES_IN_COL
}

swap :: proc(i, j: int) {
	grid[i], grid[j] = grid[j], grid[i]
}

is_empty :: proc(i: int) -> bool {
	return grid[i].type == .NONE
}
