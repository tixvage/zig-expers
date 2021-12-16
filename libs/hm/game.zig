const scene = @import("scene.zig");
const std = @import("std");
const print = std.debug.print;
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
    bg: rl.Color,
    dc: bool,

    pub fn set_clear_background(self: *Self, bg: rl.Color) void {
        self.bg = bg;
    }

    pub fn draw_cursor_with_circle(self: *Self) void {
        self.dc = true;
    }

    pub fn set_title(self: *Self, title: [*c]const u8) void {
        rl.SetWindowTitle(title);
    }

    pub fn new(allocator: *std.mem.Allocator) Self {
        rl.InitWindow(1080, 720, "hm engine demo");
        return Self{ .allocator = allocator, .bg = rl.WHITE, .dc = false };
    }

    pub fn run(self: *Self) !void {
        if (current_scene) |_scene| {
            try _scene.start();
        }

        rl.SetTargetFPS(120);

        while (!rl.WindowShouldClose()) {
            if (current_scene) |_scene| {
                _scene.update(rl.GetFrameTime());
            }
            rl.BeginDrawing();
            rl.ClearBackground(self.bg);
            if (current_scene) |_scene| {
                _scene.render();
            }
            rl.DrawFPS(20, 20);
            if (self.dc) {
                rl.DrawCircle(rl.GetMouseX(), rl.GetMouseY(), 10, rl.GRAY);
            }
            rl.EndDrawing();
        }

        if (current_scene) |_scene| {
            _scene.destroy();
        }

        rl.CloseWindow();
    }
};
