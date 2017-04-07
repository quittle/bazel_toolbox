# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

load("//labels:labels.bzl",
    "executable_label",
)

load(":internal.bzl",
    "zip_files_impl",
)

zip_files = rule(
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
        ),
        "strip_prefixes": attr.string_list(),
        "_zip_script": executable_label(Label("//actions:zip_files")),
    },
    outputs = {
        "zip": "%{name}.zip",
    },
    implementation = zip_files_impl,
)
