"""Provides http_archive rule with `patch_files`, `link_files` and `write_files`."""

# This is modified TensorFlow rule.

def _http_archive(ctx):
    """Extracts a http archive."""
    # For some reason, we need to "resolve" labels once before the
    # download_and_extract otherwise it'll invalidate and re-download the
    # archive each time.
    # https://github.com/bazelbuild/bazel/issues/10515

    # Construct all paths early on to prevent rule restart. We want the
    # attributes to be strings instead of labels because they refer to files
    # in the TensorFlow repository, not files in repos depending on TensorFlow.
    # See also https://github.com/bazelbuild/bazel/issues/10515.
    link_dict = {ctx.path(v): ctx.path(k) for k, v in ctx.attr.link_files.items()}

    standard_symlinks = {
        "BUILD.bazel": ctx.attr.build_file,
        "WORKSPACE": ctx.attr.workspace_file,
    }

    # Iterate over standard_symlinks and link under expected destinations.
    link_dict.update({ctx.path(k): ctx.path(v) for k, v in standard_symlinks.items() if v})

    # Resolve `write_files` labels to paths.
    write_files = {ctx.path(k): v for k, v in ctx.attr.write_files.items()}

    # Resolve paths to `patch_files`.
    patch_files = [ctx.path(patch_file) for patch_file in ctx.attr.patch_files if patch_file]

    for sha256, patch_url in ctx.attr.patch_urls.items():
        ctx.download(
            url = patch_url,
            sha256 = sha256,
            output = "{}.patch".format(sha256),
        )

    ctx.download_and_extract(
        url = ctx.attr.urls,
        sha256 = ctx.attr.sha256,
        stripPrefix = ctx.attr.strip_prefix,
        type = ctx.attr.type,
    )

    # apply existing patches
    for patch_file in patch_files:
        ctx.patch(patch_file, strip = 1)

    # apply patches from urls
    for sha256 in ctx.attr.patch_urls.keys():
        patch_file = "{}.patch".format(sha256)
        ctx.patch(patch_file, strip = 1)

    # link files
    for dst, src in link_dict.items():
        ctx.delete(dst)
        ctx.symlink(src, dst)

    # write files
    for dst, content in write_files.items():
        ctx.file(dst, content)

    # run commands
    for cmd in ctx.attr.commands:
        cmd = cmd.strip()
        exec_res = ctx.execute([
            "bash",
            "-c",
            cmd,
        ])
        if exec_res.return_code != 0:
            fail("Command {cmd} failed with return code {return_code} stdout: {stdout} stderr: {stderr}.".format(
                cmd = cmd,
                return_code = exec_res.return_code,
                stdout = exec_res.stdout,
                stderr = exec_res.stderr,
            ))

_http_archive_rule = repository_rule(
    implementation = _http_archive,
    attrs = {
        "urls": attr.string_list(mandatory = True),
        "sha256": attr.string(),
        "strip_prefix": attr.string(),
        "type": attr.string(),
        "build_file": attr.label(),
        "workspace_file": attr.label(),
        "link_files": attr.label_keyed_string_dict(),
        "patch_urls": attr.string_dict(doc = "Patch urls with `sha256` as key."),
        "patch_files": attr.label_list(),
        "write_files": attr.string_dict(),
        "commands": attr.string_list(),
    },
)

def cx_http_archive(*, name, **kwargs):
    if native.existing_rule(name):
        print("\n\033[1;33mWarning:\033[0m skipping import of repository '" +
              name + "' because it already exists.\n")
        return

    _http_archive_rule(
        name = name,
        **kwargs
    )
