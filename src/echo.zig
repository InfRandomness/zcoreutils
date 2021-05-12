const std = @import("std");
const args = @import("args");
const build_options = @import("build_options");
const io = std.io;
const os = std.os;
const stdout = io.getStdOut().writer();

pub fn main() !void {
    var errorCollectorGPA = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = errorCollectorGPA.deinit();
    var collection = args.ErrorCollection.init(&errorCollectorGPA.allocator);
    defer _ = collection.deinit();

    var argsAllocator = std.heap.page_allocator;
    const ops = args.parseForCurrentProcess(struct {
        help: bool = false,
        version: bool = false,

        pub const shorthands = .{ .h = "help", .v = "version" };
    }, argsAllocator, args.ErrorHandling{ .collect = &collection }) catch {
        for (collection.errors()) |err| {
            try stdout.print("{}\n", .{err});
        }
        return;
    };
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
