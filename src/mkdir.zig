const std = @import("std");
const build_options = @import("build_options");
const parse_helper = @import("helpers/parse.zig");
const io = std.io;
const os = std.os;
const stdout = io.getStdOut().writer();

pub fn main() !void {
    const ops = try parse_helper.parseArgs(struct {
        help: bool = false,

        // Options to tell the program there is multiple separators
        parents: bool = false,
        recursive: bool = false,

        verbose: bool = false,
        version: bool = false,

        pub const shorthands = .{ .h = "help", .r = "recursive", .p = "recursive", .v = "version", .V = "verbose" };
    });

    defer ops.deinit();

    if (ops.options.version) {
        try stdout.print("{s}\n", .{build_options.version});
        return;
    }

    if (ops.positionals.len < 1) {
        // TODO: make an intelligent help menu
        try stdout.print("Usage: {s} [OPTIONS] directory\n", .{ops.executable_name});
        return;
    }

    var path = ops.positionals[ops.positionals.len - 1];

    if (createDir(path, ops.options.recursive)) {
        if (ops.options.verbose or ops.options.recursive) try stdout.print("Created directory {s}\n", .{path});
    } else |err| switch (err) {
        error.FileNotFound => try stdout.print("Could not create the directory\n", .{}),
        error.PathAlreadyExists => try stdout.print("The directory already exists\n", .{}),
        else => unreachable,
    }
}

fn createDir(path: []const u8, recursive: bool) !void {
    if (recursive) {
        try std.fs.cwd().makePath(path);
    } else {
        try std.fs.cwd().makeDir(path);
    }
}
