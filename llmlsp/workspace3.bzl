load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

def workspace():
    go_rules_dependencies()
    go_register_toolchains(version = "1.20")

llmlsp_workspace3 = workspace
