const std = @import("std");
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
        _ = switch(err) {
            error.FileNotFound => std.debug.print("Directory has not been found.", .{}),
            else => std.debug.print("An error has occured", .{}),
        };
        return;
    };

    var alloc_print = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = alloc_print.deinit();

    var iterator = src.iterate();
    while (try iterator.next()) |file| {
        var token = std.mem.tokenize(file.name, ".");
        const name = token.next();

        var alloc_join = std.heap.GeneralPurposeAllocator(.{}){};
        defer _ = alloc_join.deinit();
        
        const path = try std.fs.path.join(&alloc_join.allocator, &[_][]const u8{"src", file.name});
        const exe = b.addExecutable(file.name, path);
        alloc_join.allocator.free(path);
        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.addPackagePath("args", "libs/zig-args/args.zig");
        exe.install();
        const run = exe.run();
        run.step.dependOn(b.getInstallStep());
        if (b.args) |args| run.addArgs(args);

        const name_alloc = try std.fmt.allocPrint(&alloc_print.allocator, "{s}: run", .{ name });
        const description_alloc = try std.fmt.allocPrint(&alloc_print.allocator, "Run {s}", .{ name });
        const step = b.step(name_alloc, description_alloc);
        alloc_print.allocator.free(name_alloc);
        alloc_print.allocator.free(description_alloc);
        step.dependOn(&run.step);
    }
}
