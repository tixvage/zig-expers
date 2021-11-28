const std = @import("std");
const print = std.debug.print;
const rl = @import("rl.zig");

pub const Entity = struct {
    const Self = @This();

    comps: std.ArrayList(*Component),
    allocator: *std.mem.Allocator,
    name: []const u8,

    pub fn new(allocator: *std.mem.Allocator, name: []const u8) !*Self {
        var temp = try allocator.create(Self);
        temp.comps = std.ArrayList(*Component).init(allocator);
        temp.allocator = allocator;
        temp.name = name;
        return temp;
    }

    pub fn destroy(self: *Self) void {
        for (self.comps.items) |comp| {
            comp.destroy(self.allocator);
        }
        self.comps.deinit();
        self.allocator.destroy(self);
    }

    pub fn add_component(self: *Self, comptime T: type, args: anytype) !void {
        var temp = try T.new(self.allocator, args);
        try self.comps.append(&temp.component);
    }

    pub fn start(self: *Self) void {
        for (self.comps.items) |comp| {
            comp.start();
        }
    }

    pub fn update(self: *Self, deltaTime: f64) void {
        for (self.comps.items) |comp| {
            comp.update(deltaTime);
        }
    }

    pub fn render(self: *Self) void {
        for (self.comps.items) |comp| {
            comp.render();
        }
    }
};

pub const Component = struct {
    renderFn: fn (self: *Component) void,
    updateFn: fn (self: *Component, deltaTime: f64) void,
    startFn: fn (self: *Component) void,
    destroyFn: fn (self: *Component, allocator: *std.mem.Allocator) void,

    pub fn new(renderFn: fn (self: *Component) void, updateFn: fn (self: *Component, deltaTime: f64) void, startFn: fn (self: *Component) void, destroyFn: fn (self: *Component, allocator: *std.mem.Allocator) void) Component {
        return Component{ .renderFn = renderFn, .updateFn = updateFn, .startFn = startFn, .destroyFn = destroyFn };
    }

    pub fn start(self: *Component) void {
        self.startFn(self);
    }
    pub fn update(self: *Component, deltaTime: f64) void {
        self.updateFn(self, deltaTime);
    }
    pub fn render(self: *Component) void {
        self.renderFn(self);
    }
    pub fn destroy(self: *Component, allocator: *std.mem.Allocator) void {
        self.destroyFn(self, allocator);
    }
};

pub const TestComponent = struct {
    const Self = @This();

    component: Component,

    number: i32,
    pos: rl.Vector2,

    pub fn new(allocator: *std.mem.Allocator, args: anytype) !*Self {
        var temp = try allocator.create(Self);
        temp.number = args.@"0";
        temp.pos.x = args.@"0";
        temp.pos.y = args.@"1";
        temp.component = Component.new(render, update, start, destroy);
        return temp;
    }

    pub fn render(comp: *Component) void {
        const self = @fieldParentPtr(TestComponent, "component", comp);
        rl.DrawRectangleV(self.pos, rl.Vector2{ .x = 20, .y = 20 }, rl.BLUE);
    }
    pub fn update(comp: *Component, deltaTime: f64) void {
        const self = @fieldParentPtr(TestComponent, "component", comp);

        if (rl.IsKeyDown(rl.KEY_UP)) {
            self.pos.AddF(0, -(200.0 * @floatCast(f32, deltaTime)));
        } else if (rl.IsKeyDown(rl.KEY_DOWN)) {
            self.pos.AddF(0, 200.0 * @floatCast(f32, deltaTime));
        }

        if (rl.IsKeyDown(rl.KEY_LEFT)) {
            self.pos.AddF(-(200.0 * @floatCast(f32, deltaTime)), 0);
        } else if (rl.IsKeyDown(rl.KEY_RIGHT)) {
            self.pos.AddF(200.0 * @floatCast(f32, deltaTime), 0);
        }
    }

    pub fn start(comp: *Component) void {
        const self = @fieldParentPtr(TestComponent, "component", comp);
        //print("hello world\n", .{});
        self.number = 20;
    }

    pub fn destroy(comp: *Component, allocator: *std.mem.Allocator) void {
        const self = @fieldParentPtr(TestComponent, "component", comp);
        allocator.destroy(self);
    }
};
