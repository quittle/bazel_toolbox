# Welcome to the Bazel Toolbox ![Travis CI Build Status](https://travis-ci.org/quittle/bazel_toolbox.svg?branch=master)

This is a Skylark library to facilitate the building of Skylark rule libraries. It includes helper functions for writing tests, managing various Skylark dicts, performing common actions as part of rules, and several others.

## Why use this?

Writing simple Skylark rules are easy, but it can be difficult to write rules that would be trivial in Python.  Some basic things such as the lack of recursion and while-do loops in the language and the lack of common actions such as copying files provided by default, can make writing a new rule overly difficult to do without writing a bunch of helper, boilerplate macros. It is intendend mainly for consumption by Skylark rule libraries and not by end projects that simply use Bazel as a build system.

## Integration

1. Add this as a dependency to `WORKSPACE` and add its dependencies.
```python
git_repository(
    name = "bazel_toolbox",
    commit = "<latest commit>",
    remote = "https://github.com/quittle/bazel_toolbox.git"
)
load("@bazel_toolbox//:bazel_toolbox_repositories.bzl", "bazel_toolbox_repositories")
bazel_toolbox_repositories()
```
2. `load` and use the methods in `.bzl` files.
