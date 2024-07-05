package main

import rl "vendor:raylib" 

main :: proc() {
    rl.InitWindow(1280, 720, "Odin Life")
    defer rl.CloseWindow()

    rl.SetTargetFPS(60)

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.EndDrawing()
    }
}
