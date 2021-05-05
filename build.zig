const std = @import("std");
const deps = @import("./deps.zig");
const writer = std.io.getStdOut.writer();

pub fn build(b: *std.build.Builder) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const src = std.fs.cwd().openDir("src", .{ .iterate = true }) catch |err| {
        _ = switch (err) {
            error.FileNotFound => std.debug.print("Directory has not been found.", .{}),
            else => std.debug.print("An error has occured", .{}),
        };
        return;
    };

    var iterator = src.iterate();
    while (try iterator.next()) |file| {
        const name = std.mem.tokenize(file.name, ".").next().?;

        var alloc_join = std.heap.GeneralPurposeAllocator(.{}){};
        defer _ = alloc_join.deinit();

        const path = try std.fs.path.join(&alloc_join.allocator, &[_][]const u8{ "src", file.name });
        const exe = b.addExecutable(name, path);
        alloc_join.allocator.free(path);
        exe.setTarget(target);
        exe.setBuildMode(mode);
        deps.addAllTo(exe);
        exe.install();
        const run = exe.run();
        run.step.dependOn(b.getInstallStep());
        if (b.args) |args| run.addArgs(args);

        const step = b.step(b.fmt("{s}: run", .{name}), b.fmt("Run {s}", .{name}));
        step.dependOn(&run.step);
    }
}
