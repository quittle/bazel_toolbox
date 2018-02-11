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
        tag = "2.10",
        sha256 = "0d31d3466c313a9ca014a2d904fed18cdac873a5ba1f7b70b8fd8b206cd860d6",
        build_file_content = _JINJA_BUILD_FILE,
    )

    new_github_repository(
        name = "markup_safe",
        user = "pallets",
        project = "markupsafe",
        tag = "1.0",
        sha256 = "dc3938045d9407a73cf9fdd709e2b1defd0588d50ffc85eb0786c095ec846f15",
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
