const std = @import("std");
const args = @import("args");
const io = std.io;
const os = std.os;

pub fn main() !void {
    var argsAllocator = std.heap.page_allocator;
    const stdout = io.getStdOut().writer();
    const stdin = io.getStdIn().reader();

    const ops = try args.parseForCurrentProcess(struct {
        help: bool = false,
        recursive: bool = false,

        pub const shorthands = .{
            .h = "help",
            .r = "recursive"
        };
    }, argsAllocator);
    defer ops.deinit();

    if (ops.positionals.len < 1) {
        // TODO: make an intelligent help menu
        try stdout.print("Usage {s} [OPTIONS] directory", .{ops.executable_name});
        return;
    }

    var path = ops.positionals[ops.positionals.len - 1];

    if (ops.options.recursive) {
        try std.fs.cwd().makePath(path);
    } else {
        std.fs.cwd().makeDir(path) catch |err| {
            _ = switch (err) {
                error.FileNotFound => try stdout.print("Could not create the directory\n", .{}),
                error.PathAlreadyExists => try stdout.print("The directory already exists\n", .{}),
                else => unreachable
            };
        };
    }
}