"""Provides the repository macro to import from github."""

load("//third_party:http_archive.bzl", http_archive = "cx_http_archive")

def github_repo(*, org, repo, commit, **kwargs):
    http_archive(
        urls = [
            "https://github.com/{org}/{repo}/archive/{commit}.tar.gz".format(
                org = org,
                repo = repo,
                commit = commit,
            ),
        ],
        strip_prefix = "{repo}-{commit}".format(repo = repo, commit = commit),
        **kwargs
    )
