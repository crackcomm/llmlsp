load("@io_bazel_rules_go//go:def.bzl", "go_library")

go_library(
    name = "workspace",
    srcs = [
        "files.go",
        "workspace.go",
    ],
    importpath = "github.com/crackcomm/llmlsp/llmlsp/workspace",
    visibility = ["//visibility:public"],
    deps = [
        "//llmlsp/lsp/types",
        "//llmlsp/util",
        "@com_github_sourcegraph_go_lsp//:go-lsp",
    ],
)
