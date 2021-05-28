const std = @import("std");
const build_options = @import("build_options");
const parse_helper = @import("helpers/parse.zig");
const io = std.io;
const os = std.os;
const stdout = io.getStdOut().writer();

pub fn main() !void {
    const ops = try parse_helper.parseArgs(struct {
        help: bool = false,
        newline: bool = false,
        version: bool = false,

        pub const shorthands = .{ .h = "help", .v = "version", .n = "newline" };
    });

    defer ops.deinit();

    if (ops.options.version) {
        try stdout.print("{s}\n", .{build_options.version});
        return;
    }

    if (ops.positionals.len < 1) {
        // TODO: make an intelligent help menu
        try stdout.print("Usage: {s} text\n", .{ops.executable_name});
        return;
    }

    if (ops.positionals.len == 1) {
        try stdout.print("{s}", .{ops.positionals[0]});
    } else {
        for (ops.positionals) |string| {
            try stdout.print("{s} ", .{string});
        }
    }
    if (!ops.options.newline) try stdout.print("\n", .{});
}
