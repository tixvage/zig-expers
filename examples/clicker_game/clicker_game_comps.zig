const std = @import("std");
const hm = @import("hm");
const print = std.debug.print;

pub const RandomCircleManager = struct {
    const Self = @This();

    component: hm.entity.Component,
    random: std.rand.Xoroshiro128,
    timer: f32,
    current_pos: hm.rl.Vector2,
    score: i32,

    pub fn new(allocator: *std.mem.Allocator, args: anytype) !*Self {
        var temp = try allocator.create(Self);
        var prng = std.rand.DefaultPrng.init(blk: {
            var seed: u64 = undefined;
            try std.os.getrandom(std.mem.asBytes(&seed));
            break :blk seed;
        });
        temp.timer = 0.0;
        temp.random = prng;
        temp.score = 0;
        temp.current_pos = hm.rl.Vector2{ .x = 1080, .y = 720 };
        temp.component = hm.entity.Component.new(render, update, start, destroy);
        return temp;
    }

    pub fn get_random(self: *Self) hm.rl.Vector2 {
        return .{
            .x = @intToFloat(f32, self.random.random.intRangeAtMost(u32, 0, 1080)),
            .y = @intToFloat(f32, self.random.random.intRangeAtMost(u32, 0, 720)),
        };
    }

    pub fn render(comp: *hm.entity.Component) void {
        const self = @fieldParentPtr(RandomCircleManager, "component", comp);
        hm.rl.DrawCircleV(self.current_pos, 50, hm.rl.BLUE);
        hm.rl.DrawText(hm.rl.TextFormat("%d", self.score), 100, 50, 20, hm.rl.GREEN);
    }
    pub fn update(comp: *hm.entity.Component, deltaTime: f64) void {
        const self = @fieldParentPtr(RandomCircleManager, "component", comp);
        self.timer += hm.rl.GetFrameTime();

        if (self.timer >= 1.0) {
            self.current_pos = self.get_random();
            self.timer = 0.0;
            if (self.score >= 100) {
                self.score -= 50;
            } else {
                self.score -= 20;
            }
        }

        if (hm.rl.CheckCollisionPointCircle(
            .{
                .x = @intToFloat(f32, hm.rl.GetMouseX()),
                .y = @intToFloat(f32, hm.rl.GetMouseY()),
            },
            self.current_pos,
            50,
        ) and hm.rl.IsMouseButtonPressed(0)) {
            self.current_pos = self.get_random();
            self.timer = 0.0;
            self.score += 5;
        }
    }

    pub fn start(comp: *hm.entity.Component) void {
        const self = @fieldParentPtr(RandomCircleManager, "component", comp);
        print("{d}\n", .{self.random.random.intRangeAtMost(u8, 0, 255)});
    }

    pub fn destroy(comp: *hm.entity.Component, allocator: *std.mem.Allocator) void {
        const self = @fieldParentPtr(RandomCircleManager, "component", comp);
        allocator.destroy(self);
    }
};
