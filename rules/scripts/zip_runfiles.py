# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
import hashlib
import os
import subprocess
import sys
import zipfile

def parse_args():
    parser = argparse.ArgumentParser(description='Zips the Bazel runtime')
    parser.add_argument('--ignore-files', type=str, nargs='+', default=[])
    parser.add_argument('--output', type=str, required=True)
    return parser.parse_args()

def hash_file(file):
    hasher = hashlib.sha256()
    with open(file, 'rb') as f:
        for block in iter(lambda: f.read(1024), b''):
            hasher.update(block)

    return hasher.digest()

def hash_str(str):
    hasher = hashlib.sha256()
    hasher.update(str)
    return hasher.digest()

def main():
    args = parse_args()

    output = args.output

    cwd = os.getcwd()
    cwd_length = len(cwd)

    script_path = os.path.abspath(sys.argv[0])
    ignore_files = set(args.ignore_files + [ output, script_path[cwd_length + 1:] ])

    script_hash = hash_file(script_path)

    with zipfile.ZipFile(output, mode='w') as out_zip:
        for root, dirs, files in os.walk(cwd):
            dirs.sort() # Recurse in deterministic order
            for name in sorted(files):
                relative_path = os.path.join(root[cwd_length + 1:], name)
                # Skip the generated zip file or an infinitely large file will be produced
                if relative_path in ignore_files:
                    continue
                with open(os.path.join(root, name), 'rb') as in_file:
                    data = in_file.read()
                    if hash_str(data) == script_hash:
                        continue

                    # Use ZipInfo to set the date to epoch at the cost of reading in the whole input
                    # into memory
                    entry = zipfile.ZipInfo(filename=relative_path, date_time=(1980,1,1,0,0,0))
                    out_zip.writestr(entry, data)


if __name__ == '__main__':
    main()
