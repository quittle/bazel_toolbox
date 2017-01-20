# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

def executable_label(label, relative_to_caller_repository=True):
    """
    Generates a simple executable label for Skylark rules.

    Args:
        label: `str` - The label of the tool

    Returns:
        `Label` - An executable Label for a Skylark rule
    """
    if type(label) != "string":
        fail("label was not a string")

    return attr.label(
        default = Label(label, relative_to_caller_repository=relative_to_caller_repository),
        executable = True,
        cfg = "host",
        allow_files = True,
    )