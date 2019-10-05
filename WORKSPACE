# Copyright (c) 2017-2018 Dustin Doloff
# Licensed under Apache License v2.0

workspace(name = "bazel_toolbox")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

git_repository(
    name = "bazel_repository_toolbox",
    commit = "f512b37be02d5575d85234c9040b0f4c795a76ef",
    remote = "https://github.com/quittle/bazel_repository_toolbox",
)

load("@bazel_repository_toolbox//:github_repository.bzl", "github_repository")
load(":bazel_toolbox_repositories.bzl", "bazel_toolbox_repositories")

bazel_toolbox_repositories()

github_repository(
    name = "io_bazel_rules_sass",
    project = "rules_sass",
    sha256 = "d9c4166f5eeaae2bc0985435bcc69a5f8ce0b6d4c2bfb8c04d97bf439e4d8c3b",
    tag = "1.23.0",
    user = "bazelbuild",
)

load("@io_bazel_rules_sass//:package.bzl", "rules_sass_dependencies")

rules_sass_dependencies()

load("@io_bazel_rules_sass//:defs.bzl", "sass_repositories")

sass_repositories()
