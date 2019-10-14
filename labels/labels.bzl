# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

def executable_label(label):
    """
    Generates a simple executable label for Skylark rules. If referencing a local label, do not pass
    a string, e.g. executable_label("//package:label"), pass a Label, e.g.
    executable_label(Label("//package:label")) as the Label function is relative to either package
    called in or the workspace root and a middle-layer workspace would be impossible to target.

    Examples of how to call:
    executable_label("@proj_a//a:a")
    executable_label(Label("//a:a"))

    How not to call:
    executable_label("//a:a")
    executable_label(Label(":a"))


    Args:
        label: `str|Label` - The label of the tool

    Returns:
        `attr_defintion` - An executable label for a Skylark rule
    """
    if type(label) == "string":
        label = Label(label)
    elif type(label) != "Label":
        fail("label was not a string or Label")

    return attr.label(
        default = label,
        executable = True,
        cfg = "host",
        allow_files = True,
    )
