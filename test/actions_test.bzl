# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

load("//assert:assert.bzl",
    "assert_files_equal",
    "assert_str_equal",
)

load("//actions:actions.bzl",
    "file_copy",
    "generate_templated_file",
)

load("//labels:labels.bzl",
    "executable_label",
)

def run_all_tests():
    test_file_copy()
    test_generate_templated_file()

# file_copy test

def _test_file_copy_rule_impl(ctx):
    file_copy(ctx, ctx.executable._file_copy, ctx.file.source, ctx.outputs.destination)

_test_file_copy_rule = rule(
    attrs = {
        "source": attr.label(
            allow_files = True,
            single_file = True,
            mandatory = True,
        ),
        "_file_copy": executable_label("//actions:file_copy"),
    },
    outputs = {
        "destination": "%{name}__copy",
    },
    implementation = _test_file_copy_rule_impl,
)

def test_file_copy():
    _test_file_copy_rule(
        name = "file_copy_test",
        source = "data/file.txt",
    )
    assert_files_equal("data/file.txt", ":file_copy_test")

# generate_templated_file test

def _test_generate_templated_file_rule_impl(ctx):
    generate_templated_file(
        ctx,
        ctx.executable._generate_templated_file,
        ctx.file.template,
        {
            "fruit": "apple",
            "deeply": {
                "nested": [ {
                    "value": 5
                } ]
            }
        },
        ctx.outputs.destination
    )

_test_generate_templated_file_rule = rule(
    attrs = {
        "template": attr.label(
            allow_files = True,
            single_file = True,
            mandatory = True,
        ),
        "_generate_templated_file": executable_label("//actions:generate_templated_file"),
    },
    outputs = {
        "destination": "%{name}__generated",
    },
    implementation = _test_generate_templated_file_rule_impl,
)

def test_generate_templated_file():
    _test_generate_templated_file_rule(
        name = "generate_templated_file_test",
        template = "data/template.txt",
    )
    assert_files_equal("data/expected_generated_file.txt", ":generate_templated_file_test")
