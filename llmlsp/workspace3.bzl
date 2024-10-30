load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")
load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

def workspace():
    go_rules_dependencies()
    go_register_toolchains(version = "1.23.2")
    gazelle_dependencies()

llmlsp_workspace3 = workspace
