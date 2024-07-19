load("@bazel_gazelle//:def.bzl", "gazelle")

exports_files([
    "go.mod",
    "go.sum",
])

filegroup(
    name = "srcs",
    srcs = glob(
        ["*"],
        exclude = [
            "WORKSPACE.bzlmod",  # Needs to be filtered.
            "bazel-*",  # convenience symlinks
            "out",  # IntelliJ with setup-intellij.sh
            ".*",  # mainly .git* files
            "usr",  # private user scripts
        ],
    ) + [
        ".bazelignore",
        ".bazelrc",
        ".bazelversion",
    ],
    visibility = ["//visibility:private"],
)

# gazelle:prefix github.com/crackcomm/llmlsp
gazelle(name = "gazelle")

gazelle(
    name = "gazelle-update-repos",
    args = [
        "-from_file=go.mod",
        "-to_macro=third_party/go_deps.bzl%go_dependencies",
        "-prune",
    ],
    command = "update-repos",
)
