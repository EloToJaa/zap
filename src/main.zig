const std = @import("std");
const zap = @import("zap");
const pin = @import("endpoints/pin.zig");

const StatusCode = zap.StatusCode;

fn notFound(req: zap.Request) void {
    std.log.info("not found handler\n", .{});

    req.setStatus(StatusCode.not_found);
    req.sendBody("Not found") catch return;
}

pub fn main() !void {
    const port = 3000;

    var gpa = std.heap.GeneralPurposeAllocator(.{
        .thread_safe = true,
    }){};
    const allocator = gpa.allocator();

    var router = zap.Router.init(allocator, .{
        .not_found = notFound,
    });
    defer router.deinit();

    try router.handle_func_unbound("/pin/set", pin.setPin);

    zap.enableDebugLog();

    var listener = zap.HttpListener.init(.{
        .port = port,
        .on_request = router.on_request_handler(),
        .log = true,
    });
    try listener.listen();

    std.log.info("Listening on 0.0.0.0:{}\n", .{port});

    zap.start(.{
        .threads = 2,
        .workers = 1, // user map cannot be shared among multiple worker processes
    });
}
