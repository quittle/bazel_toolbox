# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

load("//assert:assert.bzl",
    "assert_equal",
    "assert_str_equal",
)

load("//collections:collections.bzl",
    "dict_to_struct",
    "merge_dicts",
    "struct_to_dict",
)

def run_all_tests():
    test_merge_dicts_()
    test_dict_to_struct()
    test_struct_to_dict()

def test_merge_dicts_():
    assert_equal(merge_dicts({}, {}), {})

    assert_equal(merge_dicts({"a": None}, {}), {"a": None})
    assert_equal(merge_dicts({}, {"a": None}), {"a": None})

    assert_equal(merge_dicts({"a": None}, {"a": 1}), {"a": 1})

    assert_equal(merge_dicts({"a": [1]}, {"a": [2]}), {"a": [1, 2]})
    assert_equal(merge_dicts({"a": [1]}, {"b": 2, "c": {}}), {"a": [1], "b": 2, "c": {}})

    assert_str_equal(merge_dicts({"a": set([])}, {"a": set([1, 2])}), {"a": set([2, 1])})

def test_dict_to_struct():
    assert_str_equal(dict_to_struct({}), struct())

    assert_str_equal(
        dict_to_struct({
            "nested_list": [[ "a" ]],
            "set":  set([ 1, 2 ]),
            "dict": {
                "a": "b",
            }
        }),
        struct(
            nested_list = [[ "a" ]],
            set = set([ 1, 2 ]),
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
            set = set([ 1, 2 ]),
            struct = struct(
                a = "b",
            ),
        )),
        {
            "nested_list": [[ "a" ]],
            "dict_in_list": [{ "key": "value" }],
            "struct_in_list": [{
                "key": "value",
            }],
            "set":  set([ 1, 2 ]),
            "struct": {
                "a": "b",
            },
        }
    )
