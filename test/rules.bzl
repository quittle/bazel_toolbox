# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

load("//actions:actions.bzl",
    "stamp_file",
)

load("//assert:assert.bzl",
    "assert_files_equal",
)

load("//rules:rules.bzl",
    "zip_files",
)

def run_all_tests():
    test_empty()
    test_full()
    test_full_strip()
    test_generated_paths()
    test_generated_paths_strip()

def test_empty():
    zip_files(
        name = "test_zip_files_empty",
        srcs = [],
    )

    assert_files_equal("data/empty.zip", ":test_zip_files_empty")

def test_full():
    zip_files(
        name = "test_zip_files_full",
        srcs = [
            "data/file.txt",
            "data/template.txt",
        ],
    )

    assert_files_equal("data/full.zip", ":test_zip_files_full")

def test_full_strip():
    zip_files(
        name = "test_zip_files_full_strip",
        srcs = [
            "data/file.txt",
            "data/template.txt",
        ],
        strip_prefixes = [
            "test/data",
        ],
    )

    assert_files_equal("data/flat.zip", ":test_zip_files_full_strip")

def _stamp_file_rule_impl(ctx):
    stamp_file(ctx, ctx.outputs.stamp_file)

_stamp_file_rule = rule(
    outputs = {
        "stamp_file": "%{name}.stamp",
    },
    implementation = _stamp_file_rule_impl,
)

def test_generated_paths():
    _stamp_file_rule(
        name = "generated_paths_stamp",
    )
    zip_files(
        name = "test_generated_paths",
        srcs = [
            ":generated_paths_stamp",
        ],
    )

    assert_files_equal("data/nested.zip", ":test_generated_paths")

def test_generated_paths_strip():
    _stamp_file_rule(
        name = "generated_paths_stamp_strip",
    )
    zip_files(
        name = "test_generated_paths_strip",
        srcs = [
            ":generated_paths_stamp_strip",
        ],
        strip_prefixes = [
            "test",
        ],
    )

    assert_files_equal("data/nested_stripped.zip", ":test_generated_paths_strip")
