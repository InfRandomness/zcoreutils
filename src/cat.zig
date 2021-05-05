const std = @import("std");
const args = @import("args");
const io = std.io;
const heap = std.heap;
const math = std.math;

const stdout = io.getStdOut().writer();

pub fn main() !void {
    var argsAllocator = std.heap.page_allocator;
    const stdin = io.getStdIn().reader();

    const ops = try args.parseForCurrentProcess(struct {
        help: bool = false,

        pub const shorthands = .{
            .h = "help",
        };
    }, argsAllocator);
    defer ops.deinit();

    var gpa = heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    if (ops.positionals.len == 0) {
        var line = try stdin.readAllAlloc(&gpa.allocator, math.maxInt(usize));
        try stdout.print("{s}\n", .{line});
        gpa.allocator.free(line);
    } else {
        var filename = ops.positionals[ops.positionals.len - 1];
        if(std.fs.cwd().openFile(filename, .{ .read = true })) |file| {
            try fetchFileContent(file);
        } else |err| switch (err) {
            error.FileNotFound => try stdout.print("Could not find the file {s} \n", .{filename}),
            else => unreachable,
        }
    }
}

fn fetchFileContent(file: std.fs.File) !void {
    var buffer: [4096]u8 = undefined;
    while (true) {
        const len = try file.reader().read(&buffer);
        if (len == 0) break;
        try stdout.print("{s}", .{buffer[0..len]});
        // os.sendfile(1, file.handle, , in_len: u64, headers: []const iovec_const, trailers: []const iovec_const, flags: u32)
    }
}