const std = @import("std");
const args = @import("args");

pub fn parseArgs(comptime Spec: type) !args.ParseArgsResult(Spec) {
    var errorCollectorGPA = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = errorCollectorGPA.deinit();

    var collection = args.ErrorCollection.init(&errorCollectorGPA.allocator);
    defer _ = collection.deinit();
    
    const ops = args.parseForCurrentProcess(Spec, std.heap.page_allocator, args.ErrorHandling{ .collect = &collection }) catch {
        for (collection.errors()) |err| {
            try std.io.getStdOut().writer().print("{}\n", .{err});
        }
        std.os.exit(1);
    };
    return ops;
}