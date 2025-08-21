const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});
    _ = b.addModule("wav", .{
        .root_source_file = b.path("src/wav.zig"),
    });

    _ = b.addModule("sample", .{
        .root_source_file = b.path("src/sample.zig"),
    });

    const lib = b.addLibrary(.{
        .name = "zig-wav",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_module = b.createModule(.{ // this line was added
            .root_source_file = b.path("src/wav.zig"),
            .target = target,
            .optimize = optimize,
        }), // this line was added
    });

    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(lib);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const sample_unit_tests = b.addTest(.{
        .root_module = b.createModule(.{ // this line was added
            .root_source_file = b.path("src/sample.zig"),
            .target = target,
            .optimize = optimize,
        }), // this line was added
    });

    const wav_unit_tests = b.addTest(.{
        .root_module = b.createModule(.{ // this line was added
            .root_source_file = b.path("src/sample.zig"),
            .target = target,
            .optimize = optimize,
        }), // this line was added
    });

    const run_sample_unit_tests = b.addRunArtifact(sample_unit_tests);
    const run_wav_unit_tests = b.addRunArtifact(wav_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_wav_unit_tests.step);
    test_step.dependOn(&run_sample_unit_tests.step);
}
