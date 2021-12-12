const std = @import("std");
const print = std.debug.print;
const hm = @import("hm");
const main_scene = @import("clicker_game_scene.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = std.heap.c_allocator;

    var test_scene = try main_scene.clicker_gameplay.new(&gpa.allocator);
    var game = hm.game.Game.new(&gpa.allocator);
    hm.game.change_scene(&test_scene.scene);
    try game.run();
}
