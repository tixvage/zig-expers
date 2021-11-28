const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const hm = @import("hm");
const json = std.json;
const wren = @cImport(@cInclude("wren.h"));
const string = @cImport(@cInclude("string.h"));

const payload =
    \\{
    \\    "phone_number": 20,
    \\    "aa": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    \\}
;

const Person = struct {
    phone_number: i32,
    aa: []const u8,
};

fn writeFn(vm: ?*wren.WrenVM, text: [*c]const u8) callconv(.C) void {
    print("{s}", .{text});
}

fn mathAdd(vm: ?*wren.WrenVM) callconv(.C) void {
    var a = wren.wrenGetSlotDouble(vm, 1);
    var b = wren.wrenGetSlotDouble(vm, 2);
    wren.wrenSetSlotDouble(vm, 0, a + b);
}

fn empty(vm: ?*wren.WrenVM) callconv(.C) void {}

fn bindForeignMethod(vm: ?*wren.WrenVM, module: [*c]const u8, className: [*c]const u8, isStatic: bool, signature: [*c]const u8) callconv(.C) ?fn (?*wren.WrenVM) callconv(.C) void {
    if (string.strcmp(module, "main") == 0) {
        if (string.strcmp(className, "Math") == 0) {
            if (isStatic and string.strcmp(signature, "add(_,_)") == 0) {
                return mathAdd;
            }
        }
    }
    return empty;
}

pub fn main() !void {
    var config: ?wren.WrenConfiguration = wren.WrenConfiguration{ .bindForeignClassFn = null, .reallocateFn = null, .resolveModuleFn = null, .loadModuleFn = null, .bindForeignMethodFn = null, .writeFn = null, .errorFn = null, .initialHeapSize = 0, .minHeapSize = 0, .heapGrowthPercent = 0, .userData = null };
    wren.wrenInitConfiguration(&config.?);
    config.?.writeFn = writeFn;
    config.?.bindForeignMethodFn = bindForeignMethod;
    var vm: ?*wren.WrenVM = wren.wrenNewVM(&config.?);
    defer wren.wrenFreeVM(vm);

    var result: wren.WrenInterpretResult = wren.wrenInterpret(vm, "main", @embedFile("bruh.wren"));
    wren.wrenEnsureSlots(vm, 1);
    wren.wrenGetVariable(vm, "main", "GameEngine", 0);

    var gameEngineClass: ?*wren.WrenHandle = wren.wrenGetSlotHandle(vm, 0);
    var alo = wren.wrenMakeCallHandle(vm, "update(_)");
    wren.wrenSetSlotHandle(vm, 0, gameEngineClass);
    wren.wrenSetSlotDouble(vm, 1, 1000);
    _ = wren.wrenCall(vm, alo);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var stream = json.TokenStream.init(payload);
    const res = try json.parse(Person, &stream, .{ .allocator = &gpa.allocator });

    defer json.parseFree(Person, res, .{ .allocator = &gpa.allocator });

    var test_scene = try hm.scene.TestScene.new(&gpa.allocator);

    var game = hm.game.Game.new(&gpa.allocator);
    hm.game.change_scene(&test_scene.scene);
    try game.run();
}
