const std = @import("std");
const heap = std.heap;
const log = std.log;
const debug = std.debug;

const api = @import("api.zig");
const parser = @import("parser.zig");
const util = @import("util.zig");

pub fn main() !void {
    var gpa_aloc = heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa_aloc.deinit() == .leak) {
        log.warn("Memory leak detected.\n", .{});
    };
    const gpa = gpa_aloc.allocator();

    var req = api.FetchReq.init(gpa);
    defer req.deinit();

    const url_str = util.readConfigFile("conf.conf") catch {
        log.err("Failed to read config file.\n", .{});
        return;
    };

    debug.print("URL: |{s}|\n", .{url_str}); // Debug

    const res = try req.get(url_str, &.{});
    const body = try req.body.toOwnedSlice();
    defer req.allocator.free(body);

    if (res.status != .ok) {
        log.err("GET request failed - {s}\n", .{body});
        return;
    }

    //debug.print("Raw JSON: {s}\n", .{body}); // Debug

    const rates = try parser.parse_json(body);
    defer rates.deinit();

    for (rates.items) |rate| {
        debug.print("Name: {s} Rate: {d}\n", .{ rate.name, rate.rate });
    }
}
