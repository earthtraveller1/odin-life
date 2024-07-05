package main

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

count_neighbours :: proc(cells: [][CELLS_WIDTH]bool, x: int, y: int) -> int {
	alive := 0

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

	return alive
}

should_live :: proc(live_neighbours: int, is_already_alive: bool) -> bool {
	if is_already_alive && live_neighbours < 2 {
		return false
	}

	if is_already_alive && (live_neighbours == 2 || live_neighbours == 3) {
		return true
	}

	if is_already_alive && live_neighbours > 3 {
		return false
	}

	if !is_already_alive && live_neighbours == 3 {
		return true
	}

	return false
}

