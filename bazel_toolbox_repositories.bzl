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
        commit = "d78a1b079cd985eea7d636f79124ab4fc44cb538", # 2.9.6
        remote = "https://github.com/pallets/jinja.git",
        build_file_content = _JINJA_BUILD_FILE,
    )

    native.new_git_repository(
        name = "markup_safe",
        commit = "d2a40c41dd1930345628ea9412d97e159f828157", # 1.0
        remote = "https://github.com/pallets/markupsafe.git",
        build_file_content = _MARKUP_SAFE_BUILD_FILE,
    )

    native.maven_jar(
        name = "org_apache_commons_cli",
        artifact = "commons-cli:commons-cli:1.4",
        sha1 = "c51c00206bb913cd8612b24abd9fa98ae89719b1",
    )
