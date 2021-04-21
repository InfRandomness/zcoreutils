const std = @import("std");
const args = @import("args");
const io = std.io;
const heap = std.heap;
const math = std.math;

pub fn main() !void {
    var argsAllocator = std.heap.page_allocator;
    const stdout = io.getStdOut().writer();
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
        var fileContent = try fetchFileContent(&gpa.allocator, ops.positionals[ops.positionals.len - 1]);
        try stdout.print("{s}\n", .{fileContent});
        gpa.allocator.free(fileContent);
    }
}

fn fetchFileContent(allocator: *std.mem.Allocator, path: []const u8) ![]u8 {
    const size = math.maxInt(usize);
    const file = try std.fs.cwd().openFile(path, .{ .read = true });
    defer file.close();
    return try file.reader().readAllAlloc(allocator, size);
}