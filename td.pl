# PanLex expression text degradation.
# Original version by Jonathan Pool.
# Enhanced version with Indic script
# support, August 02013, by Yadav Gowda,
# further modified and edited by
# Jonathan Pool.

# create or replace function td (text)
# returns text language plperlu immutable as

use encoding 'utf8';
# Make Perl interpret the script and standard
# files as UTF-8 rather than bytes.

use strict;
# Require typing.

use Unicode::Normalize;
# Import a function to perform character
# normalization.

my $td = (&NFKD ($_[0]));
# Initialize the degradation of the specified
# text as its compatibility decomposition
# (Normalization Form KD).

$td = (lc $td);
# Make it lower-case.

$td =~ s/ı/i/g;
# Replace all instances of “ı” with “i” in it.

$td =~ s/ß/ss/g;
# Replace all instances of “ß” with “ss” in it.

if ($td !~ /[\x{0900}-\x{0D7F}]/) {
# If it contains no Indic character:

    $td =~ s/[^\p{Ll}\p{Lo}\p{Nd}]//g;
    # Remove all non-basic characters from the degradation.
    # This leaves undegraded many characters that
    # arguably merit degradation and does not deal with
    # transscriptal confusion or transliteration.

}

elsif ($td =~ /[\x{0980}-\x{09FF}]/) {
# Otherwise, if it contains any Bengali character:

    $td =~ s/\x{09CD}\x{09B0}[\x{09BF}\x{09C1}]/\x{09C3}/g;
    # Replace all instances of VIRAMA + RA +
    # VOWEL SIGN I or U with VOCALIC R.

    $td =~ s/[\x{0999}\x{099E}\x{09A3}\x{09A8}\x{09A9}\x{09AE}]
        (?![\x{09BE}-\x{09CC}\x{09D6}\x{09D7}\x{09E2}\x{09E3}])
        /\x{0982}/gx;
    # Replace all instances of a nasal not followed
    # by a vowel with ANUSVARA.

    my %usefor = (
    # Identify a table of context-independent
    # conversions of single characters to single
    # characters, with target characters as keys
    # and sets of source characters as values.
    # Specifically:

        "\x{0982}" => "\x{0981}",
        # Convert CHANDRABINDU to ANUSVARA.

        "\x{0985}" => "\x{0986}",
        "\x{0987}" => "\x{0988}",
        "\x{0989}" => "\x{098A}",
        "\x{098B}" => "\x{09E0}",
        "\x{098C}" => "\x{09E1}",
        "\x{098F}" => "\x{0990}",
        "\x{0993}" => "\x{0994}",
        # Convert a long or short vowel to the
        # corresponding basic vowel.

        "\x{09A1}" => "\x{09DC}",
        "\x{09A2}" => "\x{09DD}",
        "\x{09A4}" => "\x{09CE}",
        "\x{09AF}" => "\x{09DF}",
        "\x{09A2}" => "\x{09DD}",
        "\x{09B0}" => "[\x{09F0}\x{09F1}]",
        # Convert a consonant with a diacritical mark
        # to the corresponding consonant without one.

        "\x{09B8}" => "[\x{09B6}\x{09B7}]",
        # Convert SHA or SSA to SA.

        "\x{09BF}" => "\x{09C0}",
        "\x{09C1}" => "\x{09C2}",
        "\x{09C3}" => "\x{09C4}",
        "\x{09C7}" => "\x{09C8}",
        "\x{09CB}" => "\x{09C7}\x{09BE}|\x{09D7}",
        "\x{09E2}" => "\x{09E3}"
        # Convert a dependent short or long vowel to 
        # the corresponding dependent basic vowel.

    );

    for my $key (keys %usefor) { $td =~ s/$usefor{$key}/$key/g; }
    # Make the replacements.

    $td =~ s/\x{0982}+/\x{0982}/g;
    # Collapse all sequences of 2 or more
    # ANUSVARA.

    $td =~ s/[^\x{0982}\x{09BF}\x{09C1}\x{09C3}\x{09C7}\x{09CB}\x{09E2}\p{Ll}\p{Lo}\p{Nd}]//g;
    # Delete all non-basic characters.

}

elsif ($td =~ /[\x{0A00}-\x{0A7F}]/) {
# Otherwise, if it contains any Gurmukhi character:

    $td =~ s/[\x{0A19}\x{0A1E}\x{0A23}\x{0A28}\x{0A29}\x{0A2E}]
            (?![\x{0A3e}-\x{0A4c}])
            /\x{0A02}/gx;
    # Replace all instances of a nasal not followed
    # by a vowel with BINDI.

    my %usefor = (
    # Identify a table of context-independent
    # conversions of single characters to single
    # characters, with target characters as keys
    # and sets of source characters as values.
    # Specifically:

        "\x{0A02}" => "[\x{0A00}\x{0A01}\x{0A70}]",
        # Convert ADAK BINDI or TIPPI to BINDI.

        "\x{0A05}" => "\x{0A06}",
        "\x{0A07}" => "\x{0A08}",
        "\x{0A09}" => "\x{0A0A}",
        "\x{0A0F}" => "\x{0A10}",
        "\x{0A13}" => "\x{0A14}",
        # Convert a long or short vowel to the
        # corresponding basic vowel.

        "\x{0A16}" => "\x{0A59}",
        "\x{0A17}" => "\x{0A5A}",
        "\x{0A1C}" => "\x{0A5B}",
        "\x{0A2B}" => "\x{0A5E}",
        "\x{0A32}" => "\x{0A33}",
        # Convert a consonant with a diacritical mark
        # to the corresponding consonant without one.

        "\x{0A38}" => "\x{0A36}",
        # Convert SHA to SA.

        "\x{0A3F}" => "\x{0A40}",
        "\x{0A41}" => "\x{0A42}",
        "\x{0A47}" => "\x{0A48}",
        "\x{0A4B}" => "\x{0A4C}",
        # Convert a dependent short or long vowel to 
        # the corresponding dependent basic vowel.

    );

    for my $key (keys %usefor) { $td =~ s/$usefor{$key}/$key/g; }
    # Make the replacements.

    $td =~ s/\x{0A02}+/\x{0A02}/g;
    # Collapse all sequences of 2 or more
    # BINDI.

    $td =~ s/[^\x{0A02}\x{0A3F}\x{0A41}\x{0A47}\x{0A4B}\x{0A71}\p{Ll}\p{Lo}\p{Nd}]//g;
    # Delete all non-basic characters.

}

elsif ($td =~ /[\x{0A80}-\x{0AFF}]/) {
# Otherwise, if it contains any Gujarati character:

    $td =~ s/\x{0ACD}\x{0AB0}[\x{0ABF}\x{0AC1}]/\x{0AC3}/g;
    # Replace all instances of VIRAMA + RA +
    # VOWEL SIGN I or U with VOCALIC R.

    $td =~ s/[\x{0A99}\x{0A9E}\x{0AA3}\x{0AA8}\x{0AAE}]
        (?![\x{0ABE}-\x{0ACC}\x{0AE2}\x{0AE3}])
        /\x{0A82}/gx;
    # Replace all instances of a nasal not followed
    # by a vowel with ANUSVARA.

    my %usefor = (
    # Identify a table of context-independent
    # conversions of single characters to single
    # characters, with target characters as keys
    # and sets of source characters as values.
    # Specifically:

        "\x{0A85}" => "\x{0A86}",
        "\x{0A87}" => "\x{0A88}",
        "\x{0A89}" => "\x{0A8A}",
        "\x{0A8B}" => "\x{0AE0}",
        "\x{0A8C}" => "\x{0AE1}",
        "\x{0A8F}" => "[\x{0A8D}\x{0A90}]",
        "\x{0A93}" => "[\x{0A91}\x{0A94}]",
        # Convert a long vowel to the corresponding
        # basic vowel.

        "\x{0AB0}" => "\x{0AB1}",
        "\x{0AB3}" => "\x{0ADE}",
        # Convert a deprecated consonant to the
        # corresponding stardard one.

        "\x{0AB8}" => "[\x{0AB6}\x{0AB7}]",
        # Convert SHA or SSA to SA.

        "\x{0ABF}" => "\x{0AC0}",
        "\x{0AC1}" => "\x{0AC2}",
        "\x{0AC3}" => "\x{0AC4}",
        "\x{0AC7}" => "[\x{0AC5}\x{0AC8}]",
        "\x{0ACB}" => "[\x{0AC9}\x{0ACC}]",
        "\x{0AE2}" => "\x{0AE3}"
        # Convert a dependent long vowel to the
        # corresponding dependent basic vowel.

    );

    for my $key (keys %usefor) { $td =~ s/$usefor{$key}/$key/g; }
    # Make the replacements.

    $td =~ s/\x{0A82}+/\x{0A82}/g;
    # Collapse all sequences of 2 or more
    # ANUSVARA.

    $td =~ s/[^\x{0A82}\x{0ABF}\x{0AC1}\x{0AC3}\x{0AC7}\x{0ACB}\x{0AE2}\p{Ll}\p{Lo}\p{Nd}]//g;
    # Delete all non-basic characters.

}

elsif ($td =~ /[\x{0B00}-\x{0B7F}]/) {
# Otherwise, if it contains any Oriya character:

    $td =~ s/\x{0B4D}\x{0B30}[\x{0B3F}\x{0B41}]/\x{0B43}/g;
    # Replace all instances of VIRAMA + RA +
    # VOWEL SIGN I or U with VOCALIC R.

    $td =~ s/[\x{0B19}\x{0B1E}\x{0B23}\x{0B28}\x{0B29}\x{0B2E}]
        (?![\x{0B3E}-\x{0B4C}\x{0B56}\x{0B57}\x{0B62}\x{0B63}])
        /\x{0B02}/gx;
    # Replace all instances of a nasal not followed
    # by a vowel with ANUSVARA.

    my %usefor = (
    # Identify a table of context-independent
    # conversions of single characters to single
    # characters, with target characters as keys
    # and sets of source characters as values.
    # Specifically:

        "\x{0B02}" => "[\x{0B00}\x{0B01}]",
        # Convert CHANDRABINDU or INVERTED CHANDRABINDU
        # to ANUSVARA.

        "\x{0B05}" => "\x{0B06}",
        "\x{0B07}" => "\x{0B08}",
        "\x{0B09}" => "\x{0B0A}",
        "\x{0B0B}" => "\x{0B60}",
        "\x{0B0C}" => "\x{0B61}",
        "\x{0B0F}" => "\x{0B10}",
        "\x{0B13}" => "\x{0B14}",
        # Convert a long or short vowel to the
        # corresponding basic vowel.

        "\x{0B21}" => "\x{0B5C}",
        "\x{0B22}" => "\x{0B5D}",
        "\x{0B2C}" => "[\x{0B35}\x{0B71}]",
        "\x{0B2F}" => "\x{0B5F}",
        "\x{0B22}" => "\x{0B5D}",
        # Convert a consonant with a diacritical mark
        # to the corresponding consonant without one.

        "\x{0B38}" => "[\x{0B36}\x{0B37}]",
        # Convert SHA or SSA to SA.

        "\x{0B3F}" => "\x{0B40}",
        "\x{0B41}" => "\x{0B42}",
        "\x{0B43}" => "\x{0B44}",
        "\x{0B47}" => "\x{0B48}",
        "\x{0B4B}" => "\x{0B47}\x{0B3E}|\x{0B57}",
        "\x{0B62}" => "\x{0B63}"
        # Convert a dependent short or long vowel to 
        # the corresponding dependent basic vowel.

    );

    for my $key (keys %usefor) { $td =~ s/$usefor{$key}/$key/g; }
    # Make the replacements.

    $td =~ s/\x{0B02}+/\x{0B02}/g;
    # Collapse all sequences of 2 or more
    # ANUSVARA.

    $td =~ s/[^\x{0B02}\x{0B3F}\x{0B41}\x{0B43}\x{0B47}\x{0B4B}\x{0B62}\p{Ll}\p{Lo}\p{Nd}]//g;
    # Delete all non-basic characters.

}

elsif ($td =~ /[\x{0B80}-\x{0BFF}]/) {
# Otherwise, if it contains any Tamil character:

    my %usefor = (
    # Identify a table of context-independent
    # conversions of single characters to single
    # characters, with target characters as keys
    # and sets of source characters as values.
    # Specifically:

        "\x{0B85}" => "\x{0C86}",
        "\x{0B87}" => "\x{0B88}",
        "\x{0B89}" => "\x{0B8A}",
        "\x{0B8E}" => "\x{0B8F}",
        "\x{0B92}" => "\x{0B93}",
        # Convert a long vowel to the corresponding
        # basic vowel.

        "\x{0B95}" => "\x{0BB9}",
        "\x{0B9C}" => "[\x{0B9A}\x{0BB6}-\x{0BB8}]",
        # Convert a Grantha letter to the corresponding
        # Tamil one.

        "\x{0BBF}" => "\x{0BC0}",
        "\x{0BC1}" => "\x{0BC2}",
        "\x{0BC6}" => "\x{0BC7}",
        "\x{0BCA}" => "\x{0BCB}"
        # Convert a dependent long vowel to the
        # corresponding dependent basic vowel.

    );

    for my $key (keys %usefor) { $td =~ s/$usefor{$key}/$key/g; }
    # Make the replacements.

    $td =~ s/[^\x{0BBF}\x{0BC1}\x{0BC6}\x{0BC8}\x{0BCA}\x{0BCC}\x{0BD7}\p{Ll}\p{Lo}\p{Nd}]//g;
    # Delete all non-basic characters.

}

elsif ($td =~ /[\x{0C00}-\x{0C7F}]/) {
# Otherwise, if it contains any Telugu character:

    $td =~ s/\x{0C4D}\x{0C30}[\x{0C3F}\x{0C41}]/\x{0C43}/g;
    # Replace all instances of VIRAMA + RA +
    # VOWEL SIGN I or U with VOCALIC R.

    $td =~ s/[\x{0C19}\x{0C1E}\x{0C23}\x{0C28}\x{0C2E}]
            (?![\x{0C3e}-\x{0C4c}\x{0C62}\x{0C63}])
            /\x{0C02}/gx;
    # Replace all instances of a nasal not followed
    # by a vowel with ANUSVARA.

    my %usefor = (
    # Identify a table of context-independent
    # conversions of single characters to single
    # characters, with target characters as keys
    # and sets of source characters as values.
    # Specifically:

        "\x{0C02}" => "\x{0C01}",
        # Convert CHANDRABINDU to ANUSVARA.

        "\x{0C05}" => "\x{0C06}",
        "\x{0C07}" => "\x{0C08}",
        "\x{0C09}" => "\x{0C0A}",
        "\x{0C0B}" => "\x{0C60}",
        "\x{0C0C}" => "\x{0C61}",
        "\x{0C0E}" => "\x{0C0F}",
        "\x{0C12}" => "\x{0C13}",
        # Convert a long vowel to the corresponding
        # basic vowel.

        "\x{0C15}" => "\x{0C16}",
        "\x{0C17}" => "\x{0C18}",
        "\x{0C1A}" => "[\x{0C1B}\x{0C58}]",
        "\x{0C1C}" => "[\x{0C1D}\x{0C59}]",
        "\x{0C1F}" => "\x{0C20}",
        "\x{0C21}" => "\x{0C22}",
        "\x{0C24}" => "\x{0C25}",
        "\x{0C26}" => "\x{0C27}",
        "\x{0C2A}" => "\x{0C2B}",
        "\x{0C2C}" => "\x{0C2D}",
        "\x{0C30}" => "\x{0C31}",
        # Convert an aspirated or deprecated consonant
        # to the corresponding basic or standard one.

        "\x{0C38}" => "[\x{0C36}\x{0C37}]",
        # Convert SHA or SSA to SA.

        "\x{0C3F}" => "\x{0C40}",
        "\x{0C41}" => "\x{0C42}",
        "\x{0C43}" => "\x{0C44}",
        "\x{0C46}" => "\x{0C47}",
        "\x{0D4A}" => "\x{0C4B}",
        "\x{0C62}" => "\x{0C63}"
        # Convert a dependent long vowel to the
        # corresponding dependent basic vowel.

    );

    for my $key (keys %usefor) { $td =~ s/$usefor{$key}/$key/g; }
    # Make the replacements.

    $td =~ s/\x{0C02}+/\x{0C02}/g;
    # Collapse all sequences of 2 or more
    # ANUSVARA.

    $td =~ s/[^\x{0C02}\x{0C3F}\x{0C41}\x{0C43}\x{0C46}\x{0C48}\x{0C4A}\x{0C4C}\x{0C62}\p{Ll}\p{Lo}\p{Nd}]//g;
    # Delete all non-basic characters.

}

elsif ($td =~ /[\x{0C80}-\x{0CFF}]/) {
# Otherwise, if it contains any Kannada character:

    $td =~ s/\x{0CCD}\x{0CB0}[\x{0CBF}\x{0CC1}]/\x{0CC3}/g;
    # Replace all instances of VIRAMA + RA +
    # VOWEL SIGN I or U with VOCALIC R.

    $td =~ s/[\x{0C99}\x{0C9E}\x{0CA3}\x{0CA8}\x{0CAE}]
        (?![\x{0CBE}-\x{0CCC}\x{0CE2}\x{0CE3}])
        /\x{0C82}/gx;
    # Replace all instances of a nasal not followed
    # by a vowel with ANUSVARA.

    my %usefor = (
    # Identify a table of context-independent
    # conversions of single characters to single
    # characters, with target characters as keys
    # and sets of source characters as values.
    # Specifically:

        "\x{0C85}" => "\x{0C86}",
        "\x{0C87}" => "\x{0C88}",
        "\x{0C89}" => "\x{0C8A}",
        "\x{0C8B}" => "\x{0CE0}",
        "\x{0C8C}" => "\x{0CE1}",
        "\x{0C8E}" => "\x{0C8F}",
        "\x{0C92}" => "\x{0C93}",
        # Convert a long vowel to the corresponding
        # basic vowel.

        "\x{0C95}" => "\x{0C96}",
        "\x{0C97}" => "\x{0C98}",
        "\x{0C9A}" => "\x{0C9B}",
        "\x{0C9C}" => "\x{0C9D}",
        "\x{0C9F}" => "\x{0CA0}",
        "\x{0CA1}" => "\x{0CA2}",
        "\x{0CA4}" => "\x{0CA5}",
        "\x{0CA6}" => "\x{0CA7}",
        "\x{0CAA}" => "\x{0CAB}",
        "\x{0CAC}" => "\x{0CAD}",
        "\x{0CB0}" => "\x{0CB1}",
        "\x{0CB3}" => "\x{0CDE}",
        # Convert an aspirated or deprecated consonant
        # to the corresponding basic or standard one.

        "\x{0CB8}" => "[\x{0CB6}\x{0CB7}]",
        # Convert SHA or SSA to SA.

        "\x{0CBF}" => "\x{0CC0}",
        "\x{0CC1}" => "\x{0CC2}",
        "\x{0CC3}" => "\x{0CC4}",
        "\x{0CC6}" => "\x{0CC7}",
        "\x{0CCA}" => "\x{0CCB}",
        "\x{0CE2}" => "\x{0CE3}"
        # Convert a dependent long vowel to the
        # corresponding dependent basic vowel.

    );

    for my $key (keys %usefor) { $td =~ s/$usefor{$key}/$key/g; }
    # Make the replacements.

    $td =~ s/\x{0C82}+/\x{0C82}/g;
    # Collapse all sequences of 2 or more
    # ANUSVARA.

    $td =~ s/[^\x{0C82}\x{0CBF}\x{0CC1}\x{0CC3}\x{0CC6}\x{0CC8}\x{0CCA}\x{0CCC}\x{0CE2}\p{Ll}\p{Lo}\p{Nd}]//g;
    # Delete all non-basic characters.

}

elsif ($td =~ /[\x{0D00}-\x{0D7F}]/) {
# Otherwise, if it contains any Malayalam character:

    $td =~ s/\x{0D4D}\x{0D30}[\x{0D3F}\x{0D41}]/\x{0D43}/g;
    # Replace all instances of VIRAMA + RA +
    # VOWEL SIGN I or U with VOCALIC R.

    $td =~ s/[\x{0D19}\x{0D1E}\x{0D23}\x{0D28}\x{0D2E}]
        (?![\x{0D3E}-\x{0D4C}\x{0D62}\x{0D63}])
        /\x{0D02}/gx;
    # Replace all instances of a nasal not followed
    # by a vowel with ANUSVARA.

    my %usefor = (
    # Identify a table of context-independent
    # conversions of single characters to single
    # characters, with target characters as keys
    # and sets of source characters as values.
    # Specifically:

        "\x{0D02}" => "\x{0D01}",
        # Convert CHANDRABINDU to ANUSVARA.

        "\x{0D05}" => "\x{0D06}",
        "\x{0D07}" => "\x{0D08}",
        "\x{0D09}" => "\x{0D0A}",
        "\x{0D0B}" => "\x{0D60}",
        "\x{0D0C}" => "\x{0D61}",
        "\x{0D0E}" => "\x{0D0F}",
        "\x{0D12}" => "\x{0D13}",
        # Convert a long vowel to the corresponding
        # basic vowel.

        "\x{0D15}" => "\x{0D16}",
        "\x{0D17}" => "\x{0D18}",
        "\x{0D1A}" => "[\x{0D1B}\x{0D58}]",
        "\x{0D1C}" => "[\x{0D1D}\x{0D59}]",
        "\x{0D1F}" => "\x{0D20}",
        "\x{0D21}" => "\x{0D22}",
        "\x{0D24}" => "\x{0D25}",
        "\x{0D26}" => "\x{0D27}",
        "\x{0D2A}" => "\x{0D2B}",
        "\x{0D2C}" => "\x{0D2D}",
        "\x{0D30}" => "\x{0D31}",
        # Convert an aspirated or deprecated consonant
        # to the corresponding basic or standard one.

        "\x{0D38}" => "[\x{0D36}\x{0D37}]",
        # Convert SHA or SSA to SA.

        "\x{0D3F}" => "\x{0D40}",
        "\x{0D41}" => "\x{0D42}",
        "\x{0D43}" => "\x{0D44}",
        "\x{0D46}" => "\x{0D47}",
        "\x{0D4A}" => "\x{0D4B}",
        "\x{0D62}" => "\x{0D63}"
        # Convert a dependent long vowel to the
        # corresponding dependent basic vowel.

    );

    for my $key (keys %usefor) { $td =~ s/$usefor{$key}/$key/g; }
    # Make the replacements.

    $td =~ s/\x{0D02}+/\x{0D02}/g;
    # Collapse all sequences of 2 or more
    # ANUSVARA.

    $td =~ s/[^\x{0D02}\x{0D3F}\x{0D41}\x{0D43}\x{0D46}\x{0D48}\x{0D4A}\x{0D4C}\x{0D62}\p{Ll}\p{Lo}\p{Nd}]//g;
    # Delete all non-basic characters.

}

elsif ($td =~ /[\x{0900}-\x{097F}]/) {
# Otherwise, if it contains any Devanagari
# character:

    $td =~ s/\x{094D}\x{0930}\x{093F}/\x{0943}/g;
    # Replace all instances of VIRAMA + RA +
    # VOWEL SIGN I with VOCALIC R.

    $td =~ s/[\x{0919}\x{091E}\x{0923}\x{0928}\x{0929}\x{092E}]
        (?![\x{093E}-\x{094C}\x{094E}\x{094F}\x{0955}-\x{0957}\x{0962}\x{0963}])
        /\x{0902}/gx;
    # Replace all instances of a nasal not followed
    # by a vowel with ANUSVARA.

    my %usefor = (
    # Identify a table of context-independent
    # conversions of single characters to single
    # characters, with target characters as keys
    # and sets of source characters as values.
    # Specifically:

        "\x{0902}" => "[\x{0900}\x{0901}]",
        # Convert CHANDRABINDU or INVERTED CHANDRABINDU
        # to ANUSVARA.

        "\x{0905}" => "[\x{0904}\x{0906}\x{0972}]",
        "\x{0907}" => "\x{0908}",
        "\x{0909}" => "[\x{090A}\x{0976}\x{0977}]",
        "\x{090B}" => "\x{0960}",
        "\x{090C}" => "\x{0961}",
        "\x{090F}" => "[\x{090D}\x{090E}\x{0910}]",
        "\x{0913}" => "[\x{0911}\x{0912}\x{0914}\x{0973}\x{0974}\x{0975}]",
        # Convert a long or short vowel to the
        # corresponding basic vowel.

        "\x{0915}" => "\x{0958}",
        "\x{0916}" => "\x{0959}",
        "\x{0917}" => "[\x{095A}\x{097B}]",
        "\x{091C}" => "[\x{095B}\x{0979}\x{097C}]",
        "\x{0921}" => "[\x{095C}\x{097E}]",
        "\x{092F}" => "[\x{095F}\x{097A}]",
        "\x{0922}" => "\x{095D}",
        "\x{0928}" => "\x{0929}",
        "\x{092B}" => "\x{095E}",
        "\x{092C}" => "\x{097F}",
        "\x{0930}" => "\x{0931}",
        "\x{0933}" => "\x{0934}",
        # Convert a consonant with a diacritical mark
        # to the corresponding consonant without one.

        "\x{0938}" => "[\x{0936}\x{0937}]",
        # Convert SHA or SSA to SA.

        "\x{093F}" => "\x{0940}",
        "\x{0941}" => "[\x{0942}\x{0956}\x{0957}]",
        "\x{0943}" => "\x{0944}",
        "\x{0947}" => "[\x{0945}\x{0946}\x{0948}\x{0955}]",
        "\x{094B}" => "[\x{0949}\x{094A}\x{094C}\x{094F}]",
        "\x{0962}" => "\x{0963}"
        # Convert a dependent short or long vowel to 
        # the corresponding dependent basic vowel.

    );

    for my $key (keys %usefor) { $td =~ s/$usefor{$key}/$key/g; }
    # Make the replacements.

    $td =~ s/\x{0902}+/\x{0902}/g;
    # Collapse all sequences of 2 or more
    # ANUSVARA.

    $td =~ s/[^\x{0902}\x{093F}\x{0941}\x{0943}\x{0947}\x{094B}\x{0962}\p{Ll}\p{Lo}\p{Nd}]//g;
    # Delete all non-basic characters.

}

return $td;
# Return the degradation.