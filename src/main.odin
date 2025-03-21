package matsim

import "core:fmt"
import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

MAX_SCREEN_WIDTH :: 1024
MAX_SCREEN_HEIGHT :: 768

PARTICLE_SIZE :: 2
BRUSH_SIZE :: 10
GRAVITY :: 0.006

NUM_PARTICLES_IN_ROW :: MAX_SCREEN_WIDTH / PARTICLE_SIZE
NUM_PARTICLES_IN_COL :: MAX_SCREEN_HEIGHT / PARTICLE_SIZE
TOTAL_NUM_PARTICLES :: NUM_PARTICLES_IN_ROW * NUM_PARTICLES_IN_COL

input: Input

grid: [TOTAL_NUM_PARTICLES]Particle
dbuf_grid: [TOTAL_NUM_PARTICLES]Particle
brush: [BRUSH_SIZE]Particle

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
						p.colour = vary_colour(colours[.SAND])
						p.material = .SAND

					case 2:
						p.colour = vary_colour(colours[.WATER])
						p.material = .WATER

					case 3:
						p.colour = vary_colour(colours[.WOOD])
						p.material = .WOOD

					case 4:
						p.colour = vary_colour(colours[.SMOKE])
						p.material = .SMOKE
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
			dir := rand.choice([]int{1, -1})
			below_side := below + dir

			if within_grid(below) && is_empty(below) do swap(i, below)
			else if within_grid(below_side) && is_empty(below_side) do swap(i, below_side)

		case .WATER:
			dir := rand.choice([]int{1, -1})

			below_a := i + dir
			below_b := i + dir

			if within_grid(below) && is_empty(below) do swap(i, below)
			else if within_grid(below_a) && is_empty(below_a) do swap(i, below_a)
			else if within_grid(below_b) && is_empty(below_b) do swap(i, below_b)

		case .WOOD:

		case .SMOKE:
			up := i - NUM_PARTICLES_IN_ROW
			up_left := up - 1
			up_right := up + 1

			if !within_grid(up) || !within_grid(up_left) || !within_grid(up_right) do break

			dir := rand.choice([]int{1, -1})

			if is_empty(up) do swap(i, up)
			else if is_empty(up_left) do swap(i, up_left)
			else if is_empty(up_right) do swap(i, up_right)
		}
	}
	// }

	dbuf_grid = grid
}

render :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.LIGHTGRAY)

	for p, i in dbuf_grid {
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
