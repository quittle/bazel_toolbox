# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

def default_while_loop_termination_case(state):
    """
    Checks if the state is falsey

    Args:
        state: An object that should capable of being passed to `bool`

    Returns:
        True if the state is falsey or False if the state is Truthy
    """
    return not bool(state)
