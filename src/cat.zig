const std = @import("std");
const args = @import("args");
const build_options = @import("build_options");
const io = std.io;
const heap = std.heap;
const math = std.math;
const stdout = io.getStdOut().writer();

pub fn main() !void {
    var argsAllocator = std.heap.page_allocator;
    const stdin = io.getStdIn().reader();

    const ops = try args.parseForCurrentProcess(struct {
        help: bool = false,
        version: bool = false,

        pub const shorthands = .{
            .h = "help",
        };
    }, argsAllocator);
    defer ops.deinit();

    if (ops.options.version) {
        try stdout.print("{s}\n", .{build_options.version});
        return;
    }

    var gpa = heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    if (ops.positionals.len == 0) {
        var line = try stdin.readAllAlloc(&gpa.allocator, math.maxInt(usize));
        try stdout.print("{s}\n", .{line});
        gpa.allocator.free(line);
    } else {
        var filename = ops.positionals[ops.positionals.len - 1];
        if (std.fs.cwd().openFile(filename, .{ .read = true })) |file| {
            defer file.close();
            try printFileContent(file);
        } else |err| switch (err) {
            error.FileNotFound => try stdout.print("Could not find the file {s} \n", .{filename}),
            else => unreachable,
        }
    }
}

fn printFileContent(file: std.fs.File) !void {
    var stat = try file.stat();
    var result = try std.os.mmap(null, stat.size, std.os.PROT_READ, std.os.MAP_PRIVATE, file.handle, 0);
    try stdout.print("{s}\n", .{result});
}
