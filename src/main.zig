const std = @import("std");
const webui = @import("webui");

pub fn main() !void {
    var win = webui.newWindow();
    _ = win.setRootFolder("frontend");
    // _ = win.show("main/index.html");
    _ = win.showBrowser("main/index.html", .Firefox);
    webui.wait();
}
