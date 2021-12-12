//DONT EDIT THIS FILE (AUTO GENERATED with clicker_game_scene.hm)
const std = @import("std");
const hm = @import("hm");
const comps = @import("clicker_game_comps.zig");
pub const clicker_gameplay = struct {
    const Self = @This();
    scene: hm.scene.Scene,
    allocator: *std.mem.Allocator,
    pub fn new(allocator: *std.mem.Allocator) !*Self {
        var temp = try allocator.create(Self);
        temp.allocator = allocator;
        temp.scene = hm.scene.Scene.new(allocator, .{ create_entities, destroy });
        return temp;
    }
    pub fn create_entities(scene: *hm.scene.Scene) anyerror!void {
        var circle_manager = try scene.add_entity("circle_manager");
        try circle_manager.add_component(comps.RandomCircleManager, .{});
    }

    pub fn destroy(scene: *hm.scene.Scene) i32 {
        const self = @fieldParentPtr(clicker_gameplay, "scene", scene);
        scene._destroy();
        self.allocator.destroy(self);
        return 0;
    }
};
