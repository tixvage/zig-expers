const entity = @import("entity.zig");
const std = @import("std");
const print = std.debug.print;
const comps = @import("components.zig");

pub const Scene = struct {
    const Self = @This();

    create_entities_fn: ?fn (self: *Self) anyerror!void,
    destroy_fn: ?fn (self: *Self) i32,
    update_fn: ?fn (self: *Self, deltaTime: f32) void,

    entites: std.ArrayList(*entity.Entity),
    allocator: *std.mem.Allocator,
    pw: comps.PhysicWorld,

    fn empty_ce(self: *Self) anyerror!void {}
    fn empyt_update(self: *Self, deltaTime: f32) void {}

    pub fn new(allocator: *std.mem.Allocator, args: anytype) Self {
        var temp: Self = undefined;
        temp.allocator = allocator;
        temp.update_fn = null;
        temp.create_entities_fn = null;
        inline for (args) |arg, i| {
            switch (@TypeOf(arg)) {
                fn (*Scene) anyerror!void => {
                    print("create_entities found\n", .{});
                    temp.create_entities_fn = arg;
                },
                fn (*Self) i32 => {
                    temp.destroy_fn = arg;
                },
                else => {
                    print("WTF is that function {}\n", .{arg});
                    @panic("Wrong function type");
                },
            }
        }
        if (temp.update_fn == null) {
            temp.update_fn = empyt_update;
        }
        if (temp.create_entities_fn == null) {
            temp.create_entities_fn = empty_ce;
        }
        temp.entites = std.ArrayList(*entity.Entity).init(allocator);
        temp.pw = comps.PhysicWorld.new(allocator);
        return temp;
    }

    pub fn add_entity(self: *Self, name: []const u8) !*entity.Entity {
        var temp = try entity.Entity.new(self.allocator, name);
        try self.entites.append(temp);
        return temp;
    }

    pub fn _destroy(self: *Self) void {
        self.pw.destroy();
        for (self.entites.items) |bru| {
            bru.destroy();
        }
        self.entites.deinit();
    }

    pub fn update(self: *Self, deltaTime: f64) void {
        self.pw.update();
        for (self.entites.items) |bru| {
            bru.update(deltaTime);
        }
    }

    pub fn render(self: *Self) void {
        for (self.entites.items) |bru| {
            bru.render();
        }
    }

    pub fn start(self: *Self) !void {
        try self.create_entities_fn.?(self);
        for (self.entites.items) |bru| {
            bru.start();
        }
    }

    pub fn destroy(self: *Self) void {
        _ = self.destroy_fn.?(self);
    }
};

pub const TestScene = struct {
    const Self = @This();

    scene: Scene,
    allocator: *std.mem.Allocator,

    pub fn new(allocator: *std.mem.Allocator) !*Self {
        var temp = try allocator.create(Self);
        temp.allocator = allocator;
        temp.scene = Scene.new(allocator, .{ create_entities, destroy });
        return temp;
    }
    pub fn create_entities(scene: *Scene) anyerror!void {
        var entity1 = try scene.add_entity("entity1");
        try entity1.add_component(comps.Transform, .{ 20, 20 });
        try entity1.add_component(comps.Collider, .{ &scene.pw, true });

        var entity2 = try scene.add_entity("entity2");
        try entity2.add_component(comps.BasicMovement, .{});
        try entity2.add_component(comps.Transform, .{ 500, 500 });
        try entity2.add_component(comps.SpriteRenderer, .{"assets/bruh.png"});
        try entity2.add_component(comps.Collider, .{ &scene.pw, false });
    }
    pub fn destroy(scene: *Scene) i32 {
        const self = @fieldParentPtr(TestScene, "scene", scene);

        scene._destroy();
        self.allocator.destroy(self);

        return 0;
    }
};
