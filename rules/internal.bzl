# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

load("//actions:actions.bzl",
    "zip_files",
)

def zip_files_impl(ctx):
    zip_files(ctx, ctx.executable._zip_script, ctx.files.srcs, ctx.outputs.zip,
            ctx.attr.strip_prefixes)

def _zip_runfiles_impl(ctx):
    ctx.action(
        mnemonic = "ZipPyRunfiles",
        arguments = [
            "--output", ctx.outputs.zip.path,
        ] +
            [ "--ignore-files",
                ctx.executable.binary.path,
                ctx.attr.binary.files_to_run.executable.path,
            ],
        executable = ctx.executable.binary,
        outputs = [ ctx.outputs.zip, ],
    )

zip_runfiles_rule = rule(
    attrs = {
        "binary": attr.label(
            mandatory = True,
            cfg = "host",
            executable = True,
        ),
    },
    outputs = {
        "zip": "%{name}__runfiles.zip",
    },
    implementation = _zip_runfiles_impl,
)
