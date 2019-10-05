# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
import difflib
import hashlib
import os
import subprocess
import zipfile

# Resets color formatting
COLOR_END = '\33[0m'
# Modifies characters or color
COLOR_BOLD = '\33[1m'
COLOR_DISABLED = '\33[02m' # Mostly just means darker
# Sets the text color
COLOR_GREEN = '\33[32m'
COLOR_YELLOW = '\33[33m'
COLOR_RED = '\33[31m'

def parse_args():
    parser = argparse.ArgumentParser(description='Asserts files are the same')
    parser.add_argument('--stamp', type=argparse.FileType('w+'), required=True,
                                   help='Stamp file to record action completed')
    parser.add_argument('--files', type=str, nargs='+', required=True)
    return parser.parse_args()

def bytes_to_str(bytes):
    return bytes.decode('utf-8', 'backslashreplace')

def color_diff(text_a, text_b):
    """
        Compares two pieces of text and returns a tuple
        The first value is a colorized diff of the texts.
        The second value is a boolean, True if there was a diff, False if there wasn't.
    """
    sequence_matcher = difflib.SequenceMatcher(None, text_a, text_b)
    colorized_diff = ''
    diff = False
    for opcode, a0, a1, b0, b1 in sequence_matcher.get_opcodes():
        if opcode == 'equal':
            colorized_diff += bytes_to_str(sequence_matcher.a[a0:a1])
        elif opcode == 'insert':
            colorized_diff += COLOR_BOLD + COLOR_GREEN + bytes_to_str(sequence_matcher.b[b0:b1]) + COLOR_END
            diff = True
        elif opcode == 'delete':
            colorized_diff += COLOR_BOLD + COLOR_RED + bytes_to_str(sequence_matcher.a[a0:a1]) + COLOR_END
            diff = True
        elif opcode == 'replace':
            colorized_diff += (COLOR_BOLD + COLOR_YELLOW + bytes_to_str(sequence_matcher.a[a0:a1]) +
                               COLOR_DISABLED + bytes_to_str(sequence_matcher.b[b0:b1]) + COLOR_END)
            diff = True
        else:
            raise RuntimeError('unexpected opcode ' + opcode)
    return colorized_diff, diff

def hash_file(file):
    """
        Computes the SHA-256 hash of the file
        file - The file to hash
    """
    hasher = hashlib.sha256()
    with open(file, 'rb') as f:
        for block in iter(lambda: f.read(1024), b''):
            hasher.update(block)

    return hasher.digest()

def summarize(file):
    """
        Summarizes a file via it's metadata to provide structured text for diffing
    """
    summary = None
    if zipfile.is_zipfile(file):
        with zipfile.ZipFile(file) as zf:
            summary = ''
            for info in zf.infolist():
                summary += 'Entry: ('
                summary += ', '.join(s + ': ' + repr(getattr(info, s)) for s in info.__slots__)
                summary += ') ' + os.linesep

    assert summary is not None, 'Unable to summarize %s' % file
    return summary


def main():
    args = parse_args()

    files = args.files

    assert len(files) >= 2, 'There must be at least two files to compare'

    files_hashes = set()
    max_file_size = 0
    for file in files:
        files_hashes.add(hash_file(file))
        max_file_size = max(max_file_size, os.stat(file).st_size)

    # Check hashes first
    if len(files_hashes) != 1:
        for i in range(len(files) - 1):
            file_a = files[i]
            file_b = files[i + 1]

            file_a_contents = None
            file_b_contents = None
            if max_file_size > 1024 * 1024:
                file_a_contents = summarize(file_a)
                file_b_contents = summarize(file_b)
            else:
                with open(file_a, 'rb') as a:
                    file_a_contents = a.read()
                with open(file_b, 'rb') as b:
                    file_b_contents = b.read()

            diff, problem = color_diff(file_a_contents, file_b_contents)
            assert not problem, 'File {a} does not match {b}:{newline}{diff}'.format(
                    a = file_a,
                    b = file_b,
                    newline = os.linesep,
                    diff = diff)

        assert False, 'File hashes don\'t match.'

    with args.stamp as stamp_file:
        stamp_file.write(str(args))

if __name__ == '__main__':
    main()
