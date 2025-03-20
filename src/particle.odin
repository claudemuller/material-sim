package sandsim

import rl "vendor:raylib"

Particle :: struct {
	type:   ParticleType,
	colour: rl.Color,
}

ParticleType :: enum {
	NONE,
	SAND,
	WATER,
}
