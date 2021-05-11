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
    const empty_iovec = [0]std.os.iovec_const{};
    var offset: u64 = 0;
    sendfile_loop: while (true) {
        const sendfile = try std.os.sendfile(std.os.STDOUT_FILENO, file.handle, offset, 0, &empty_iovec, &empty_iovec, 0);
        if (sendfile == 0) break :sendfile_loop;
        offset += sendfile;
    }
}
