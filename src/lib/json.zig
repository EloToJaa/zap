const zap = @import("zap");

pub fn serialize(value: anytype, buf: []u8) ![]const u8 {
    if (zap.stringifyBuf(buf, value, .{})) |json| {
        return json;
    } else {
        return "null";
    }
}
