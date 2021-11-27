const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const hm = @import("hm");
const rl = @cImport(@cInclude("raylib.h"));

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var demo_scene = try hm.scene.TestScene.new(&gpa.allocator);

    try demo_scene.scene.start();

    rl.InitWindow(1080, 720, "HAHA");
    defer rl.CloseWindow();

    rl.SetTargetFPS(120);

    while (!rl.WindowShouldClose()) {
        demo_scene.scene.update(rl.GetFrameTime());
        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.ClearBackground(rl.RAYWHITE);
        demo_scene.scene.render();
    }

    demo_scene.destroy();
}
