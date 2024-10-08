const std = @import("std");
const heap = std.heap;
const log = std.log;

const dprint = std.debug.print;

const api = @import("api.zig");
const rates = @import("rates.zig");
const util = @import("util.zig");
const bellmain = @import("bellman.zig");

pub fn main() !void {
    var gpa_aloc = heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa_aloc.deinit() == .leak) {
        log.warn("Memory leak detected.\n", .{});
    };
    const gpa = gpa_aloc.allocator();

    var req = api.FetchReq.init(gpa);
    defer req.deinit();

    const config = util.readConfigFile("conf.conf") catch {
        log.err("Failed to read config file.\n", .{});
        return;
    };

    // targets have to be a-z to match api res
    const targets = config.targets.items;
    std.sort.insertion([]const u8, targets, {}, util.compareStrings);
    dprint("Targets: {s}\n", .{targets});

    const res = try req.get(config.link, &.{});
    const body = try req.body.toOwnedSlice();
    defer req.allocator.free(body);

    if (res.status != .ok) {
        log.err("GET request failed - {s}\n", .{body});
        return;
    }

    var currency_rates = try rates.parse_json(gpa, body, targets);

    defer currency_rates.free(gpa);

    try bellmain.arbitrage(gpa, currency_rates);
}
