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
        verbose: bool = false,

        pub const shorthands = .{
            .h = "help",
            .r = "recursive",
            .v = "verbose"
        };
    }, argsAllocator);
    defer ops.deinit();

    if (ops.positionals.len < 1) {
        // TODO: make an intelligent help menu
        try stdout.print("Usage {s} [OPTIONS] directory\n", .{ops.executable_name});
        return;
    }

    var path = ops.positionals[ops.positionals.len - 1];

    if(createDir(path, ops.options.recursive)) {
        if (ops.options.verbose) try stdout.print("Created directory {s}\n", .{path});
    } else |err| switch(err) {
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