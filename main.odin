package main

import "core:c"
import "core:math/rand"
import "core:fmt"

import rl "vendor:raylib"

CELL_SIZE :: 8
CELLS_WIDTH :: 1280 / CELL_SIZE
CELLS_HEIGHT :: 720 / CELL_SIZE

cells: [CELLS_HEIGHT][CELLS_WIDTH]bool

main :: proc() {
	rl.InitWindow(1280, 720, "Odin Life")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
        if rl.IsMouseButtonDown(.LEFT) {
            mouse_position := rl.GetMousePosition()
            cell_x := int(mouse_position.x / 8)
            cell_y := int(mouse_position.y / 8)
            cells[cell_y][cell_x] = true
        }

		rl.BeginDrawing()

		for row, y in cells {
			for cell, x in row {
				if cell {
					rl.DrawRectangle(c.int(x * CELL_SIZE), c.int(y * CELL_SIZE), 8, 8, rl.WHITE)
				}
			}
		}

		rl.EndDrawing()
	}
}
