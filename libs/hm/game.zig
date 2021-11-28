const scene = @import("scene.zig");
const std = @import("std");
const rl = @import("rl.zig");

var current_scene: ?*scene.Scene = null;

pub fn change_scene(new_scene: *scene.Scene) void {
    current_scene = new_scene;
}

pub fn get_scene() ?*scene.Scene {
    return current_scene;
}

pub const Game = struct {
    const Self = @This();

    allocator: *std.mem.Allocator,

    pub fn new(allocator: *std.mem.Allocator) Self {
        return Self{ .allocator = allocator };
    }

    pub fn run(self: *Self) !void {
        rl.InitWindow(1080, 720, "hm engine demo");

        if (current_scene != null) {
            try current_scene.?.start();
        }

        rl.SetTargetFPS(120);

        while (!rl.WindowShouldClose()) {
            if (current_scene != null) {
                current_scene.?.update(rl.GetFrameTime());
            }
            rl.BeginDrawing();
            rl.ClearBackground(rl.RAYWHITE);
            rl.DrawFPS(20, 20);

            if (current_scene != null) {
                current_scene.?.render();
            }

            rl.EndDrawing();
        }

        if (current_scene != null) {
            current_scene.?.destroy();
        }
    }
};
