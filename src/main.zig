const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const hm = @import("hm");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = std.heap.c_allocator;

    var test_scene = try hm.scene.TestScene.new(&gpa.allocator);
    var game = hm.game.Game.new(&gpa.allocator);
    hm.game.change_scene(&test_scene.scene);
    try game.run();
}

////line 1
//const comps = @import("hm");
//
////line 2
//const Gameplay = struct{
//    const Self = @This();
//
//    scene: Scene,
//    allocator: *std.mem.Allocator,
//
//    pub fn new(allocator: *std.mem.Allocator) !*Self {
//        var temp = try allocator.create(Self);
//        temp.allocator = allocator;
//        temp.scene = Scene.new(allocator, .{ create_entities, destroy });
//        return temp;
//    }
//    pub fn create_entities(scene: *Scene) anyerror!void {
//        //line 3
//        var player = try scene.add_entity("player");
//
//        //line 4
//        try player.add_component(comps.Transform, .{ 500, 500 });
//    }
//    pub fn destroy(scene: *Scene) i32 {
//        const self = @fieldParentPtr(TestScene, "scene", scene);
//
//        scene._destroy();
//        self.allocator.destroy(self);
//
//        return 0;
//    }
//};
//
