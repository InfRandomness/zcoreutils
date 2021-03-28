const std = @import("std");
const args = @import("args");
const fs = std.fs;
const os = std.os;
const target = std.Target;
const File = fs.File;
const heap = std.heap;
const io = std.io;

pub fn main() !void {
    var argsAllocator = heap.page_allocator;
    var fileContent: []u8 = undefined;
    const stdout = io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();

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
            var line = try stdin.readAllAlloc(&gpa.allocator, std.math.maxInt(usize));
            try stdout.print("{s}\n", .{line});
            gpa.allocator.free(line);
    } else {
        fileContent = try fetch_file_content(&gpa.allocator, ops.positionals[ops.positionals.len - 1]);
        //try stdout.writer().print("filename = {s}", .{ops.positionals[ops.positionals.len]});
        try stdout.print("{s}\n", .{fileContent});
        gpa.allocator.free(fileContent);
    }
}

fn fetch_file_content(allocator: *std.mem.Allocator, path: []const u8) ![]u8 {
    const size = std.math.maxInt(usize);
    const file = try std.fs.cwd().openFile(path, .{ .read = true });
    defer file.close();
    return try file.reader().readAllAlloc(allocator, size);
}