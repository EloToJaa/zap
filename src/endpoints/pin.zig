const zap = @import("zap");

const User = @import("../models/user.zig").User;
const StatusCode = zap.StatusCode;

pub fn setPin(req: zap.Request) void {
    if (req.methodAsEnum() != .GET) {
        req.setStatus(StatusCode.method_not_allowed);
        req.sendBody("Method not allowed") catch return;
        return;
    }

    const user = User{
        .first_name = "PIN",
        .last_name = "123",
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
