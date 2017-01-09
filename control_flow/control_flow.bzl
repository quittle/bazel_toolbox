# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

load(":internal.bzl",
    "default_while_loop_termination_case",
)

# Due to restrictions of the language, the only loop supported is a for-in loop, so a long iterable
# is needed to simulate a while-do loop
_LONG_LIST = 10000 * "."

def while_loop(body, termination_case = default_while_loop_termination_case, state = None):
    """
    Performs a while loop. This method is of limited use due to the inability to define lambdas

    Args:
        body: `function(*):* - The body function that is called with the current state for each
                               iteration. The return value from this method is the new state.
        termination_case: `function(*):bool` - This method determines if the loop should continue.
                                               it takes the current state and returns a boolean. If
                                               it returns True, the loop terminates. Defaults to
                                               using the inverse of the global |bool| method.
        state: `*` The initial state to use. Defaults to None.

    Returns:
        `*` The final state of the loop when `termination_case` returns True.
    """
    for _ in _LONG_LIST:
        should_terminate = termination_case(state)
        if type(should_terminate) != "bool":
            fail("termination_case must return a boolean. Returned: " + str(should_terminate))

        if should_terminate:
            return state

        state = body(state)

    fail("While loop never terminated. Final state: " + str(state))