const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const hm = @import("hm");
const rl = @cImport(@cInclude("raylib.h"));

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var scene_bruh = try hm.scene.TestScene.new(&gpa.allocator);
    scene_bruh.destroy();
    rl.InitWindow(1080, 720, "HAHA");
    defer rl.CloseWindow();

    rl.SetTargetFPS(120);

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.ClearBackground(rl.RAYWHITE);
    }
}
