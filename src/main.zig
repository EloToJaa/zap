const std = @import("std");
const zap = @import("zap");
const StatusCode = zap.StatusCode;

const User = struct {
    first_name: ?[]const u8 = null,
    last_name: ?[]const u8 = null,
};

fn on_test(req: zap.Request) void {
    if (req.methodAsEnum() != .POST) {
        req.setStatus(StatusCode.method_not_allowed);
        req.sendBody("Method not allowed") catch return;
        return;
    }

    const user = User{
        .first_name = "John",
        .last_name = "Doe",
    };

    var buf: [512]u8 = undefined;
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

fn on_request(req: zap.Request) void {
    if (req.methodAsEnum() != .POST) {
        req.setStatus(StatusCode.method_not_allowed);
        req.sendBody("Method not allowed") catch return;
        return;
    }

    const user = User{
        .first_name = "Jan",
        .last_name = "Kowalski",
    };

    var buf: [512]u8 = undefined;
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
    std.debug.print("not found handler\n", .{});

    // req.setStatus(StatusCode.not_found);
    req.sendBody("Not found") catch return;
}

pub fn main() !void {
    const port = 3000;

    var gpa = std.heap.GeneralPurposeAllocator(.{
        .thread_safe = true,
    }){};
    const allocator = gpa.allocator();

    var router = zap.Router.init(allocator, .{
        .not_found = not_found,
    });
    defer router.deinit();

    try router.handle_func_unbound("/", on_request);
    try router.handle_func_unbound("/test", on_test);

    var listener = zap.HttpListener.init(.{
        .port = port,
        .on_request = router.on_request_handler(),
        .log = true,
    });
    zap.enableDebugLog();
    try listener.listen();

    std.debug.print("Listening on 0.0.0.0:{}\n", .{port});

    zap.start(.{
        .threads = 2,
        .workers = 1, // user map cannot be shared among multiple worker processes
    });
}
