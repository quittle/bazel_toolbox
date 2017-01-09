# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

workspace(name = "bazel_toolbox")

load(":bazel_toolbox_repositories.bzl", "bazel_toolbox_repositories")
bazel_toolbox_repositories()

git_repository(
    name = "io_bazel_rules_sass",
    remote = "https://github.com/bazelbuild/rules_sass.git",
    commit = "5973952ac44b93691e137362567220d64a92e7e9", # 0.0.1
)
load("@io_bazel_rules_sass//sass:sass.bzl", "sass_repositories")
sass_repositories()

