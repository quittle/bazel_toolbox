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
import org.apache.commons.io.FileUtils;

/**
 * Contains the main function and argument parsing capabilities
 */
public final class Main {
    private static final String ARG_SOURCES = "sources";
    private static final String ARG_STRIP_FIRST = "strip-first";
    private static final String ARG_STRIP_PREFIXES = "strip-prefixes";
    private static final String ARG_OUTPUT = "output";

    /** The ZIP format supports 1-1-1980 as the epoch start date. */
    private static final long EPOCH_DATE = 315532800000L;

    private static final Comparator<String> STRING_LENGTH_HIGH_TO_LOW_COMPARATOR =
            (final String a, final String b) -> b.length() - a.length();

    private static class Pair<A, B> {
        private final A a;
        private final B b;

        public Pair(final A a, final B b) {
            this.a = a;
            this.b = b;
        }

        public A getFirst() {
            return a;
        }

        public B getSecond() {
            return b;
        }
    }

    private static class StringPair extends Pair<String, String> {
        public StringPair(final String a, final String b) {
            super(a, b);
        }
    }

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

    @SuppressWarnings({"TypeParameterUnusedInFormals", "unchecked"})
    private static <T> T getOption(final CommandLine commandLine, final String arg) {
        try {
            return (T) commandLine.getParsedOptionValue(arg);
        } catch (final ParseException e) {
            throw new RuntimeException("Unable to parse arg: " + arg);
        }
    }

    private static String[] getOptionValuesDefault(final CommandLine commandLine, final String arg) {
        final String[] values = commandLine.getOptionValues(arg);
        if (values == null) {
            return new String[0];
        } else {
            return values;
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

        final String[] sources = getOptionValuesDefault(commandLine, ARG_SOURCES);
        final String[] stripFirst = getOptionValuesDefault(commandLine, ARG_STRIP_FIRST);
        final String[] stripPrefixes = getOptionValuesDefault(commandLine, ARG_STRIP_PREFIXES);
        final File output = getOption(commandLine, ARG_OUTPUT);

        Arrays.sort(stripFirst, STRING_LENGTH_HIGH_TO_LOW_COMPARATOR);
        Arrays.sort(stripPrefixes, STRING_LENGTH_HIGH_TO_LOW_COMPARATOR);

        try (final ZipOutputStream zos = new ZipOutputStream(new FileOutputStream(output))) {
            zos.setLevel(Deflater.NO_COMPRESSION);

            Arrays.stream(sources)
                .map((final String source) -> {
                    for (final String prefix : stripFirst) {
                        if (source.startsWith(prefix)) {
                            return new StringPair(source, source.substring(prefix.length()));
                        }
                    }
                    return new StringPair(source, source);
                })
                .map((final StringPair sourcePair) -> {
                    final String shortenedSource = sourcePair.getSecond();
                    for (final String prefix : stripPrefixes) {
                        if (shortenedSource.startsWith(prefix)) {
                            return new StringPair(sourcePair.getFirst(), shortenedSource.substring(prefix.length()));
                        }
                    }
                    return sourcePair;
                })
                .sorted((final StringPair a, final StringPair b) -> a.getSecond().compareTo(b.getSecond()))
                .forEach((final Pair<String, String> sourcePair) -> {
                    final File sourceFile = new File(sourcePair.getFirst());
                    final ZipEntry zipEntry = new ZipEntry(sourcePair.getSecond());
                    zipEntry.setTime(EPOCH_DATE); // Reset date for build consistency
                    zipEntry.setMethod(ZipEntry.STORED);
                    zipEntry.setSize(sourceFile.length());
                    zipEntry.setCompressedSize(sourceFile.length());
                    try {
                        zipEntry.setCrc(FileUtils.checksumCRC32(sourceFile));
                        zos.putNextEntry(zipEntry);
                        Files.copy(sourceFile.toPath(), zos);
                        zos.closeEntry();
                    } catch (final IOException e) {
                        throw new RuntimeException(e);
                    }
                });
        }
    }

    private Main() {}
}
