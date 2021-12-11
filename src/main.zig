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
