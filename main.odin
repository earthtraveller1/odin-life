package main

import "core:c"
import "core:fmt"
import "core:math/rand"
import "core:strings"

import rl "vendor:raylib"

CELL_SIZE :: 16
CELLS_WIDTH :: 1280 / CELL_SIZE
CELLS_HEIGHT :: 720 / CELL_SIZE

draw_cells :: proc(cells: [][CELLS_WIDTH]bool, x_offset: c.int, y_offset: c.int) {
	for row, y in cells {
		for cell, x in row {
			if cell {
				rl.DrawRectangle(
					c.int(x * CELL_SIZE) + x_offset,
					c.int(y * CELL_SIZE) + y_offset,
					CELL_SIZE,
					CELL_SIZE,
					rl.WHITE,
				)
			}
		}
	}
}

remap_x :: proc(x: int) -> int {
	if x < 0 {
		return CELLS_HEIGHT + x
	} else if x >= CELLS_WIDTH {
		return x - CELLS_WIDTH
	} else {
		return x
	}
}

remap_y :: proc(y: int) -> int {
	if y < 0 {
		return CELLS_HEIGHT + y
	} else if y >= CELLS_HEIGHT {
		return y - CELLS_HEIGHT
	} else {
		return y
	}
}

count_neighbours :: proc(cells: [][CELLS_WIDTH]bool, x: int, y: int) -> (alive: int) {
	for offset_x in -1 ..= 1 {
		for offset_y in -1 ..= 1 {
			if offset_x == 0 && offset_y == 0 {
				continue
			}

			if cells[remap_y(y + offset_y)][remap_x(x + offset_x)] {
				alive += 1
			}
		}
	}

	return
}

main :: proc() {
	rl.InitWindow(1280, 720, "Odin Life")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	paused := true

	cells := make([][CELLS_WIDTH]bool, CELLS_HEIGHT)
	back_cells := make([][CELLS_WIDTH]bool, CELLS_HEIGHT)

	zoom: f32
	drag_x: int
	drag_y: int

	speed: int = 1
	tick_progress: int = 0

	for !rl.WindowShouldClose() {
		if !paused {
			tick_progress += speed

			if tick_progress >= 20 {
                tick_progress = 0

				for y in 0 ..< CELLS_HEIGHT {
					for x in 0 ..< CELLS_WIDTH {
						alive_count := count_neighbours(cells, x, y)

						if back_cells[y][x] && alive_count < 2 {
							back_cells[y][x] = false
						}

						if back_cells[y][x] && alive_count > 3 {
							back_cells[y][x] = false
						}

						if !back_cells[y][x] && alive_count == 3 {
							back_cells[y][x] = true
						}
					}
				}

				{
					temp := back_cells
					back_cells = cells
					cells = temp
				}
			}
		}

		if rl.IsMouseButtonDown(.LEFT) {
			mouse_position := rl.GetMousePosition()
			cell_x := int((mouse_position.x - c.float(drag_x)) / CELL_SIZE)
			cell_y := int((mouse_position.y - c.float(drag_y)) / CELL_SIZE)

			fmt.println("x =", cell_x, "y =", cell_y)
			cells[cell_y][cell_x] = true
		}

		if rl.IsMouseButtonDown(.RIGHT) {
			mouse_position := rl.GetMousePosition()
			cell_x := int((mouse_position.x - c.float(drag_x)) / CELL_SIZE)
			cell_y := int((mouse_position.y - c.float(drag_y)) / CELL_SIZE)
			cells[cell_y][cell_x] = false
		}

		if rl.IsMouseButtonDown(.MIDDLE) {
			diff := rl.GetMouseDelta()
			drag_x += int(diff.x)
			drag_y += int(diff.y)
		}

		if rl.IsKeyPressed(.SPACE) {
			paused = (!paused)
		}

        speed += int(rl.GetMouseWheelMove())

		rl.ClearBackground(rl.BLACK)
		rl.BeginDrawing()

		rl.DrawRectangle(c.int(drag_x), c.int(drag_y), 1280, 720, rl.GetColor(0x820082))

		if paused {
			rl.DrawText("Paused", 10, 10, 48, rl.YELLOW)
        }

        {
            string_builder := strings.builder_make_none()
            defer strings.builder_destroy(&string_builder)

            stuff := fmt.sbprintf(&string_builder, "x%d", speed)
            cstuff := strings.clone_to_cstring(stuff)
            defer delete(cstuff)

            rl.DrawText(cstuff, 10, 72, 48, rl.YELLOW)
        }

		draw_cells(cells, c.int(drag_x), c.int(drag_y))

		rl.EndDrawing()
	}
}
