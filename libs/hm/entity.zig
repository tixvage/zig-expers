const std = @import("std");
const print = std.debug.print;

pub const Entity = struct {
    const Self = @This();

    comps: std.ArrayList(*Component),
    allocator: *std.mem.Allocator,

    pub fn new(allocator: *std.mem.Allocator) !*Self {
        var temp = try allocator.create(Self);
        temp.comps = std.ArrayList(*Component).init(allocator);
        temp.allocator = allocator;
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
        temp.component.start();
        try self.comps.append(&temp.component);
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

pub const Test = struct {
    const Self = @This();
    component: Component,
    number: i32,
    pub fn new(allocator: *std.mem.Allocator, args: anytype) !*Self {
        var temp = try allocator.create(Self);
        temp.number = args.@"0";
        temp.component = Component.new(render, update, start, destroy);
        return temp;
    }

    pub fn render(comp: *Component) void {}
    pub fn update(comp: *Component, deltaTime: f64) void {}

    pub fn start(comp: *Component) void {
        const self = @fieldParentPtr(Test, "component", comp);
        self.number = 20;
        print("{}\n", .{self.number});
    }

    pub fn destroy(comp: *Component, allocator: *std.mem.Allocator) void {
        const self = @fieldParentPtr(Test, "component", comp);
        allocator.destroy(self);
    }
};
