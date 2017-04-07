# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
import zipfile

def parse_args():
    parser = argparse.ArgumentParser(description='Zips files into a zip file')
    parser.add_argument('--sources', type=str, nargs='*', required=True)
    parser.add_argument('--output', type=argparse.FileType('w+'), required=True)
    parser.add_argument('--strip-first', type=str, nargs='+', default=[])
    parser.add_argument('--strip-prefixes', type=str, nargs='+', default=[])
    return parser.parse_args()

def main():
    args = parse_args()

    with zipfile.ZipFile(args.output, 'w', zipfile.ZIP_STORED) as zipf:
        for source in args.sources:
            print(source)
            name = source
            for prefix in args.strip_first:
                if name.startswith(prefix):
                    name = name[len(prefix):]
                    break
            for prefix in args.strip_prefixes:
                print(prefix)
                if name.startswith(prefix):
                    name = name[len(prefix):]
                    break
            zipf.write(source, name)

if __name__ == '__main__':
    main()
