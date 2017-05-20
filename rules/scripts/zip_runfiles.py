# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
import os
import sys
import zipfile

def parse_args():
    parser = argparse.ArgumentParser(description='Zips the Bazel runtime')
    parser.add_argument('--ignore-files', type=str, nargs='+', default=[])
    parser.add_argument('--output', type=str, required=True)
    return parser.parse_args()

def main():
    args = parse_args()

    output = args.output

    cwd = os.getcwd()
    cwd_length = len(cwd)

    script_path = os.path.abspath(sys.argv[0])
    ignore_files = set(args.ignore_files + [ output, script_path[cwd_length + 1:] ])

    with zipfile.ZipFile(output, mode='w') as out_zip:
        for root, dirs, files in os.walk(cwd):
            for name in files:
                relative_path = os.path.join(root[cwd_length + 1:], name)
                # Skip the generated zip file or an infinitely large file will be produced
                if relative_path in ignore_files: #output == relative_path:
                    continue
                with open(os.path.join(root, name), 'rb') as in_file:
                    # Use ZipInfo to set the date to epoch at the cost of reading in the whole input
                    # into memory
                    entry = zipfile.ZipInfo(filename=relative_path)
                    data = in_file.read()
                    out_zip.writestr(entry, data)


if __name__ == '__main__':
    main()
