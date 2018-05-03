# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

load(":internal.bzl",
    "DEFAULT_TARGET_STRUCT_KEYS",
    "default_none",
)

# An important note about functions in this file. Bazel does not support recursion, so this file
# uses a loop with a stack to recurse through objects. Bazel also does not support while loops, so
# an "infinite" loop for all practical purposes with an immediate conditional-break is immediately
# used. This cannot be simplified with a function because lambdas are not supported and method
# passing is tedious due to the excess method definitions

# Due to restrictions of the language, the only loop supported is a for-in loop, so a long iterable
# is needed to simulate a while-do loop
_LONG_LIST = 10000 * "."

def simple_dict(dictionary):
    """
    Converts a dictionary into a json-like dict, simplifying Bazel objects into strings and sets
    into lists.

    Args:
        dictionary: `dict` - The dict to simplify.

    Returns:
        `dict` - A dict that contains only dicts, lists, strings, and numbers.
    """
    result = {}
    stack = [ (result, key, list(value) if type(value) == "depset" else value)
            for key, value in dictionary.items() ]
    for i in _LONG_LIST:
        if len(stack) == 0:
            break
        container, key, value = stack.pop()

        type_value = type(value)
        simple_value = None
        if type_value in ["depset", "list"]:
            simple_value = []
            stack.extend([ (simple_value, None, sub_value) for sub_value in value ])
        elif type_value == "dict":
            simple_value = {}
            stack.extend([ (simple_value, sub_key, sub_value)
                    for sub_key, sub_value in value.items() ])
        elif type_value == "struct":
            simple_value = {}
            stack.extend([ (simple_value, sub_key, sub_value)
                    for sub_key, sub_value in struct_to_dict(value).items() ])
        elif type_value == "File":
            simple_value = value.path
        elif type_value in ["bool", "int", "number", "string"]:
            simple_value = value
        elif type_value in ["Action", "OutputGroupProvider"]:
            # Not currently iteratable
            pass
        else:
            fail("Unable to handle type: " + type_value)

        type_container = type(container)
        if type_container == "dict":
            if type(key) != "string":
                fail("Key is not a string: " + type(key))
            container[key] = simple_value
        elif type_container == "list":
            if key != None:
                fail("Key should have been None: " + key)
            container.append(simple_value)
        else:
            fail("Container of invalid type: " + type_container)

    return result

def get_struct_entries(structure):
    """
    Gets the entries in `structure` that are not default values.

    Args:
        structure: `struct|Target` - The struct or target to get entries from

    Returns:
        `list of strings` - A list of keys in `structure` that are not added by default
    """
    structure_type = type(structure)
    if structure_type not in ["struct", "Target"]:
        fail("Expected a struct or Target, but got " + structure_type)

    keys = dir(structure)
    for key in dir(struct()) + DEFAULT_TARGET_STRUCT_KEYS:
        if key in keys:
            keys.remove(key)
    return keys

def struct_to_dict(structure):
    """
    Converts a struct to a dict along with all nested structs.

    Args:
        structure : `struct|Target` - The struct or target to convert

    Returns:
        `dict` - A dict representation of the struct
    """
    structure_type = type(structure)
    if structure_type not in [ "struct", "Target" ]:
        fail("Expected a struct or Target, but got " + structure_type)

    contents = get_struct_entries(structure)

    result = {}
    stack = [ (result, entry, getattr(structure, entry)) for entry in contents ]
    for i in _LONG_LIST:
        if len(stack) == 0:
            break
        container, key, value = stack.pop()

        new_value = value

        type_value = type(value)
        if type_value == "struct":
            new_value = {}
            stack.extend([ (new_value, entry, getattr(value, entry))
                    for entry in get_struct_entries(value) ])
        elif type_value == "dict":
            new_value = {}
            stack.extend([ (new_value, sub_key, sub_value)
                    for sub_key, sub_value in value.items() ])
        elif type_value == "list":
            new_value = []
            stack.extend([ (new_value, None, sub_value) for sub_value in value ])
        # No need to worry about depsets, which aren't mutable, because they cannot contain mutable
        # objects or depsets. Even though they can contain structs, the dicts they'd be converted to
        # wouldn't be allowed inside. Then if those structs were ignored, it wouldn't matter anyway
        # as nothing would need to be changed inside the set so no need to loop through the depset's
        # contents.

        if key != None:
            container[key] = new_value
        elif type(container) == "list":
            container.append(new_value)
        else:
            fail("Unexpected container type: " + type(container))

    return result

def dict_to_struct(dictionary):
    """
    Converts a dict to a struct, without converting nested dicts. Note that this is not a complete
    reverse of struct_to_dict as it will not convert deeply nested dicts.

    Args:
        dictionary: `dict` - The dict to convert

    Retruns:
        `struct` - A struct representation of `dictionary`
    """
    return struct(**dictionary)

def merge_structs(struct_1, struct_2):
    """
    Merges the two structs and returns the new, merged struct.

    Args:
        struct_1: `struct` - The first struct to merge
        struct_2: `struct` - The second struct to merge

    Returns:
        `struct` - Returns a new struct containing all the entries from the inputs. The second
                   struct's entries override the first's.
    """
    return dict_to_struct(merge_dicts(struct_to_dict(struct_1), struct_to_dict(struct_2)))

def merge_dicts(dict_1, dict_2):
    """
        Merges two dicts into a new dict.

        Args:
            dict_1: `dict` - The first dict to merge
            dict_2: `dict` - The second dict to merge

        Returns:
            `dict` - A new dict containing all the entries from the inputs. The second dict's
                     entries override the firsts unless they are containers, in which case the
                     second dict's conents are added to the first's.
    """
    result = {}
    # First item needs to be inserted last so that it overrides values from the second
    stack = [ (result, (None, None), key, value)
            for key, value in dict_2.items() + dict_1.items() ]
    for i in _LONG_LIST:
        if len(stack) == 0:
            break
        # parent is the parent of container and parent_key is the key for parent that accesses
        # container.
        container, (parent, parent_key), key, value = stack.pop()

        type_container = type(container)
        type_value = type(value)

        # The current value for the same key in the container being merged into. This is to enable
        # merging into already generated containers that might be referenced in the stack.
        pre_filled_value = (
            None if type_value not in ["dict", "list", "depset", "struct"] else
            container[key] if type_container == "dict" and key in container else
            list(container)[list(container).index(value)]
                    if type_container in ["list", "depset"] and value in container else
            getattr(container, key) if type_container == "struct" else
            None
        )

        simple_value = None
        if type_value == "list":
            simple_value = default_none(pre_filled_value, [])
            stack.extend([ (simple_value, (container, key), None, sub_value)
                    for sub_value in value ])
        elif type_value == "depset":
            simple_value = default_none(pre_filled_value, depset([]))
            stack.extend([ (simple_value, (container, key), None, sub_value)
                    for sub_value in value ])
        elif type_value == "dict":
            simple_value = default_none(pre_filled_value, {})
            stack.extend([ (simple_value, (container, key), sub_key, sub_value)
                    for sub_key, sub_value in value.items() ])
        elif type_value == "struct":
            simple_value = default_none(pre_filled_value, {}) # Convert this out of laziness
            stack.extend([ (simple_value, (container, key), sub_key, sub_value)
                    for sub_key, sub_value in struct_to_dict(value).items() ])
        else:
            simple_value = value

        if type_container == "dict":
            if type(key) != "string":
                fail("Key is not a string: " + type(key))
            container[key] = simple_value
        elif type_container == "list":
            if key != None:
                fail("Key should have been None: " + key)
            container.append(simple_value)
        elif type_container == "depset":
            if key != None:
                fail("Key should have been None: " + key)
            # Depsets are immutable so a new one needs to be created and inserted into the parent.
            # This can't chain because depsets can't contain mutable objects or other depsets.
            parent[parent_key] += depset([ simple_value ])
        else:
            fail("Container of invalid type: " + type_container)

    return result

def reverse(collection):
    """
        Reverses a collection.

        Args:
            collection: `dict|list|depset` - The collection to reverse

        Returns:
            `dict|list|depset` - A new collection of the same type, with items in the reverse order
                                 of the input collection.
    """
    forward_list = None
    collection_type = type(collection)
    if collection_type == "dict":
        forward_list = collection.items()
    elif collection_type == "list":
        forward_list = collection
    elif collection_type == "depset":
        forward_list = list(collection)
    else:
        fail("Unsupported collection type: " + collection_type)

    reverse_list = []
    for value in forward_list:
        reverse_list.insert(0, value)

    ret = None
    if collection_type == "dict":
        ret = dict(reverse_list)
    elif collection_type == "list":
        ret = reverse_list
    elif collection_type == "depset":
        ret = depset(reverse_list)
    else:
        fail("Unsupported collection type: " + collection_type)

    return ret
