load("@io_bazel_rules_go//go:def.bzl", "go_library")

go_library(
    name = "server",
    srcs = ["server.go"],
    importpath = "github.com/crackcomm/llmlsp/llmlsp/server",
    visibility = ["//visibility:public"],
    deps = [
        "//llmlsp/lsp",
        "@com_github_sourcegraph_jsonrpc2//:jsonrpc2",
    ],
)
