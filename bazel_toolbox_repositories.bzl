# Copyright (c) 2017-2018 Dustin Doloff
# Licensed under Apache License v2.0

load("@bazel_repository_toolbox//:github_repository.bzl", "new_github_repository")

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
    new_github_repository(
        name = "jinja",
        user = "pallets",
        project = "jinja",
        tag = "2.10.3",
        sha256 = "db49236731373e4f3118af880eb91bb0aa6978bc0cf8b35760f6a026f1a9ffc4",
        build_file_content = _JINJA_BUILD_FILE,
    )

    new_github_repository(
        name = "markup_safe",
        user = "pallets",
        project = "markupsafe",
        tag = "1.1.1",
        sha256 = "222a10e3237d92a9cd45ed5ea882626bc72bc5e0264d3ed0f2c9129fa69fc167",
        build_file_content = _MARKUP_SAFE_BUILD_FILE,
    )

    native.maven_jar(
        name = "org_apache_commons_cli",
        artifact = "commons-cli:commons-cli:1.4",
        sha1 = "c51c00206bb913cd8612b24abd9fa98ae89719b1",
    )

    native.maven_jar(
        name = "org_apache_commons_io",
        artifact = "commons-io:commons-io:2.6",
        sha1 = "815893df5f31da2ece4040fe0a12fd44b577afaf",
    )
