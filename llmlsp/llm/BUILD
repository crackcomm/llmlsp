load("@io_bazel_rules_go//go:def.bzl", "go_library")

go_library(
    name = "llm",
    srcs = [
        "openai.go",
        "provider.go",
    ],
    importpath = "github.com/crackcomm/llmlsp/llmlsp/llm",
    visibility = ["//visibility:public"],
    deps = [
        "@com_github_pkg_errors//:errors",
        "@com_github_sashabaranov_go_openai//:go-openai",
    ],
)
