const std = @import("std");
const entity = @import("entity.zig");
const rl = @import("rl.zig");

pub const Transform = struct {
    const Self = @This();

    component: entity.Component,

    position: rl.Vector2,
    scale: f32,
    rotation: f32,
    child: ?*entity.Entity,

    pub fn Move(self: *Self, mvmnt: rl.Vector2) void {
        self.position.AddV(mvmnt);
        if (self.child != null) {
            self.child.?.get_component(Transform, "Transform").?.Move(mvmnt);
        }
    }

    pub fn new(allocator: *std.mem.Allocator, args: anytype) !*Self {
        var temp = try allocator.create(Self);

        //TODO: parse args
        temp.position = rl.Vector2{ .x = 50, .y = 50 };
        temp.scale = 1;
        temp.rotation = 0;
        temp.child = null;

        temp.component = entity.Component.new(render, update, start, destroy);
        return temp;
    }

    pub fn render(comp: *entity.Component) void {
        //const self = @fieldParentPtr(Transform, "component", comp);
    }
    pub fn update(comp: *entity.Component, deltaTime: f64) void {
        const self = @fieldParentPtr(Transform, "component", comp);

        if (rl.IsKeyDown(rl.KEY_UP)) {
            self.Move(rl.Vector2{ .x = 0, .y = -(200.0 * @floatCast(f32, deltaTime)) });
        } else if (rl.IsKeyDown(rl.KEY_DOWN)) {
            self.Move(rl.Vector2{ .x = 0, .y = (200.0 * @floatCast(f32, deltaTime)) });
        }

        if (rl.IsKeyDown(rl.KEY_LEFT)) {
            self.Move(rl.Vector2{ .x = -(200.0 * @floatCast(f32, deltaTime)), .y = 0 });
        } else if (rl.IsKeyDown(rl.KEY_RIGHT)) {
            self.Move(rl.Vector2{ .x = (200.0 * @floatCast(f32, deltaTime)), .y = 0 });
        }
    }

    pub fn start(comp: *entity.Component) void {
        //const self = @fieldParentPtr(TestComponent, "component", comp);
    }

    pub fn destroy(comp: *entity.Component, allocator: *std.mem.Allocator) void {
        const self = @fieldParentPtr(Transform, "component", comp);
        allocator.destroy(self);
    }
};

pub const SpriteRenderer = struct {
    const Self = @This();

    component: entity.Component,
    texture: rl.Texture2D,
    color: rl.Color,
    transform: *Transform,

    pub fn new(allocator: *std.mem.Allocator, args: anytype) !*Self {
        var temp = try allocator.create(Self);
        temp.texture = rl.LoadTexture(args.@"0");
        temp.color = rl.WHITE;
        temp.component = entity.Component.new(render, update, start, destroy);
        return temp;
    }

    pub fn render(comp: *entity.Component) void {
        const self = @fieldParentPtr(SpriteRenderer, "component", comp);
        rl.DrawTextureEx(self.texture, self.transform.position, self.transform.rotation, self.transform.scale, self.color);
    }
    pub fn update(comp: *entity.Component, deltaTime: f64) void {
        const self = @fieldParentPtr(SpriteRenderer, "component", comp);
    }

    pub fn start(comp: *entity.Component) void {
        const self = @fieldParentPtr(SpriteRenderer, "component", comp);
        self.transform = comp.entity.?.get_component(Transform, "Transform").?;
    }

    pub fn destroy(comp: *entity.Component, allocator: *std.mem.Allocator) void {
        const self = @fieldParentPtr(SpriteRenderer, "component", comp);
        rl.UnloadTexture(self.texture);
        allocator.destroy(self);
    }
};
