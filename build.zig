const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "iron_lung",
        .root_module = exe_mod,
    });

    const zig_webui = b.dependency("zig_webui", .{
        .target = target,
        .optimize = optimize,
        .enable_tls = false, // whether enable tls support
        .is_static = true, // whether static link
    });
    exe.root_module.addImport("webui", zig_webui.module("webui"));

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const compile_scss_cmd = b.addSystemCommand(&[_][]const u8{ "sass", "frontend/styles/styles.scss", "frontend/styles/styles.css" });

    const compile_scss = b.step("scss", "Compile Scss");
    compile_scss.dependOn(&compile_scss_cmd.step);

    const run_zig_step = b.step("run-zig", "Run the backend.");
    run_zig_step.dependOn(&run_cmd.step);

    const run_full_step = b.step("run-full", "Run the app.");
    run_full_step.dependOn(compile_scss);
    run_full_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
