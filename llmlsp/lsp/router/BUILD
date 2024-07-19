load("@io_bazel_rules_go//go:def.bzl", "go_library")

go_library(
    name = "router",
    srcs = ["router.go"],
    importpath = "github.com/crackcomm/llmlsp/llmlsp/lsp/router",
    visibility = ["//visibility:public"],
    deps = ["@com_github_sourcegraph_jsonrpc2//:jsonrpc2"],
)
