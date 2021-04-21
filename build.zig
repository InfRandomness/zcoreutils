const std = @import("std");
const writer = std.io.getStdOut.writer();

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    var src: std.fs.Dir = undefined;

    //TODO: Found a way to iterate over every files in that src/ directory
    // if(std.fs.cwd().openDir("src/", .{ .iterate = true })) |dir| {
    //     src = dir;
    //     defer src.close();
    // } else |err| switch(err) {
    //     std.fs.Dir.OpenError.FileNotFound => {
    //         std.debug.print("Directory has not been found.", .{});
    //     },
    //     else => {
    //         std.debug.print("An error has occured", .{});
    //     }
    // }
    
    // while(src.iterate().next()) |file| {
    //     // TODO: Find the best way to hand the error in the while loop
    //     std.debug.print(file);
    // }

    const cat = b.addExecutable("cat", "src/cat.zig");
    cat.setTarget(target);
    cat.setBuildMode(mode);
    cat.addPackagePath("args", "libs/zig-args/args.zig");
    cat.install();
    const run_cat = cat.run();
    
    const mkdir = b.addExecutable("mkdir", "src/mkdir.zig");
    mkdir.setTarget(target);
    mkdir.setBuildMode(mode);
    mkdir.addPackagePath("args", "libs/zig-args/args.zig");
    mkdir.install();
    const run_mkdir = mkdir.run();

    run_cat.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cat.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cat.step);
}
