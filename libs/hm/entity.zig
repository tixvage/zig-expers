const std = @import("std");
const print = std.debug.print;
const rl = @import("rl.zig");

pub const Entity = struct {
    const Self = @This();

    comps: std.ArrayList(*Component),
    comps_types: std.ArrayList([]const u8),
    allocator: *std.mem.Allocator,
    name: []const u8,

    pub fn new(allocator: *std.mem.Allocator, name: []const u8) !*Self {
        var temp = try allocator.create(Self);
        temp.comps_types = std.ArrayList([]const u8).init(allocator);
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
        self.comps_types.deinit();
        self.allocator.destroy(self);
    }

    pub fn add_component(self: *Self, comptime T: type, args: anytype) !void {
        var temp = try T.new(self.allocator, args);
        temp.component.entity = self;
        try self.comps.append(&temp.component);
        try self.comps_types.append(@typeName(T));
    }

    pub fn get_component(self: *Self, comptime T: type) ?*T {
        for (self.comps.items) |comp, i| {
            if (std.mem.eql(u8, @typeName(T), self.comps_types.items[i])) {
                return @fieldParentPtr(T, "component", comp);
            }
        }
        print("{} can not found on {s} entity", .{ T, self.name });
        return null;
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
    entity: ?*Entity,

    renderFn: fn (self: *Component) void,
    updateFn: fn (self: *Component, deltaTime: f64) void,
    startFn: fn (self: *Component) void,
    destroyFn: fn (self: *Component, allocator: *std.mem.Allocator) void,

    pub fn new(renderFn: fn (self: *Component) void, updateFn: fn (self: *Component, deltaTime: f64) void, startFn: fn (self: *Component) void, destroyFn: fn (self: *Component, allocator: *std.mem.Allocator) void) Component {
        return Component{ .entity = null, .renderFn = renderFn, .updateFn = updateFn, .startFn = startFn, .destroyFn = destroyFn };
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
        rl.DrawRectangleV(self.pos, rl.Vector2{ .x = 200, .y = 200 }, rl.BLUE);
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
        self.number = 20;
    }

    pub fn destroy(comp: *Component, allocator: *std.mem.Allocator) void {
        const self = @fieldParentPtr(TestComponent, "component", comp);
        allocator.destroy(self);
    }
};

pub const TestComponent2 = struct {
    const Self = @This();

    component: Component,

    pub fn new(allocator: *std.mem.Allocator, args: anytype) !*Self {
        var temp = try allocator.create(Self);
        temp.component = Component.new(render, update, start, destroy);
        return temp;
    }

    pub fn render(comp: *Component) void {
        const self = @fieldParentPtr(TestComponent2, "component", comp);
    }
    pub fn update(comp: *Component, deltaTime: f64) void {
        const self = @fieldParentPtr(TestComponent2, "component", comp);
    }

    pub fn start(comp: *Component) void {
        const self = @fieldParentPtr(TestComponent2, "component", comp);
    }

    pub fn destroy(comp: *Component, allocator: *std.mem.Allocator) void {
        const self = @fieldParentPtr(TestComponent2, "component", comp);
        allocator.destroy(self);
    }
};

pub const Template = struct {
    const Self = @This();

    component: Component,

    pub fn new(allocator: *std.mem.Allocator, args: anytype) !*Self {
        var temp = try allocator.create(Self);
        temp.component = Component.new(render, update, start, destroy);
        return temp;
    }

    pub fn render(comp: *Component) void {
        const self = @fieldParentPtr(Template, "component", comp);
    }
    pub fn update(comp: *Component, deltaTime: f64) void {
        const self = @fieldParentPtr(Template, "component", comp);
    }

    pub fn start(comp: *Component) void {
        const self = @fieldParentPtr(Template, "component", comp);
    }

    pub fn destroy(comp: *Component, allocator: *std.mem.Allocator) void {
        const self = @fieldParentPtr(Template, "component", comp);
        allocator.destroy(self);
    }
};
