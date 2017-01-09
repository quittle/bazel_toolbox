# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

# Default methods and attributes associated with Targets. This is due to limitations in Bazel being
# unable to detect if an attribute of an object is a method or really an attribute
DEFAULT_TARGET_STRUCT_KEYS = [
    "data_runfiles",
    "default_runfiles",
    "files",
    "files_to_run",
    "label",
    "output_group",
    "output_groups",
]

def default_none(value, default):
    """
    Returns |value| if it is not None, otherwise returns |default|.
    """
    return value if value != None else default
