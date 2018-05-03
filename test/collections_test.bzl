# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

load("//assert:assert.bzl",
    "assert_equal",
    "assert_str_equal",
)

load("//actions:actions.bzl",
    "stamp_file",
)

load("//collections:collections.bzl",
    "dict_to_struct",
    "merge_dicts",
    "reverse",
    "simple_dict",
    "struct_to_dict",
)

def run_all_tests():
    test_simple_dict()
    test_merge_dicts()
    test_dict_to_struct()
    test_struct_to_dict()
    test_reverse()

def simple_dict_rule_impl(ctx):
    src = ctx.file.src

    if ctx.attr.assert_provider:
        sd = simple_dict(struct_to_dict(ctx.attr.src))
        assert_equal(sd,
            {
                "actions": [ None ],
                "boolean": True,
                "complex_dict": {
                    "test/data/file.txt": "string",
                    "numbers": [
                        True,
                        "string",
                        123
                    ],
                },
                "file": "test/data/file.txt",
                "file_depset": [
                    "test/data/file.txt",
                ],
                "file_dict": {
                    "test/data/file.txt": "test/data/file.txt"
                },
                "file_list": [
                    "test/data/file.txt",
                ],
                "number": 123,
                "string": "string",
            }
        )

    stamp_file(ctx, ctx.outputs.stamp)

    return struct(
        string = "string",
        number = 123,
        boolean = True,
        file = src,
        file_depset = depset([ src ]),
        file_list = [ src ],
        file_dict = { src.short_path: src },
        complex_dict = {
            src.short_path: "string",
            "numbers": [
                True,
                "string",
                123,
            ],
        },
    )


simple_dict_rule = rule(
    attrs = {
        "src": attr.label(
            allow_files = True,
            single_file = True,
            mandatory = True,
        ),
        "assert_provider": attr.bool()
    },
    outputs = {
        "stamp": "%{name}.stamp",
    },
    implementation = simple_dict_rule_impl,
)

def test_simple_dict():
    assert_equal(simple_dict({}), {})
    assert_equal(simple_dict({"a": []}), {"a": []})
    assert_equal(simple_dict({"a": depset([])}), {"a": []})

    assert_equal(simple_dict({"a": { "b": {} }}), { "a": { "b": {}}})
    assert_equal(simple_dict({"a": { "b": [] }}), { "a": { "b": []}})
    assert_equal(simple_dict({"a": { "b": depset([]) }}), { "a": { "b": []}})

    test_simple_dict_rule()

def test_simple_dict_rule():
    simple_dict_rule(
        name = "simple_dict_rule_input",
        src = "data/file.txt",
    )

    simple_dict_rule(
        name = "simple_dict_rule_test",
        src = ":simple_dict_rule_input",
        assert_provider = True,
    )

def test_merge_dicts():
    assert_equal(merge_dicts({}, {}), {})

    assert_equal(merge_dicts({"a": None}, {}), {"a": None})
    assert_equal(merge_dicts({}, {"a": None}), {"a": None})

    assert_equal(merge_dicts({"a": None}, {"a": 1}), {"a": 1})

    assert_equal(merge_dicts({"a": [1]}, {"a": [2]}), {"a": [1, 2]})
    assert_equal(merge_dicts({"a": [1]}, {"b": 2, "c": {}}), {"a": [1], "b": 2, "c": {}})

    assert_str_equal(merge_dicts({"a": depset([])}, {"a": depset([1, 2])}), {"a": depset([2, 1])})

def test_dict_to_struct():
    assert_str_equal(dict_to_struct({}), struct())

    assert_str_equal(
        dict_to_struct({
            "nested_list": [[ "a" ]],
            "set":  depset([ 1, 2 ]),
            "dict": {
                "a": "b",
            }
        }),
        struct(
            nested_list = [[ "a" ]],
            set = depset([ 1, 2 ]),
            dict = {
                "a": "b",
            },
        )
    )

def test_struct_to_dict():
    assert_equal(struct_to_dict(struct()), {})

    assert_str_equal(
        struct_to_dict(struct(
            nested_list = [[ "a" ]],
            dict_in_list = [{ "key": "value" }],
            struct_in_list = [struct(
                key = "value",
            )],
            set = depset([ 1, 2 ]),
            struct = struct(
                a = "b",
            ),
        )),
        {
            "struct_in_list": [{
                "key": "value",
            }],
            "struct": {
                "a": "b",
            },
            "set": depset([ 1, 2 ]),
            "nested_list": [[ "a" ]],
            "dict_in_list": [{ "key": "value" }],
        }
    )

def test_reverse():
    assert_str_equal([], reverse([]))
    assert_str_equal(depset([]), reverse(depset([])))
    assert_str_equal({}, reverse({}))

    assert_str_equal([1, 2, 3], reverse([3, 2, 1]))
    assert_str_equal(depset([1, 2, 3]), reverse(depset([3, 2, 1])))
    assert_str_equal({"a": 1, "b": 2, "c": 3}, reverse({"c": 3, "b": 2, "a": 1}))
