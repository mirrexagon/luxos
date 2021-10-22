const std = @import("std");

export fn isdigit(ch: c_int) c_int {
    if (ch >= '0' and ch <= '9') {
        return 1;
    } else {
        return 0;
    }
}
