package main

import "base:runtime"

import "core:c"
import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:strings"

import rl "vendor:raylib"

CELL_SIZE :: 32
CELLS_WIDTH :: 1280 / CELL_SIZE
CELLS_HEIGHT :: 720 / CELL_SIZE
TICK_LENGTH :: 20

draw_cells :: proc(
	cells: [][CELLS_WIDTH]bool,
	x_offset: c.int,
	y_offset: c.int,
	color: rl.Color = rl.WHITE,
) {
	for row, y in cells {
		for cell, x in row {
			if cell {
				rl.DrawRectangle(
					c.int(x * CELL_SIZE) + x_offset,
					c.int(y * CELL_SIZE) + y_offset,
					CELL_SIZE,
					CELL_SIZE,
					color,
				)
			}
		}
	}
}

draw_formatted_text :: proc(x: int, y: int, font_size: int, format_string: string, args: ..any) {
	string_builder := strings.builder_make_none()
	defer strings.builder_destroy(&string_builder)

	stuff := fmt.sbprintf(&string_builder, format_string, ..args)
	cstuff := strings.clone_to_cstring(stuff)
	defer delete(cstuff)

	rl.DrawText(cstuff, c.int(x), c.int(y), c.int(font_size), rl.YELLOW)
}

Game :: struct {
	paused:        bool,
	cells:         [][CELLS_WIDTH]bool,
	back_cells:    [][CELLS_WIDTH]bool,

	// How much has been dragged by the user
	drag_x:        int,
	drag_y:        int,
	speed:         int,
	tick_progress: int,
}

game_new :: proc() -> Game {
	rl.InitWindow(1280, 720, "Odin Life")
	rl.SetTargetFPS(60)

	return Game {
		paused = true,
		cells = make([][CELLS_WIDTH]bool, CELLS_HEIGHT),
		back_cells = make([][CELLS_WIDTH]bool, CELLS_HEIGHT),
		speed = 1,
		tick_progress = 0,
	}
}

game_update :: proc(game: ^Game) {
	using game

	if !paused {
		tick_progress += speed

		if tick_progress >= TICK_LENGTH {
			tick_progress = 0

			for y in 0 ..< CELLS_HEIGHT {
				for x in 0 ..< CELLS_WIDTH {
					alive_count := count_neighbours(cells, x, y)
					back_cells[y][x] = should_live(alive_count, cells[y][x])
				}
			}

			temp := back_cells
			back_cells = cells
			cells = temp
		}
	}

	game_handle_input(game)
}

game_handle_input :: proc(game: ^Game) {
	using game

	if rl.IsMouseButtonDown(.LEFT) {
		mouse_position := rl.GetMousePosition()
		cell_x := int((mouse_position.x - c.float(drag_x)) / CELL_SIZE)
		cell_y := int((mouse_position.y - c.float(drag_y)) / CELL_SIZE)
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
	speed = math.clamp(speed, 1, TICK_LENGTH)
}

game_render :: proc(game: ^Game) {
    using game

	rl.ClearBackground(rl.BLACK)
	rl.BeginDrawing()

	rl.DrawRectangle(c.int(drag_x), c.int(drag_y), 1280, 720, rl.GetColor(0x820082))

	if paused {
		rl.DrawText("Paused", 10, 10, 48, rl.YELLOW)
	}

	draw_formatted_text(10, 72, 48, "x%d", speed)

	draw_formatted_text(
		10,
		128,
		32,
		"X: %d Y: %d",
		(rl.GetMouseX() + c.int(drag_x)) / CELL_SIZE,
		(rl.GetMouseY() + c.int(drag_y)) / CELL_SIZE,
	)

	draw_cells(cells, c.int(drag_x), c.int(drag_y))

	rl.DrawRectangle(
		((rl.GetMouseX() - c.int(drag_x)) / CELL_SIZE) * CELL_SIZE + c.int(drag_x),
		((rl.GetMouseY() - c.int(drag_y)) / CELL_SIZE) * CELL_SIZE + c.int(drag_y),
		CELL_SIZE,
		CELL_SIZE,
		rl.GREEN,
	)

	rl.EndDrawing()
}

game_destroy :: proc(game: ^Game) {
    delete(game.back_cells)
    delete(game.cells)
    rl.CloseWindow()
}

main :: proc() {
    game := game_new()
    defer game_destroy(&game)

	for !rl.WindowShouldClose() {
        game_update(&game)
        game_render(&game)
	}
}
