# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

load(
    "//actions:actions.bzl",
    "zip_files",
)

def _generate_file_impl(ctx):
    ctx.actions.write(ctx.outputs.file, ctx.attr.contents)

generate_bin_file = rule(
    attrs = {
        "contents": attr.string(
            mandatory = True,
        ),
        "file": attr.output(
            mandatory = True,
        ),
    },
    implementation = _generate_file_impl,
    output_to_genfiles = False,
)

generate_gen_file = rule(
    attrs = {
        "contents": attr.string(
            mandatory = True,
        ),
        "file": attr.output(
            mandatory = True,
        ),
    },
    implementation = _generate_file_impl,
    output_to_genfiles = True,
)

def zip_files_impl(ctx):
    zip_files(
        ctx,
        ctx.executable._zip_script,
        ctx.files.srcs,
        ctx.outputs.zip,
        ctx.attr.strip_prefixes,
    )

def _zip_runfiles_impl(ctx):
    ctx.actions.run(
        mnemonic = "ZipPyRunfiles",
        arguments = [
                        "--output",
                        ctx.outputs.zip.path,
                    ] +
                    [
                        "--ignore-files",
                        ctx.executable.binary.path,
                        ctx.attr.binary.files_to_run.executable.path,
                    ],
        tools = [ctx.executable.binary],
        executable = ctx.executable.binary,
        outputs = [ctx.outputs.zip],
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
