workspace(name = "monorepo_llmlsp")

load("//llmlsp:repositories.bzl", "llmlsp_repositories")

llmlsp_repositories()

load("//llmlsp:workspace3.bzl", "llmlsp_workspace3")

llmlsp_workspace3()

# gazelle:repo bazel_gazelle
load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")
load("//third_party:go_deps.bzl", "go_dependencies")

# gazelle:repository_macro third_party/go_deps.bzl%go_dependencies
go_dependencies()

gazelle_dependencies()
