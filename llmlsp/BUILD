load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library")

go_library(
    name = "llmlsp_lib",
    srcs = ["main.go"],
    importpath = "github.com/crackcomm/llmlsp/llmlsp",
    visibility = ["//visibility:private"],
    deps = [
        "//llmlsp/lsp",
        "//llmlsp/server",
        "@com_github_alecthomas_kong//:kong",
    ],
)

go_binary(
    name = "llmlsp",
    embed = [":llmlsp_lib"],
    visibility = ["//visibility:public"],
)
