const std = @import("std");
const entity = @import("entity.zig");
const rl = @import("rl.zig");

pub const AABB = struct {
    x: i32,
    y: i32,
    w: i32,
    h: i32,
};

pub const PhysicWorld = struct {
    const Self = @This();

    dynamics: std.ArrayList(*Collider),
    statics: std.ArrayList(*Collider),
    hm: i32,

    pub fn new(allocator: *std.mem.Allocator) Self {
        return Self{ .hm = 0, .dynamics = std.ArrayList(*Collider).init(allocator), .statics = std.ArrayList(*Collider).init(allocator) };
    }

    pub fn add_dynamic(self: *Self, coll: *Collider) !void {
        try self.dynamics.append(coll);
    }

    pub fn add_static(self: *Self, coll: *Collider) !void {
        try self.statics.append(coll);
    }

    pub fn update(self: *Self) void {
        for (self.dynamics.items) |dynamic| {
            for (self.statics.items) |static| {
                if (rl.CheckCollisionRecs(
                    rl.Rectangle{
                        .x = @intToFloat(f32, dynamic.aabb.x),
                        .y = @intToFloat(f32, dynamic.aabb.y),
                        .height = @intToFloat(f32, dynamic.aabb.h),
                        .width = @intToFloat(f32, dynamic.aabb.w),
                    },
                    rl.Rectangle{
                        .x = @intToFloat(f32, static.aabb.x),
                        .y = @intToFloat(f32, static.aabb.y),
                        .height = @intToFloat(f32, static.aabb.h),
                        .width = @intToFloat(f32, static.aabb.w),
                    },
                )) {
                    std.debug.print("{d}:{d}\n", .{ dynamic.velocity.x, dynamic.velocity.y });
                    dynamic.transform.position.AddF(-dynamic.velocity.x, -dynamic.velocity.y); //@intToFloat(f32, @floatToInt(i32, rect.width + 1.0));
                    //dynamic.transform.position.y -= rect.height + 1.0;
                }
            }
        }
    }

    pub fn destroy(self: *Self) void {
        self.dynamics.deinit();
        self.statics.deinit();
    }
};

pub const BasicMovement = struct {
    const Self = @This();

    component: entity.Component,
    transform: *Transform,
    body: *KinematicBody,
    velocity: rl.Vector2,

    pub fn new(allocator: *std.mem.Allocator, args: anytype) !*Self {
        var temp = try allocator.create(Self);

        temp.component = entity.Component.new(render, update, start, destroy);
        return temp;
    }

    pub fn render(comp: *entity.Component) void {}
    pub fn update(comp: *entity.Component, deltaTime: f64) void {
        const self = @fieldParentPtr(BasicMovement, "component", comp);

        self.velocity = rl.Vector2{
            .x = 0,
            .y = 0,
        };

        if (rl.IsKeyDown(rl.KEY_UP)) {
            self.velocity.AddV(rl.Vector2{ .x = 0, .y = -(200.0 * @floatCast(f32, deltaTime)) });
        } else if (rl.IsKeyDown(rl.KEY_DOWN)) {
            self.velocity.AddV(rl.Vector2{ .x = 0, .y = (200.0 * @floatCast(f32, deltaTime)) });
        }

        if (rl.IsKeyDown(rl.KEY_LEFT)) {
            self.velocity.AddV(rl.Vector2{ .x = -(200.0 * @floatCast(f32, deltaTime)), .y = 0 });
        } else if (rl.IsKeyDown(rl.KEY_RIGHT)) {
            self.velocity.AddV(rl.Vector2{ .x = (200.0 * @floatCast(f32, deltaTime)), .y = 0 });
        }

        self.body.move(self.velocity);
    }

    pub fn start(comp: *entity.Component) void {
        const self = @fieldParentPtr(BasicMovement, "component", comp);
        self.transform = comp.entity.get_component(Transform).?;
        self.body = comp.entity.get_component(KinematicBody).?;
    }

    pub fn destroy(comp: *entity.Component, allocator: *std.mem.Allocator) void {
        const self = @fieldParentPtr(BasicMovement, "component", comp);
        allocator.destroy(self);
    }
};

pub const Transform = struct {
    const Self = @This();

    component: entity.Component,

    position: rl.Vector2,
    scale: f32,
    rotation: f32,
    child: ?*entity.Entity,

    pub fn Multiply(self: *Self, value: f32) void {
        self.position.x *= value;
        self.position.y *= value;
    }

    pub fn Move(self: *Self, mvmnt: rl.Vector2) void {
        self.position.AddV(mvmnt);
        if (self.child != null) {
            self.child.?.get_component(Transform).?.Move(mvmnt);
        }
    }

    pub fn new(allocator: *std.mem.Allocator, args: anytype) !*Self {
        var temp = try allocator.create(Self);

        //TODO: parse args
        temp.position = rl.Vector2{ .x = args.@"0", .y = args.@"1" };
        temp.scale = 0.5;
        temp.rotation = 0;
        temp.child = null;

        temp.component = entity.Component.new(render, update, start, destroy);
        return temp;
    }

    pub fn render(comp: *entity.Component) void {}
    pub fn update(comp: *entity.Component, deltaTime: f64) void {}

    pub fn start(comp: *entity.Component) void {}

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
        self.transform = comp.entity.get_component(Transform).?;
    }

    pub fn destroy(comp: *entity.Component, allocator: *std.mem.Allocator) void {
        const self = @fieldParentPtr(SpriteRenderer, "component", comp);
        rl.UnloadTexture(self.texture);
        allocator.destroy(self);
    }
};

pub const Collider = struct {
    const Self = @This();

    component: entity.Component,

    aabb: AABB,
    transform: *Transform,
    pw: *PhysicWorld,
    velocity: rl.Vector2,

    pub fn new(allocator: *std.mem.Allocator, args: anytype) !*Self {
        var temp = try allocator.create(Self);
        temp.component = entity.Component.new(render, update, start, destroy);
        temp.pw = args.@"0";
        if (args.@"1" == true) {
            try temp.pw.add_static(temp);
        } else {
            try temp.pw.add_dynamic(temp);
        }
        return temp;
    }

    pub fn render(comp: *entity.Component) void {
        const self = @fieldParentPtr(Collider, "component", comp);
        rl.DrawRectangle(self.aabb.x, self.aabb.y, self.aabb.w, self.aabb.h, rl.Color{ .r = 0, .g = 250, .b = 100, .a = 150 });
    }

    pub fn update(comp: *entity.Component, deltaTime: f64) void {
        const self = @fieldParentPtr(Collider, "component", comp);

        self.aabb.x = @floatToInt(i32, self.transform.position.x);
        self.aabb.y = @floatToInt(i32, self.transform.position.y);
    }

    pub fn start(comp: *entity.Component) void {
        const self = @fieldParentPtr(Collider, "component", comp);
        self.transform = comp.entity.get_component(Transform).?;

        self.aabb.x = @floatToInt(i32, self.transform.position.x);
        self.aabb.y = @floatToInt(i32, self.transform.position.y);
        self.aabb.w = 100;
        self.aabb.h = 100;
    }

    pub fn destroy(comp: *entity.Component, allocator: *std.mem.Allocator) void {
        const self = @fieldParentPtr(Collider, "component", comp);
        allocator.destroy(self);
    }
};

pub const KinematicBody = struct {
    const Self = @This();

    component: entity.Component,
    collider: *Collider,
    velocity: rl.Vector2,

    pub fn new(allocator: *std.mem.Allocator, args: anytype) !*Self {
        var temp = try allocator.create(Self);
        temp.component = entity.Component.new(render, update, start, destroy);
        return temp;
    }

    pub fn render(comp: *entity.Component) void {
        const self = @fieldParentPtr(KinematicBody, "component", comp);
    }
    pub fn update(comp: *entity.Component, deltaTime: f64) void {
        const self = @fieldParentPtr(KinematicBody, "component", comp);
    }

    pub fn start(comp: *entity.Component) void {
        const self = @fieldParentPtr(KinematicBody, "component", comp);
        self.collider = comp.entity.get_component(Collider).?;
    }

    pub fn destroy(comp: *entity.Component, allocator: *std.mem.Allocator) void {
        const self = @fieldParentPtr(KinematicBody, "component", comp);
        allocator.destroy(self);
    }

    pub fn move(self: *Self, vel: rl.Vector2) void {
        self.velocity = vel;
        self.collider.velocity = vel;
        self.collider.transform.Move(self.velocity);
    }
};
