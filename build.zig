const std = @import("std");

const pkgs = struct {
    const hm = std.build.Pkg{
        .name = "hm",
        .path = "libs/hm/hm.zig", //.{ .path = "libs/hm/hm.zig" },
        .dependencies = &[_]std.build.Pkg{},
    };
};

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("zartzurt", "src/main.zig");
    exe.addPackage(pkgs.hm);
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.linkSystemLibrary("raylib");
    exe.linkSystemLibrary("wren");
    exe.linkLibC();
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
