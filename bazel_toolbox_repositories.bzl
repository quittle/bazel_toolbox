# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

_JINJA_BUILD_FILE = """

py_library(
    name = "jinja",
    srcs = glob([ "jinja2/*.py" ]),
    deps = [
        "@markup_safe//:markup_safe",
    ],
    visibility = [ "//visibility:public" ],
)

"""

_MARKUP_SAFE_BUILD_FILE = """

py_library(
    name = "markup_safe",
    srcs = glob([ "markupsafe/*.py" ]),
    visibility = [ "//visibility:public" ],
)

"""

def bazel_toolbox_repositories():
    """
        Adds all the necessary repositories to the workspace.
    """
    native.new_git_repository(
        name = "jinja",
        commit = "966e1a409f02de57b75a0463fc953d54dad2a205", # 2.8
        remote = "https://github.com/pallets/jinja.git",
        build_file_content = _JINJA_BUILD_FILE,
    )

    native.new_git_repository(
        name = "markup_safe",
        commit = "feb1d70c16df62f60dcb521d127fdad8819fc036", # 0.23
        remote = "https://github.com/pallets/markupsafe.git",
        build_file_content = _MARKUP_SAFE_BUILD_FILE,
    )
