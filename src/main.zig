const std = @import("std");
const zap = @import("zap");
const StatusCode = zap.StatusCode;

const User = struct {
    first_name: ?[]const u8 = null,
    last_name: ?[]const u8 = null,
};

fn on_request(req: zap.Request) void {
    if (req.methodAsEnum() != .POST) return;

    const user = User{
        .first_name = "John",
        .last_name = "Doe",
    };

    var buf: [100]u8 = undefined;
    var json_to_send: []const u8 = undefined;
    if (zap.stringifyBuf(&buf, user, .{})) |json| {
        json_to_send = json;
    } else {
        json_to_send = "null";
    }

    req.setContentType(.JSON) catch return;
    req.setStatus(StatusCode.ok);
    req.sendBody(json_to_send) catch return;
}

fn not_found(req: zap.Request) void {
    std.debug.print("not found handler", .{});

    req.setStatus(StatusCode.not_found);
    req.sendBody("Not found") catch return;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{
        .thread_safe = true,
    }){};
    const allocator = gpa.allocator();

    var router = zap.Router.init(allocator, .{
        .not_found = not_found,
    });
    defer router.deinit();

    try router.handle_func_unbound("/get/a", on_request);

    var listener = zap.HttpListener.init(.{
        .port = 3000,
        .on_request = on_request,
        .log = true,
    });
    zap.enableDebugLog();
    try listener.listen();

    std.debug.print("Listening on 0.0.0.0:3000\n", .{});

    // start worker threads
    zap.start(.{
        .threads = 2,
        .workers = 1, // user map cannot be shared among multiple worker processes
    });
}
