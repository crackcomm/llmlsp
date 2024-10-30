load("@io_bazel_rules_go//go:def.bzl", "go_library")

go_library(
    name = "lsp",
    srcs = [
        "code_actions.go",
        "handler.go",
        "helpers.go",
        "lsp.go",
    ],
    importpath = "github.com/crackcomm/llmlsp/llmlsp/lsp",
    visibility = ["//visibility:public"],
    deps = [
        "//llmlsp/llm",
        "//llmlsp/lsp/router",
        "//llmlsp/lsp/types",
        "//llmlsp/util",
        "//llmlsp/workspace",
        "@com_github_google_uuid//:uuid",
        "@com_github_sourcegraph_go_lsp//:go-lsp",
        "@com_github_sourcegraph_jsonrpc2//:jsonrpc2",
    ],
)
