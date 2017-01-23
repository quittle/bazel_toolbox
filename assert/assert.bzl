# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

load(":internal.bzl",
    "assert_files_equal_rule",
    "assert_label_struct_rule",
)

def assert_equal(v1, v2):
    """
    Asserts that two values are equal. If not, fails the build
    """
    if v1 != v2:
        fail("Values were not equal (" + str(v1) + ") (" + str(v2) + ")")

def assert_str_equal(v1, v2):
    """
    Asserts that the string representation of two values are equal. If not, fails the build
    """
    assert_equal(str(v1), str(v2))

def assert_repr_equal(v1, v2):
    """
    Asserts that the `repr` of two values are equal. If not, fails the build
    """
    assert_equal(repr(v1), repr(v2))

def assert_files_equal(expected_file, actual_file):
    """
    Asserts that two files are equal

    Args:
        expected_file: `label` - The file compared against
        actual_file: `label` - The file being tested
    """
    name = "assert_files_equal_{hash}".format(hash = hash(expected_file + actual_file))
    assert_files_equal_rule(
        name = name,
        expected_file = expected_file,
        actual_file = actual_file,
    )

def assert_label_providers(label, expected_struct):
    """
    Asserts that a label's provider struct matches the expected struct

    Args:
        label: `Label|str` - The label or name of a label to check
        expected_struct: `struct` - The struct expected to match the provider's of `label`
    """
    if type(expected_struct) != "dict":
        fail("expected_struct is not a dict")

    expected_struct_string = str(expected_struct)
    name = "assert_label_struct_{hash}".format(hash = hash(label + expected_struct_string))
    assert_label_struct_rule(
        name = name,
        label = label,
        expected_struct_string = expected_struct_string,
    )
