# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

load("//actions:actions.bzl",
    "zip_files",
)

def zip_files_impl(ctx):
    zip_files(ctx, ctx.executable._zip_script, ctx.files.srcs, ctx.outputs.zip,
            ctx.attr.strip_prefixes)
