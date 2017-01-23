# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

load("//assert:assert.bzl",
    "assert_equal",
)

load("//control_flow:control_flow.bzl",
    "while_loop",
)

def run_all_tests():
    test_while_loop()

def incr(state):
    if type(state) == "dict":
        state["incr_calls"] = state.get("incr_calls", 0) + 1
        state["value"] += 1
    else:
        state += 1
    return state

def decr(state):
    if type(state) == "dict":
        state["decr_calls"] = state.get("decr_calls", 0) + 1
        state["value"] -= 1
    else:
        state -= 1
    return state

def is_3(state):
    if type(state) == "dict":
        state["is_3_calls"] = state.get("is_3_calls", 0) + 1
        return state["value"] == 3
    else:
        return state == 3

def test_while_loop():
    assert_equal(None, while_loop(fail))

    assert_equal(0, while_loop(decr, state = 3))

    assert_equal(
        {
            "incr_calls": 3,
            "is_3_calls": 4,
            "value": 3,
        },
        while_loop(incr, is_3, state = {"value": 0})
    )
