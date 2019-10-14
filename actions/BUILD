# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

py_library(
    name = "jinja_helper",
    srcs = [
        "scripts/jinja_helper.py",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "@jinja",
    ],
)

py_binary(
    name = "generate_templated_file",
    srcs = [
        "scripts/generate_templated_file.py",
    ],
    visibility = ["//visibility:public"],
    deps = [
        ":jinja_helper",
    ],
)

py_binary(
    name = "file_copy",
    srcs = [
        "scripts/file_copy.py",
    ],
    visibility = ["//visibility:public"],
)

java_binary(
    name = "zip_files",
    srcs = glob(["scripts/zip_files/java/src/**/*.java"]),
    main_class = "com.dustindoloff.zipfiles.Main",
    visibility = ["//visibility:public"],
    deps = [
        "@org_apache_commons_cli//jar",
        "@org_apache_commons_io//jar",
    ],
)
