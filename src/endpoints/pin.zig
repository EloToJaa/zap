const zap = @import("zap");
const std = @import("std");
const json = @import("../lib/json.zig");

const User = @import("../models/user.zig").User;
const StatusCode = zap.StatusCode;

pub fn setPin(req: zap.Request) void {
    if (req.methodAsEnum() != .GET) {
        req.setStatus(StatusCode.method_not_allowed);
        req.sendBody("Method not allowed") catch return;
        return;
    }

    req.parseBody() catch return;
    const list = req.parametersToOwnedList(std.heap.page_allocator, true) catch return;
    const pin = list.items.ptr[0].value.?.String;
    defer pin.deinit();

    // var buf: [100]u8 = undefined;
    // const name = std.fmt.bufPrint(&buf, "{}", .{pin}) catch return;
    const user = User{
        .first_name = "PIN",
        .last_name = pin.str,
    };

    var buf: [100]u8 = undefined;
    const json_to_send = try json.serialize(user, &buf);

    req.setContentType(.JSON) catch return;
    req.setStatus(StatusCode.ok);
    req.sendBody(json_to_send) catch return;
}
