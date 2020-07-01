# Copyright (c) 2017-2018 Dustin Doloff
# Licensed under Apache License v2.0

workspace(name = "bazel_toolbox")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

git_repository(
    name = "bazel_repository_toolbox",
    commit = "b7d32c04cb993267606a188cc4c55be3b6b5c564",
    remote = "https://github.com/quittle/bazel_repository_toolbox",
)

load("@bazel_repository_toolbox//:github_repository.bzl", "github_repository")

github_repository(
    name = "io_bazel_rules_sass",
    project = "rules_sass",
    sha256 = "1e87d3c77be74f67f617e8fa2d7c1f2d9604717c892b06e5ee3338c1b92b0074",
    tag = "1.26.9",
    user = "bazelbuild",
)

github_repository(
    name = "rules_jvm_external",
    project = "rules_jvm_external",
    sha256 = "19d402ef15f58750352a1a38b694191209ebc7f0252104b81196124fdd43ffa0",
    tag = "3.2",
    user = "bazelbuild",
)

load("@io_bazel_rules_sass//:package.bzl", "rules_sass_dependencies")

rules_sass_dependencies()

load("@io_bazel_rules_sass//:defs.bzl", "sass_repositories")

sass_repositories()

load(":bazel_toolbox_repositories.bzl", "bazel_toolbox_repositories")

bazel_toolbox_repositories()
