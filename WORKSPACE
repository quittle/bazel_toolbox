# Copyright (c) 2017-2018 Dustin Doloff
# Licensed under Apache License v2.0

workspace(name = "bazel_toolbox")

git_repository(
    name = "bazel_repository_toolbox",
    remote = "https://github.com/quittle/bazel_repository_toolbox",
    commit = "dfffafc08ec40df1b5ef1fbe0fbe77e643f6c672",
)

load("@bazel_repository_toolbox//:github_repository.bzl", "github_repository")

load(":bazel_toolbox_repositories.bzl", "bazel_toolbox_repositories")
bazel_toolbox_repositories()


github_repository(
    name = "io_bazel_rules_sass",
    user = "bazelbuild",
    project = "rules_sass",
    tag = "0.0.3",
    sha256 = "14536292b14b5d36d1d72ae68ee7384a51e304fa35a3c4e4db0f4590394f36ad",
)
load("@io_bazel_rules_sass//sass:sass.bzl", "sass_repositories")
sass_repositories()
