# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

load("//actions:actions.bzl",
    "stamp_file",
)

load("//assert:assert.bzl",
    "assert_files_equal",
    "assert_label_providers",
)

load("//rules:rules.bzl",
    "generate_file",
    "zip_files",
    "zip_runfiles",
)

def run_all_tests():
    test_generate_file()
    test_zip_files()
    test_zip_runfiles()

def test_generate_file():
    test_generate_bin_file()
    test_generate_gen_file()

def test_generate_bin_file():
    generate_file(
        name = "test_generate_bin_file",
        contents = "contents",
        bin_file = True,
        file = "test_generate_bin_file.txt",
    )
    assert_files_equal("data/contents.txt", ":test_generate_bin_file")

def test_generate_gen_file():
    generate_file(
        name = "test_generate_gen_file",
        contents = "contents",
        bin_file = False,
        file = "test_generate_gen_file.txt",
    )
    assert_files_equal("data/contents.txt", ":test_generate_gen_file")

def test_zip_files():
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
            ":test_generate_bin_file",
            ":test_generate_gen_file",
        ],
    )

    assert_files_equal("data/full.zip", ":test_zip_files_full")

def test_full_strip():
    zip_files(
        name = "test_zip_files_full_strip",
        srcs = [
            "data/file.txt",
            "data/template.txt",
            ":test_generate_bin_file",
            ":test_generate_gen_file",
        ],
        strip_prefixes = [
            "test/",
            "test/data/",
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

def test_zip_runfiles():
    test_zip_runfiles_deps()
    test_simple_zip_runfiles()
    test_single_dep_zip_runfiles()
    test_complex_zip_runfiles()

def test_zip_runfiles_deps():
    native.py_library(
        name = "simple_library",
        srcs = [ "data/test.py" ],
    )

    native.py_library(
        name = "single_dep_library",
        srcs = [ "data/test.py" ],
        data = [ "data/file.txt" ],
    )

    native.py_binary(
        name = "complex_binary",
        srcs = [ "data/other.py" ],
        main = "data/other.py",
        deps = [
            ":simple_library",
            ":single_dep_library",
        ],
        data = [
            "data/empty.txt",
            "@markup_safe//:markup_safe",
        ]

    )

def test_simple_zip_runfiles():
    zip_runfiles(
        name = "test_simple_library_runfiles",
        py_library = ":simple_library",
    )
    assert_files_equal("data/expected_simple_library_runfiles.zip", ":test_simple_library_runfiles")

def test_single_dep_zip_runfiles():
    zip_runfiles(
        name = "test_single_dep_runfiles",
        py_library = ":single_dep_library",
    )
    assert_files_equal("data/expected_single_dep_runfiles.zip", ":test_single_dep_runfiles")

def test_complex_zip_runfiles():
    zip_runfiles(
        name = "test_complex_runfiles",
        py_library = ":complex_binary",
    )
    assert_files_equal("data/expected_complex_binary_runfiles.zip", ":test_complex_runfiles")
