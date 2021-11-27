const entity = @import("entity.zig");
const std = @import("std");
const print = std.debug.print;

pub const Scene = struct {
    const Self = @This();

    create_entities_fn: fn (self: *Self) anyerror!void = undefined,
    update_fn: fn (self: *Self, deltaTime: f32) void = undefined,
    entites: std.ArrayList(*entity.Entity),
    allocator: *std.mem.Allocator,

    fn empyt_update(self: *Self, deltaTime: f32) void {}

    pub fn new(allocator: *std.mem.Allocator, args: anytype) Self {
        var temp: Self = undefined;
        temp.allocator = allocator;
        inline for (args) |arg, i| {
            switch (@TypeOf(arg)) {
                fn (*Scene) anyerror!void => {
                    print("create_entities found\n", .{});
                    temp.create_entities_fn = arg;
                },
                fn (*Scene, f32) void => {
                    print("update found\n", .{});
                    temp.update_fn = arg;
                },
                else => {
                    print("WTF is that function {}\n", .{arg});
                    @panic("Wrong function type");
                },
            }
        }
        if (temp.update_fn == undefined) {
            temp.update_fn = empyt_update;
        }
        temp.entites = std.ArrayList(*entity.Entity).init(allocator);

        return temp;
    }

    pub fn add_entity(self: *Self, name: []const u8) !*entity.Entity {
        var temp = try entity.Entity.new(self.allocator, name);
        try self.entites.append(temp);
        return temp;
    }

    pub fn destroy(self: *Self) void {
        for (self.entites.items) |bru| {
            bru.destroy();
        }
        self.entites.deinit();
    }

    pub fn update(self: *Self, deltaTime: f64) void {
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
        try self.create_entities_fn(self);
        for (self.entites.items) |bru| {
            bru.start();
        }
    }
};

pub const TestScene = struct {
    const Self = @This();

    scene: Scene,
    allocator: *std.mem.Allocator,

    pub fn new(allocator: *std.mem.Allocator) !*Self {
        var temp = try allocator.create(Self);
        temp.allocator = allocator;
        temp.scene = Scene.new(allocator, .{create_entities});
        return temp;
    }
    pub fn create_entities(scene: *Scene) anyerror!void {
        var entity1 = try scene.add_entity("entity1");
        try entity1.add_component(entity.TestComponent, .{5});
    }
    pub fn destroy(self: *Self) void {
        self.scene.destroy();
        self.allocator.destroy(self);
    }
};
