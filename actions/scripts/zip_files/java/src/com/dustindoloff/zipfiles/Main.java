// Copyright (c) 2017 Dustin Doloff
// Licensed under Apache License v2.0

package com.dustindoloff.zipfiles;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.util.Arrays;
import java.util.Comparator;
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

    private static final Comparator<String> STRING_LENGTH_HIGH_TO_LOW_COMPARATOR =
            (final String a, final String b) -> b.length() - a.length();

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

        String[] sources = commandLine.getOptionValues(ARG_SOURCES);
        String[] stripFirst = commandLine.getOptionValues(ARG_STRIP_FIRST);
        String[] stripPrefixes = commandLine.getOptionValues(ARG_STRIP_PREFIXES);
        final File output = getOption(commandLine, ARG_OUTPUT);

        if (sources == null) {
            sources = new String[0];
        }

        if (stripFirst == null) {
            stripFirst = new String[0];
        }

        if (stripPrefixes == null) {
            stripPrefixes = new String[0];
        }

        Arrays.sort(stripFirst, STRING_LENGTH_HIGH_TO_LOW_COMPARATOR);
        Arrays.sort(stripPrefixes, STRING_LENGTH_HIGH_TO_LOW_COMPARATOR);

        try (final ZipOutputStream zos = new ZipOutputStream(new FileOutputStream(output))) {
            zos.setLevel(Deflater.NO_COMPRESSION);

            for (final String source : sources) {
                String name = source;
                for (final String prefix : stripFirst) {
                    if (name.startsWith(prefix)) {
                        name = name.substring(prefix.length());
                        break;
                    }
                }
                for (final String prefix : stripPrefixes) {
                    if (name.startsWith(prefix)) {
                        name = name.substring(prefix.length());
                        break;
                    }
                }
                final ZipEntry zipEntry = new ZipEntry(name);
                zipEntry.setTime(0); // Reset date for build consistency
                zos.putNextEntry(zipEntry);
                Files.copy(new File(source).toPath(), zos);
                zos.closeEntry();
            }
        }
    }
}
