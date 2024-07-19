load("@io_bazel_rules_go//go:def.bzl", "go_library")

go_library(
    name = "types",
    srcs = ["types.go"],
    importpath = "github.com/crackcomm/llmlsp/llmlsp/lsp/types",
    visibility = ["//visibility:public"],
    deps = [
        "//llmlsp/llm",
        "@com_github_sourcegraph_go_lsp//:go-lsp",
    ],
)
