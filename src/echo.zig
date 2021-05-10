const std = @import("std");
const args = @import("args");
const build_options = @import("build_options");
const io = std.io;
const os = std.os;

pub fn main() !void {
    var argsAllocator = std.heap.page_allocator;
    const stdout = io.getStdOut().writer();
    const stdin = io.getStdIn().reader();

    const ops = try args.parseForCurrentProcess(struct {
        help: bool = false,
        version: bool = false,

        pub const shorthands = .{ .h = "help", .v = "version" };
    }, argsAllocator);
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
        try stdout.print("{s}\n", .{ops.positionals[0]});
    } else {
        for (ops.positionals) |string| {
            try stdout.print("{s} ", .{string});
        }
        try stdout.print("\n", .{});
    }
}
