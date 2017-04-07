// Copyright (c) 2017 Dustin Doloff
// Licensed under Apache License v2.0

package com.dustindoloff.zipfiles;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.util.zip.Deflater;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;

/**
 * Contains the main function and argument parsing capabilities
 */
public final class Main {
    private static final String ARG_SOURCES = "sources";
    private static final String ARG_STRIP_FIRST = "strip-first";
    private static final String ARG_STRIP_PREFIXES = "strip-prefixes";
    private static final String ARG_OUTPUT = "output";

    private static Options buildOptions() {
        return new Options()
            .addOption(Option.builder()
                    .argName("Sources")
                    .longOpt(ARG_SOURCES)
                    .desc("The files to zip up")
                    .type(String.class)
                    .hasArgs()
                    .build())
            .addOption(Option.builder()
                    .argName("Initial Prefixes")
                    .longOpt(ARG_STRIP_FIRST)
                    .desc("Prefixes to strip before regular prefixes. Useful for build folders")
                    .type(String.class)
                    .hasArgs()
                    .build())
            .addOption(Option.builder()
                    .argName("Path Prefixes")
                    .longOpt(ARG_STRIP_PREFIXES)
                    .desc("Paths to strip off the entries")
                    .type(String.class)
                    .hasArgs()
                    .build())
            .addOption(Option.builder()
                    .argName("Output")
                    .longOpt(ARG_OUTPUT)
                    .desc("The zipfile to output")
                    .type(File.class)
                    .required()
                    .hasArg()
                    .build());
    }

    @SuppressWarnings("unchecked")
    private static <T> T getOption(final CommandLine commandLine, final String arg) {
        try {
            return (T) commandLine.getParsedOptionValue(arg);
        } catch (final ParseException e) {
            throw new RuntimeException("Unable to parse arg: " + arg);
        }
    }

    public static void main(final String[] args) throws IOException {
        final Options options = buildOptions();
        final CommandLineParser parser = new DefaultParser();
        final CommandLine commandLine;
        try {
            commandLine = parser.parse(options, args);
        } catch (final ParseException e) {
            System.out.println(e.getMessage());
            new HelpFormatter().printHelp("zipFiles", options);
            System.exit(1);
            return;
        }

        final String[] sources = commandLine.getOptionValues(ARG_SOURCES);
        final String[] stripFirst = commandLine.getOptionValues(ARG_STRIP_FIRST);
        final String[] stripPrefixes = commandLine.getOptionValues(ARG_STRIP_PREFIXES);
        final File output = getOption(commandLine, ARG_OUTPUT);

        try (final ZipOutputStream zos = new ZipOutputStream(new FileOutputStream(output))) {
            zos.setLevel(Deflater.NO_COMPRESSION);

            if (sources == null) {
                return;
            }

            for (final String source : sources) {
                String name = source;
                if (stripFirst != null) {
                    for (final String prefix : stripFirst) {
                        if (name.startsWith(prefix)) {
                            name = name.substring(prefix.length());
                            break;
                        }
                    }
                }
                if (stripPrefixes != null) {
                    for (final String prefix : stripPrefixes) {
                        if (name.startsWith(prefix)) {
                            name = name.substring(prefix.length());
                            break;
                        }
                    }
                }
                final ZipEntry zipEntry = new ZipEntry(name);
                zipEntry.setTime(0);
                zos.putNextEntry(zipEntry);
                Files.copy(new File(source).toPath(), zos);
                zos.closeEntry();
            }
        }
    }
}
