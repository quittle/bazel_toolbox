# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

load("//collections:collections.bzl",
    "simple_dict",
    "struct_to_dict",
)

load("//labels:labels.bzl",
    "executable_label",
)

def _assert_files_equal_impl(ctx):
    ctx.action(
        mnemonic = "AssertingFilesAreEqual",
        arguments = [
            "--files", ctx.file.expected_file.path, ctx.file.actual_file.path,
            "--stamp", ctx.outputs.stamp_file.path,
        ],
        inputs = [
            ctx.executable._assert_files_equal,
            ctx.file.expected_file,
            ctx.file.actual_file,
        ],
        executable = ctx.executable._assert_files_equal,
        outputs = [ ctx.outputs.stamp_file ]
    )

assert_files_equal_rule = rule(
    attrs = {
        "expected_file": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        "actual_file": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        "_assert_files_equal": executable_label("//assert:assert_equal",
                                                relative_to_caller_repository=False),
    },
    outputs = {
        "stamp_file": "assert/equal/%{name}.stamp",
    },
    implementation = _assert_files_equal_impl,
)

def _assert_label_struct_impl(ctx):
    actual_dict = str(simple_dict(struct_to_dict(ctx.attr.label)))
    expected_dict = (ctx.attr.expected_struct_string
            .replace("{BIN_DIR}", ctx.bin_dir.path)
            .replace("{GEN_DIR}", ctx.genfiles_dir.path))
    if actual_dict != expected_dict:
        fail("label struct does not match expected struct. " +
             "Expected: {expected} Actual: {actual}".format(expected = expected_dict,
                                                            actual = actual_dict))

    ctx.file_action(
        content = "",
        output = ctx.outputs.stamp_file,
    )

assert_label_struct_rule = rule(
    attrs = {
        "label": attr.label(
            mandatory = True,
        ),
        "expected_struct_string": attr.string(
            mandatory = True,
        ),
    },
    outputs = {
        "stamp_file": "assert/valid_type/%{name}.stamp",
    },
    implementation = _assert_label_struct_impl,
)
