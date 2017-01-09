# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

def file_copy(ctx, file_copy_script, source_file, destination_file):
    """
    Copies a file from one location to another.

    Args:
        ctx: `ctx` - The context to use
        file_copy_script: `executable` - The file_copy executable
        source_file: `File` - The file to copy
        destination_file: `File` - The file to copy it out to
    """
    if type(ctx) != "ctx":
        fail("ctx was not a context")
    if type(file_copy_script) != "File":
        fail("file_copy_script was not a file")
    if type(source_file) != "File":
        fail("source_file was not a file")
    if type(destination_file) != "File":
        fail("destination_file was not a file")

    ctx.action(
        mnemonic = "CopyFile",
        arguments = [
            "--source", source_file.path,
            "--destination", destination_file.path,
        ],
        inputs = [ file_copy_script, source_file ],
        executable = file_copy_script,
        outputs = [ destination_file ],
    )

def generate_templated_file(ctx, generate_templated_file_script, template, config, out_file):
    """
    Create an action that generates a file from a jinja template.

    Args:
        ctx: `ctx` - The context to use
        generate_templated_file_script: `executable` - The generate_templated_file executable
        template: `File` - The jinja template file
        config: `dict` - The args to use with the template
        out_file: `File` - The file generated from applying `config` to `template`
    """
    if type(ctx) != "ctx":
        fail("ctx was not a context")
    if type(generate_templated_file_script) != "File":
        fail("generate_templated_file_script was not a file")
    if type(template) != "File":
        fail("template was not a File")
    if type(config) != "dict":
        fail("config was not a dictionary")
    if type(out_file) != "File":
        fail("out_file was not a File")

    ctx.action(
        mnemonic = "GeneratingFileFromJinjaTemplate",
        arguments = [
            "--template", template.path,
            "--config", str(config),
            "--out-file", out_file.path,
        ],
        inputs = [ template ],
        executable = generate_templated_file_script,
        outputs = [ out_file ],
    )
