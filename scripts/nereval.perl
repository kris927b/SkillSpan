#!/usr/bin/perl -w
# File: nereval.perl: Evaluate result of processing GermEval 2014 NER shared task.
# Usage:     conlleval [-l] [-v] [-d delimiterTag] < file
#            (README: https://sites.google.com/site/germeval2014ner/evaluation/evaluation.pdf)
# Options:   -l: generate LaTeX output for tables.
#            -v: Add detailed additional output about found NE chunks.
#            -d: Alternative delimiter tag (default is TAB character)
# Note:      The file should contain lines with items separated
#            by $delimiter characters (default TAB). The final
#            four items should contain in the following order:
#            1. the correct tag for level 1
#            2. the correct tag for level 2
#            3. the guessed tag for level 1
#            4. the guessed tag for level 2.
#            Sentences should be separated from each other by empty lines.
# Url:       https://sites.google.com/site/germeval2014ner/data
# Started:   1998-09-25
# Version:   2014-05-19
# Authors:   Initial version: Erik Tjong Kim Sang <erikt@uia.ua.ac.be>
#            Current version: Max Kisselew (max.kisselew@ims.uni-stuttgart.de)

use strict;
use warnings;

my $false = 0;
my $true = 42;

my $boundary = "-X-";     # sentence boundary
my @correct = ("", "", "", "");      # current corpus chunk tag (I,O,B)
my @correctChunk = (0, 0, 0, 0);     # number of correctly identified chunks
my @correctTags = (0, 0, 0, 0);      # number of correct chunk tags
my @correctType = ("", "", "", "");         # type of current chunk tag (LOC,PER,etc.)
my @correctSpecialType = ("", "", "", "");  #
my $delimiter = "\\t";      # field delimiter (default)
my $FB1O = 0.0;            # FB1 score (Van Rijsbergen 1979)
my $FB1I = 0.0;            # FB1 score (Van Rijsbergen 1979)
my $firstItem;            # first feature (for sentence boundary checks)
my @foundCorrect = (0, 0, 0, 0);     # number of chunks in corpus
my @foundGuessed = (0, 0, 0, 0);     # number of identified chunks
my @guessed = ("", "", "", "");              # current guessed chunk tag
my @guessedType = ("", "", "", "");          # type of current guessed chunk tag
my @guessedSpecialType = ("", "", "", "");   #
my $i;                    # miscellaneous counter
my $b = 0;                # Upper boundary for a for loop.
my $linecounter = 0;

my @inCorrect = ($false, $false, $false, $false);   # currently processed chunk is correct until now
my @lastCorrect = ("O", "O", "O", "O");    # previous chunk tag in corpus

my @lastCorrectType = ("", "", "", ""); # type of previously identified chunk tag
my @lastCorrectSpecialType = ("", "", "", ""); # type of previously identified chunk tag
my @lastGuessed = ("O", "O", "O", "O");    # previously identified chunk tag
my @lastGuessedType = ("", "", "", ""); # type of previous chunk tag in corpus
my @lastGuessedSpecialType = ("", "", "", ""); # type of previous chunk tag in corpus
my $lastType;             # temporary storage for detecting duplicates
my $line;                 # line
my $linetext = "";
my $NEchunk = "";
my $nbrOfFeatures = -1;   # number of features per line
#!!!my $precision = 0.0;      # precision score
my @precision = (0.0, 0.0, 0.0, 0.0); # precision score
my $precisionO = 0.0;      # precision score
my $precisionI = 0.0;      # precision score
my $oTag = "O";           # outside tag, default O
my @recall = (0.0, 0.0, 0.0, 0.0);     # recall score
my $recallO = 0.0;         # recall score
my $recallI = 0.0;         # recall score
my $tokenCounter = 0;     # token counter (ignores sentence breaks)
my $precisionEv1 = 0.0;
my $recallEv1 = 0.0;
my @FB1 = (0.0, 0.0, 0.0, 0.0);
my $FB1Ev1 = 0.0;
my $precisionEv2 = 0.0;
my $recallEv2 = 0.0;
my $FB1Ev2 = 0.0;

# LaTeX output variables.
my $chunkType = "";
my $latexTypes = "";
my $latexTemp = "";

# Command line arguments.
my $latex = 0;            # Generate LaTeX formatted output.
my $verbose = 0;          # Output detailed information.

#!!! correctChunk should get another name because confusing.
my %correctChunkOs = ();    # number of correctly identified chunks per type
my %correctChunkIs = ();    # number of correctly identified chunks per type
my %correctChunkOl = ();    # number of correctly identified chunks per type
my %correctChunkIl = ();    # number of correctly identified chunks per type
my %foundCorrectOs = ();    # number of chunks in corpus per type
my %foundCorrectIs = ();    # number of chunks in corpus per type
my %foundCorrectOl = ();    # number of chunks in corpus per type
my %foundCorrectIl = ();    # number of chunks in corpus per type
my %foundGuessedOs = ();    # number of identified chunks per type
my %foundGuessedIs = ();    # number of identified chunks per type
my %foundGuessedOl = ();    # number of identified chunks per type
my %foundGuessedIl = ();    # number of identified chunks per type

#!!! Hashes to keep track of the captured NE chunks.
my @NEchunksOs = ();
my @NEchunksIs = ();
my @NEchunksOl = ();
my @NEchunksIl = ();

my @features;             # features on line
my @sortedTypes;          # sorted list of chunk type names

my @outer_strict = ("strict", $inCorrect[0], $correctTags[0],
  $lastCorrect[0], $correct[0], $lastCorrectType[0], $correctType[0], $lastCorrectSpecialType[0], $correctSpecialType[0],
  $lastGuessed[0], $guessed[0], $lastGuessedType[0], $guessedType[0], $lastGuessedSpecialType[0], $guessedSpecialType[0],
  $foundCorrect[0], $foundGuessed[0], $correctChunk[0], \%correctChunkOs, \%foundCorrectOs, \%foundGuessedOs,
  $linetext, $NEchunk, \@NEchunksOs);

my @inner_strict = ("strict", $inCorrect[1], $correctTags[1],
  $lastCorrect[1], $correct[1], $lastCorrectType[1], $correctType[1], $lastCorrectSpecialType[1], $correctSpecialType[1],
  $lastGuessed[1], $guessed[1], $lastGuessedType[1], $guessedType[1], $lastGuessedSpecialType[1], $guessedSpecialType[1],
  $foundCorrect[1], $foundGuessed[1], $correctChunk[1], \%correctChunkIs, \%foundCorrectIs, \%foundGuessedIs,
  $linetext, $NEchunk, \@NEchunksIs);

my @outer_loose = ("loose", $inCorrect[2], $correctTags[2],
  $lastCorrect[2], $correct[2], $lastCorrectType[2], $correctType[2], $lastCorrectSpecialType[2], $correctSpecialType[2],
  $lastGuessed[2], $guessed[2], $lastGuessedType[2], $guessedType[2], $lastGuessedSpecialType[2], $guessedSpecialType[2],
  $foundCorrect[2], $foundGuessed[2], $correctChunk[2], \%correctChunkOl, \%foundCorrectOl, \%foundGuessedOl,
  $linetext, $NEchunk, \@NEchunksOl);

my @inner_loose = ("loose", $inCorrect[3], $correctTags[3],
  $lastCorrect[3], $correct[3], $lastCorrectType[3], $correctType[3], $lastCorrectSpecialType[3], $correctSpecialType[3],
  $lastGuessed[3], $guessed[3], $lastGuessedType[3], $guessedType[3], $lastGuessedSpecialType[3], $guessedSpecialType[3],
  $foundCorrect[3], $foundGuessed[3], $correctChunk[3], \%correctChunkIl, \%foundCorrectIl, \%foundGuessedIl,
  $linetext, $NEchunk, \@NEchunksIl);

# sanity check
while (@ARGV and $ARGV[0] =~ /^-/) {
   if ($ARGV[0] eq "-l") { $latex = 1; shift(@ARGV); }
   elsif ($ARGV[0] eq "-v") { $verbose = 1; shift(@ARGV); }
   elsif ($ARGV[0] eq "-d") {
      shift(@ARGV);
      if (not defined $ARGV[0]) {
         die "conlleval: -d requires delimiter character";
      }
      $delimiter = shift(@ARGV);
   } else { die "conlleval: unknown argument $ARGV[0]\n"; }
}
if (@ARGV) { die "conlleval: unexpected command line argument\n"; }

# process input
while (<STDIN>) {
   chomp($line = $_);

   #!!! In case that the input file has \r\n line endings.
   if ($line =~ /\r$/) {
     chop $line;
   }

   $linecounter++;
   #!!! max
   #!!! Skip comments and empty lines.
   if ($line =~ /^#/ or $line =~ /^$/ or $line =~ /^\t/) {next;}
   #!!! max

   @features = split(/$delimiter/,$line);

   #!!! max
   #print($line . "\n");
   #print(@features . "\n");
   #print($#features . "\n");
   #print($delimiter . "\n");
   #!!! max

   if ($nbrOfFeatures < 0) { $nbrOfFeatures = $#features; }
   elsif ($nbrOfFeatures != $#features and @features != 0) {
      printf STDERR "unexpected number of features: %d (%d)\n",
         $#features+1,$nbrOfFeatures+1;
      exit(1);
   }

   #!!! max: Probably unnecessary.
   if (@features == 0 or
       $features[0] eq $boundary) { @features = ($boundary,"O","O"); }

   #!!! max: 2 replaced by 6.
   if (@features < 6) {
      if ($line !~ /^$/) {
        die "conlleval: unexpected number of features in line $line\n";
      }
   }

   #!!! Store current line in array for each eval mode.
   $outer_strict[21] = $line;
   $inner_strict[21] = $line;
   $outer_loose[21] = $line;
   $inner_loose[21] = $line;

   #!!!=========================================================================
   #!!! Extract correct and guessed tags.
   #!!!=========================================================================
   #!!! Guessed inner tag.
   if ($features[$#features] =~ /^([^-]*)-(.+?)(deriv|part)?$/) {

      $inner_strict[10] = $1;
      $inner_loose[10] = $1;
      $inner_strict[12] = $2;
      $inner_loose[12] = $2;

      if (defined $3) {
        $inner_strict[14] = $3;
        $inner_loose[14] = $3;
      } else {
        $inner_strict[14] = "";
        $inner_loose[14] = "";
      }
   } else {
      $inner_strict[10] = $features[$#features];
      $inner_loose[10] = $features[$#features];
      $inner_strict[12] = "";
      $inner_loose[12] = "";
      $inner_strict[14] = "";
      $inner_loose[14] = "";
   }

   if (&check_labels($inner_strict[10], $inner_strict[12], $inner_strict[14], $line) == 0) {
     exit();
   }

   pop(@features);

   #!!! Guessed outer tag.
   if ($features[$#features] =~ /^([^-]*)-(.+?)(deriv|part)?$/) {

      $outer_strict[10] = $1;
      $outer_loose[10] = $1;
      $outer_strict[12] = $2;
      $outer_loose[12] = $2;

      if (defined $3) {
        $outer_strict[14] = $3;
        $outer_loose[14] = $3;
      } else {
        $outer_strict[14] = "";
        $outer_loose[14] = "";
      }
   } else {
      $outer_strict[10] = $features[$#features];
      $outer_loose[10] = $features[$#features];
      $outer_strict[12] = "";
      $outer_loose[12] = "";
      $outer_strict[14] = "";
      $outer_loose[14] = "";
   }

   if (&check_labels($outer_strict[10], $outer_strict[12], $outer_strict[14], $line) == 0) {
     exit();
   }

   pop(@features);

   #!!! Correct inner tag.
   if ($features[$#features] =~ /^([^-]*)-(.+?)(deriv|part)?$/) {

      $inner_strict[4] = $1;
      $inner_loose[4] = $1;
      $inner_strict[6] = $2;
      $inner_loose[6] = $2;
      if (defined $3) {
        $inner_strict[8] = $3;
        $inner_loose[8] = $3;
      } else {
        $inner_strict[8] = "";
        $inner_loose[8] = "";
      }
   } else {
      $inner_strict[4] = $features[$#features];
      $inner_loose[4] = $features[$#features];
      $inner_strict[6] = "";
      $inner_loose[6] = "";
      $inner_strict[8] = "";
      $inner_loose[8] = "";
   }

   if (&check_labels($inner_strict[4], $inner_strict[6], $inner_strict[8], $line) == 0) {
     exit();
   }

   pop(@features);

   #!!! Correct outer tag.
   if ($features[$#features] =~ /^([^-]*)-(.+?)(deriv|part)?$/) {

      $outer_strict[4] = $1;
      $outer_loose[4] = $1;
      $outer_strict[6] = $2;
      $outer_loose[6] = $2;
      if (defined $3) {
         $outer_strict[8] = $3;
         $outer_loose[8] = $3;
      } else {
         $outer_strict[8] = "";
         $outer_loose[8] = "";
      }
   } else {
      $outer_strict[4] = $features[$#features];
      $outer_loose[4] = $features[$#features];
      $outer_strict[6] = "";
      $outer_loose[6] = "";
      $outer_strict[8] = "";
      $outer_loose[8] = "";
   }

   if (&check_labels($outer_strict[4], $outer_strict[6], $outer_strict[8], $line) == 0) {
     exit();
   }

   pop(@features);

#  ($guessed,$guessedType) = split(/-/,pop(@features));
#  ($correct,$correctType) = split(/-/,pop(@features));
   #!!! max: Probably not necessary.
   #!!!$guessedType = $guessedType ? $guessedType : "";
   #!!!$correctType = $correctType ? $correctType : "";
   $firstItem = shift(@features);

   #!!!=========================================================================

   # 1999-06-26 sentence breaks should always be counted as out of chunk
   #!!!if ( $firstItem eq $boundary ) { $guessed = "O"; }

   #!!!print "==> $features[0]\n";
   #!!!print "@outer_strict[3]\n";
   #!!! Outer chunks, strict.
   @outer_strict = &update_per_line(@outer_strict);
   #!!!print "@outer_strict[3]\n";

   #!!! Inner chunks, strict.
   @inner_strict = &update_per_line(@inner_strict);

   #!!! Outer chunks, loose.
   @outer_loose = &update_per_line(@outer_loose);

   #!!! Inner chunks, loose.
   @inner_loose = &update_per_line(@inner_loose);

   $tokenCounter++;
}

#!!! Consider the last NE chunk of input file since it cannot be pushed an more
#!!! in the update_per_line subroutine.
if ($outer_strict[22] ne "") {
  push(@{$outer_strict[23]}, $outer_strict[22]);
}
if ($inner_strict[22] ne "") {
  push(@{$inner_strict[23]}, $inner_strict[22]);
}
if ($outer_loose[22] ne "") {
  push(@{$outer_loose[23]}, $outer_loose[22]);
}
if ($inner_loose[22] ne "") {
  push(@{$inner_loose[23]}, $inner_loose[22]);
}

## compute overall precision, recall and FB1 (default values are 0.0)

#!!! Evaluation Metric 1: Strict evaluation: Compute M1 UNION M2 precision, recall and FB1 (default values are 0.0)
#!!!$precisionEv1 = 100*($correctChunk[0]+$correctChunk[1])/($foundGuessed[0]+$foundGuessed[1]) if ($foundGuessed[0] > 0 or $foundGuessed[1] > 0);
$precisionEv1 = 100*($outer_strict[17]+$inner_strict[17])/($outer_strict[16]+$inner_strict[16]) if ($outer_strict[16] > 0 or $inner_strict[16] > 0);
#!!!$recallEv1 = 100*($correctChunk[0]+$correctChunk[1])/($foundCorrect[0]+$foundCorrect[1]) if ($foundCorrect[0] > 0 or $foundCorrect[1] > 0);
$recallEv1 = 100*($outer_strict[17]+$inner_strict[17])/($outer_strict[15]+$inner_strict[15]) if ($outer_strict[15] > 0 or $inner_strict[15] > 0);
$FB1Ev1 = 2*$precisionEv1*$recallEv1/($precisionEv1+$recallEv1) if ($precisionEv1+$recallEv1 > 0);

#!!! Evaluation Metric 2: Loose, combined evaluation.
#!!!$precisionEv2 = 100*($correctChunk[2]+$correctChunk[3])/($foundGuessed[2]+$foundGuessed[3]) if ($foundGuessed[2] > 0 or $foundGuessed[3] > 0);
$precisionEv2 = 100*($outer_loose[17]+$inner_loose[17])/($outer_loose[16]+$inner_loose[16]) if ($outer_loose[16] > 0 or $inner_loose[16] > 0);
#!!!$recallEv2 = 100*($correctChunk[2]+$correctChunk[3])/($foundCorrect[2]+$foundCorrect[3]) if ($foundCorrect[2] > 0 or $foundCorrect[3] > 0);
$recallEv2 = 100*($outer_loose[17]+$inner_loose[17])/($outer_loose[15]+$inner_loose[15]) if ($outer_loose[15] > 0 or $inner_loose[15] > 0);
$FB1Ev2 = 2*$precisionEv2*$recallEv2/($precisionEv2+$recallEv2) if ($precisionEv2+$recallEv2 > 0);

#!!! Evaluation Metric 3: Strict, separate evaluation.
# compute M1 (outer tags) precision, recall and FB1 (default values are 0.0)
$precisionO = 100*$outer_strict[17]/$outer_strict[16] if ($outer_strict[16] > 0);
$recallO = 100*$outer_strict[17]/$outer_strict[15] if ($outer_strict[15] > 0);
$FB1O = 2*$precisionO*$recallO/($precisionO+$recallO) if ($precisionO+$recallO > 0);

# compute M2 (inner tags) precision, recall and FB1 (default values are 0.0)
$precisionI = 100*$inner_strict[17]/$inner_strict[16] if ($inner_strict[16] > 0);
$recallI = 100*$inner_strict[17]/$inner_strict[15] if ($inner_strict[15] > 0);
$FB1I = 2*$precisionI*$recallI/($precisionI+$recallI) if ($precisionI+$recallI > 0);

#!!!
# $correctChunk (17) = TP
# $foundGuessed (16) = TP + FP
# $foundCorrect (15) = TP + FN

if ($verbose) {
  printf "correctTags: %d\n",($outer_strict[2]+$inner_strict[2])/2;

  # Numbers of true positives, false positives and false negatives.
  printf "Level 1\tstrict\tloose\n";
  printf "TP\t%d\t%d\n",$outer_strict[17],$outer_loose[17];
  printf "FP\t%d\t%d\n",$outer_strict[16]-$outer_strict[17],$outer_loose[16]-$outer_loose[17];
  printf "FN\t%d\t%d\n\n",$outer_strict[15]-$outer_strict[17],$outer_loose[15]-$outer_loose[17];
  printf "Level 2\tstrict\tloose\n";
  printf "TP\t%d\t%d\n",$inner_strict[17],$inner_loose[17];
  printf "FP\t%d\t%d\n",$inner_strict[16]-$inner_strict[17],$inner_loose[16]-$inner_loose[17];
  printf "FN\t%d\t%d\n\n",$inner_strict[15]-$inner_strict[17],$inner_loose[15]-$inner_loose[17];

  # Print all found NE chunks.
  print "> Found NE chunks from level 1 (strict):\n";
  foreach (@{$outer_strict[23]}) {
    print $_ . "\n";
  }

  print "> Found NE chunks from level 2 (strict):\n";
  foreach (@{$inner_strict[23]}) {
    print $_ . "\n";
  }

  print "> Found NE chunks from level 1 (loose):\n";
  foreach (@{$outer_loose[23]}) {
    print $_ . "\n";
  }

  print "> Found NE chunks from level 2 (loose):\n";
  foreach (@{$inner_loose[23]}) {
    print $_ . "\n";
  }
}

# Print overall performance
#!!!printf "\nProcessed $tokenCounter tokens with $outer_strict[15] outer and $inner_strict[15] inner phrases;\n";
printf "STRICT: Found: $outer_strict[16] outer and $inner_strict[16] inner phrases; Gold: $outer_strict[15] (outer) and $inner_strict[15] (inner).\n";
printf "LOOSE: Found: $outer_loose[16] outer and $inner_loose[16] inner phrases; Gold: $outer_loose[15] (outer) and $inner_loose[15] (inner).\n";

if ($tokenCounter > 0) {
  print "\n1. Strict, Combined Evaluation (official):\n";
  printf "Accuracy: %6.2f%%;\n",100*(($outer_strict[2]+$inner_strict[2])/2)/$tokenCounter;
  printf "Precision: %6.2f%%;\n",$precisionEv1;
  printf "Recall: %6.2f%%;\n",$recallEv1;
  printf "FB1: %6.2f\n",$FB1Ev1;

  print "\n2. Loose, Combined Evaluation:\n";
  printf "Accuracy: %6.2f%%;\n",100*(($outer_loose[2]+$inner_loose[2])/2)/$tokenCounter;
  printf "Precision: %6.2f%%;\n",$precisionEv2;
  printf "Recall: %6.2f%%;\n",$recallEv2;
  printf "FB1: %6.2f\n",$FB1Ev2;

  print "\n3.1 Per-Level Evaluation (outer chunks):\n";
  printf "Accuracy: %6.2f%%;\n",100*($outer_strict[2]/$tokenCounter);
  printf "Precision: %6.2f%%;\n",$precisionO;
  printf "Recall: %6.2f%%;\n",$recallO;
  printf "FB1: %6.2f\n",$FB1O;

  print "\n3.2 Per-Level Global Evaluation (inner chunks):\n";
  printf "Accuracy: %6.2f%%;\n",100*($inner_strict[2]/$tokenCounter);
  printf "Precision: %6.2f%%;\n",$precisionI;
  printf "Recall: %6.2f%%;\n",$recallI;
  printf "FB1: %6.2f\n\n",$FB1I;
}

if ($latex) {
  print "\nLaTeX output for types:\n";
  print "-------------\n\n";
  print "\\begin{tabular}{l|llll}\n";
  print "Metric & Accuracy & Precision & Recall & FB1 \\\\\\hline\n";
  printf "Strict, Combined (official) & %6.2f\\%% & %6.2f\\%% & %6.2f\\%% & %6.2f\\%% \\\\\n",
    100*(($outer_strict[2]+$inner_strict[2])/2)/$tokenCounter, $precisionEv1,
    $recallEv1, $FB1Ev1;
  printf "Loose, Combined & %6.2f\\%% & %6.2f\\%% & %6.2f\\%% & %6.2f\\%% \\\\\n",
    100*(($outer_loose[2]+$inner_loose[2])/2)/$tokenCounter, $precisionEv1,
    $recallEv1, $FB1Ev1;
  printf "Strict, Outer chunks only & %6.2f\\%% & %6.2f\\%% & %6.2f\\%% & %6.2f\\%% \\\\\n",
    100*($outer_strict[2]/$tokenCounter), $precisionO, $recallO, $FB1O;
  printf "Strict, Inner chunks only & %6.2f\\%% & %6.2f\\%% & %6.2f\\%% & %6.2f\\%% \\\\\n",
    100*($inner_strict[2]/$tokenCounter), $precisionI, $recallI, $FB1I;
  print "\\end{tabular}\n"
}

# Sort chunk type names from TP, FP, FN.
undef($lastType);
@sortedTypes = ();

foreach $i (sort (keys %{$outer_strict[19]}, keys %{$outer_strict[20]}, keys %{$outer_loose[19]}, keys %{$outer_loose[20]}, keys %{$inner_strict[19]}, keys %{$inner_strict[20]}, keys %{$inner_loose[19]}, keys %{$inner_loose[20]})) {
   if (not($lastType) or $lastType ne $i) {
      push(@sortedTypes,($i));
   }
   $lastType = $i;
}


#
# Print performance per chunk type.
print "\nEvaluation per type and mode:\n=============================\n\n";

#!!!
#print scalar(keys $outer_strict[18]), "\n";
#print scalar(keys $outer_strict[19]), "\n";
#print scalar(keys $outer_strict[20]), "\n";
#!!!

for $i (@sortedTypes) {

  if ($latex) { $latexTypes = sprintf("%s\n%s", $latexTypes , "\\hline"); }

  printf "==> %10s\n==============\n",$i;

  $outer_strict[18]{$i} = $outer_strict[18]{$i} ? $outer_strict[18]{$i} : 0;
  $inner_strict[18]{$i} = $inner_strict[18]{$i} ? $inner_strict[18]{$i} : 0;

  if (not($outer_strict[20]{$i})) { $outer_strict[20]{$i} = 0; $precision[0] = 0.0; }
  else { $precision[0] = 100*$outer_strict[18]{$i}/$outer_strict[20]{$i}; }
  if (not($inner_strict[20]{$i})) { $inner_strict[20]{$i} = 0; $precision[1] = 0.0; }
  else { $precision[1] = 100*$inner_strict[18]{$i}/$inner_strict[20]{$i}; }

  if (not($outer_strict[19]{$i})) { $recall[0] = 0.0; }
  else { $recall[0] = 100*$outer_strict[18]{$i}/$outer_strict[19]{$i}; }
  if (not($inner_strict[19]{$i})) { $recall[1] = 0.0; }
  else { $recall[1] = 100*$inner_strict[18]{$i}/$inner_strict[19]{$i}; }

  #!!! Loose metrics should be only shown for the four coarse labels.
  if ($i !~ /deriv$/ and $i !~ /part$/) {
    $outer_loose[18]{$i} = $outer_loose[18]{$i} ? $outer_loose[18]{$i} : 0;
    $inner_loose[18]{$i} = $inner_loose[18]{$i} ? $inner_loose[18]{$i} : 0;

    if (not($outer_loose[20]{$i})) { $outer_loose[20]{$i} = 0; $precision[2] = 0.0; }
    else { $precision[2] = 100*$outer_loose[18]{$i}/$outer_loose[20]{$i}; }
    if (not($inner_loose[20]{$i})) { $inner_loose[20]{$i} = 0; $precision[3] = 0.0; }
    else { $precision[3] = 100*$inner_loose[18]{$i}/$inner_loose[20]{$i}; }

    if (not($outer_loose[19]{$i})) { $recall[2] = 0.0; }
    else { $recall[2] = 100*$outer_loose[18]{$i}/$outer_loose[19]{$i}; }
    if (not($inner_loose[19]{$i})) { $recall[3] = 0.0; }
    else { $recall[3] = 100*$inner_loose[18]{$i}/$inner_loose[19]{$i}; }

    $b = 4;
  }
  else {$b = 2;}

  for ($a=0; $a<$b; $a=$a+1) {

    if ($precision[$a]+$recall[$a] == 0.0) { $FB1[$a] = 0.0; }
    else { $FB1[$a] = 2*$precision[$a]*$recall[$a]/($precision[$a]+$recall[$a]); }

    if ($a == 0) {print "Outer strict: "}
    elsif ($a == 1) {print "Inner strict: "}
    elsif ($a == 2) {print "Outer loose: "}
    elsif ($a == 3) {print "Inner loose: "}

    printf "Precision: %6.2f%%; ",$precision[$a];
    printf "Recall: %6.2f%%; ",$recall[$a];
    printf "FB1: %6.2f\n",$FB1[$a];
    #printf "FB1: %6.2f; %d outer and %d inner chunks found (%d outer and %d inner correct).\n", $FB1[$a];

    if ($latex) {
      if ($a == 0) {$chunkType = "Outer strict"}
      elsif ($a == 1) {$chunkType = "Inner strict"}
      elsif ($a == 2) {$chunkType = "Outer loose"}
      elsif ($a == 3) {$chunkType = "Inner loose"}
      $latexTemp = sprintf "\n%-7s & %s & %6.2f\\%% & %6.2f\\%% & %6.2f \\\\",
        $i,$chunkType,$precision[$a],$recall[$a],$FB1[$a];
      $latexTypes = $latexTypes . $latexTemp;
    }
  }
}

if ($latex) {
   print "\nLaTeX output:\n";
   print "-------------\n\n";
   print "\\begin{tabular}{ll|lll}\n";
   print "Type & Chunk Type & Precision &  Recall  & F\$_{\\beta=1}\$ \\\\";
   print $latexTypes;
   print "\n\\end{tabular}\n\n";
}
print "\n";

exit 0;

# endOfChunk: checks if a chunk ended between the previous and current word
# arguments:  previous and current chunk tags, previous and current types
# note:       this code is capable of handling other chunk representations
#             than the default CoNLL-2000 ones, see EACL'99 paper of Tjong
#             Kim Sang and Veenstra http://xxx.lanl.gov/abs/cs.CL/9907006

sub endOfChunk {
   my $prevTag = shift(@_);
   my $tag = shift(@_);
   my $prevType = shift(@_);
   my $type = shift(@_);
   my $chunkEnd = $false;

   if ( $prevTag eq "B" and $tag eq "B" ) { $chunkEnd = $true; }
   if ( $prevTag eq "B" and $tag eq "O" ) { $chunkEnd = $true; }
   if ( $prevTag eq "I" and $tag eq "B" ) { $chunkEnd = $true; }
   if ( $prevTag eq "I" and $tag eq "O" ) { $chunkEnd = $true; }

   #!!!if ($prevTag ne "O" and $prevType ne $type and $prevSpecialType ne $SpecialType) {
   #!!!if ($prevTag ne "O" and $prevType ne $type) {
   #!!!   $chunkEnd = $true;
   #!!!}

   return($chunkEnd);
}

# startOfChunk: checks if a chunk started between the previous and current word
# arguments:    previous and current chunk tags, previous and current types
# note:         this code is capable of handling other chunk representations
#               than the default CoNLL-2000 ones, see EACL'99 paper of Tjong
#               Kim Sang and Veenstra http://xxx.lanl.gov/abs/cs.CL/9907006

sub startOfChunk {
   my $prevTag = shift(@_);
   my $tag = shift(@_);
   my $prevType = shift(@_);
   my $type = shift(@_);
   my $chunkStart = $false;

   if ( $prevTag eq "B" and $tag eq "B" ) { $chunkStart = $true; }
   if ( $prevTag eq "I" and $tag eq "B" ) { $chunkStart = $true; }
   if ( $prevTag eq "O" and $tag eq "B" ) { $chunkStart = $true; }
   if ( $prevTag eq "O" and $tag eq "I" ) { $chunkStart = $true; }

   #!!! This seems to be for the case B-[...] => I-[...] (new chunk).
   #!!!if ($tag ne "O" and $prevType ne $type) {
   #!!!   $chunkStart = $true;
   #!!!}

   return($chunkStart);
}

sub update_per_line {
   my $evalMode = shift(@_);    #!!! Loose or strict?
   my $inCorrect = shift(@_);
   my $correctTags = shift(@_);      # number of correct chunk tags
   my $lastCorrect = shift(@_);
   my $correct = shift(@_);
   my $lastCorrectType = shift(@_);
   my $correctType = shift(@_);
   my $lastCorrectSpecialType = shift(@_);
   my $correctSpecialType = shift(@_);

   my $lastGuessed = shift(@_);
   my $guessed = shift(@_);
   my $lastGuessedType = shift(@_);
   my $guessedType = shift(@_);
   my $lastGuessedSpecialType = shift(@_);
   my $guessedSpecialType = shift(@_);

   my $foundCorrect = shift(@_);     # number of chunks in corpus
   my $foundGuessed = shift(@_);     # number of identified chunks
   my $correctChunk = shift(@_);
   my %correctChunk = %{shift(@_)};
   my %foundCorrect = %{shift(@_)};    # number of chunks in corpus per type
   my %foundGuessed = %{shift(@_)};    # number of identified chunks per type

   my $linetext = shift(@_);
   my $NEchunk = shift(@_);
   my @NEchunks = @{shift(@_)};

   #!!!print "$evalMode $inCorrect $correctTags\n";
   #!!!print "$lastCorrect $correct $lastCorrectType $correctType $lastCorrectSpecialType $correctSpecialType\n";
   #!!!print "$lastGuessed $guessed $lastGuessedType $guessedType $lastGuessedSpecialType $guessedSpecialType\n";
   #!!!print "$foundCorrect $foundGuessed $correctChunk\n";

   if ($evalMode eq "loose") {
     if ($inCorrect) {
        #!!! Check whether the chunk which ended in the last line was a correct
        #!!! chunk. If so, update chunk counter and hash.
        if ( &endOfChunk($lastCorrect,$correct) and
             &endOfChunk($lastGuessed,$guessed) and
             $lastGuessedType eq $lastCorrectType) {
           $inCorrect = $false;
           #!!! Last chunk was correct => increment chunk counter.
           $correctChunk++;
           $correctChunk{$lastCorrectType} = $correctChunk{$lastCorrectType} ?
               $correctChunk{$lastCorrectType}+1 : 1;
        } elsif (
             #!!! Chunk ends do not match.
             &endOfChunk($lastCorrect,$correct) !=
             &endOfChunk($lastGuessed,$guessed) or
             $guessedType ne $correctType) {
           $inCorrect = $false;
           $NEchunk = "";
        }
     }

     #!!! Are we in a correct chunk label?
     if (&startOfChunk($lastCorrect,$correct) and
        &startOfChunk($lastGuessed,$guessed) and
        $guessedType eq $correctType) {

        $inCorrect = $true;

        if ($NEchunk ne "") {
          push(@NEchunks, $NEchunk);
        }
        $NEchunk = $linetext . "\n";
     }

     if (&startOfChunk($lastCorrect,$correct) ) {
        $foundCorrect++;
        $foundCorrect{$correctType} = $foundCorrect{$correctType} ?
            $foundCorrect{$correctType}+1 : 1;
     }
     if (&startOfChunk($lastGuessed,$guessed) ) {
        $foundGuessed++;
        $foundGuessed{$guessedType} = $foundGuessed{$guessedType} ?
            $foundGuessed{$guessedType}+1 : 1;
     }

     if ($correct eq $guessed and $guessedType eq $correctType) {
        $correctTags++;
        if ($guessed ne "B" and $guessed ne "O") {
          $NEchunk = $NEchunk . $linetext . "\n";
        }
     }
   } # End loose.
   elsif ($evalMode eq "strict") {
     if ($inCorrect) {
        #!!! Check whether the chunk which ended in the last line was a correct
        #!!! chunk. If so, update chunk counter and hash.
        if ( &endOfChunk($lastCorrect,$correct) and
             &endOfChunk($lastGuessed,$guessed) and
             $lastGuessedType eq $lastCorrectType and
             $lastGuessedSpecialType eq $lastCorrectSpecialType) {
           $inCorrect = $false;
           #!!! Last chunk was correct => increment chunk counter.
           $correctChunk++;
           $correctChunk{$lastCorrectType . $lastCorrectSpecialType} = $correctChunk{$lastCorrectType . $lastCorrectSpecialType} ?
               $correctChunk{$lastCorrectType . $lastCorrectSpecialType}+1 : 1;
        } elsif (
             #!!! Chunk label or types do not match.
             &endOfChunk($lastCorrect,$correct) != &endOfChunk($lastGuessed,$guessed) or
             $guessedType ne $correctType or
             $guessedSpecialType ne $correctSpecialType) {
           $inCorrect = $false;
           $NEchunk = "";
        }
     }

     if (&startOfChunk($lastCorrect,$correct) and
        &startOfChunk($lastGuessed,$guessed) and
        $guessedType eq $correctType and
        $guessedSpecialType eq $correctSpecialType) {

        $inCorrect = $true;

        if ($NEchunk ne "") {
          push(@NEchunks, $NEchunk);
        }
        $NEchunk = $linetext . "\n";
     }

     #!!! Collecting chunk type information.
     if (&startOfChunk($lastCorrect,$correct) ) {
        $foundCorrect++;
        $foundCorrect{$correctType . $correctSpecialType} = $foundCorrect{$correctType . $correctSpecialType} ?
            $foundCorrect{$correctType . $correctSpecialType}+1 : 1;
     }
     if (&startOfChunk($lastGuessed,$guessed) ) {
        $foundGuessed++;
        $foundGuessed{$guessedType . $guessedSpecialType} = $foundGuessed{$guessedType . $guessedSpecialType} ?
            $foundGuessed{$guessedType . $guessedSpecialType}+1 : 1;
     }

     if ($correct eq $guessed and $guessedType eq $correctType and $guessedSpecialType eq $correctSpecialType) {
        $correctTags++;
        if ($guessed ne "B" and $guessed ne "O") {
          $NEchunk = $NEchunk . $linetext . "\n";
        }
     }
   } # end strict
   else { print "Wrong evaluation mode! Program quits." }

   $lastGuessed = $guessed;
   $lastCorrect = $correct;
   $lastGuessedType = $guessedType;
   $lastCorrectType = $correctType;
   $lastGuessedSpecialType = $guessedSpecialType;
   $lastCorrectSpecialType = $correctSpecialType;

   return ($evalMode, $inCorrect, $correctTags,
     $lastCorrect, $correct, $lastCorrectType, $correctType, $lastCorrectSpecialType, $correctSpecialType,
     $lastGuessed, $guessed, $lastGuessedType, $guessedType, $lastGuessedSpecialType, $guessedSpecialType,
     $foundCorrect, $foundGuessed, $correctChunk, \%correctChunk, \%foundCorrect, \%foundGuessed,
     $linetext, $NEchunk, \@NEchunks);
}

sub check_labels {
  my $chunk = shift(@_);
  my $type = shift(@_);
  my $specialType = shift(@_);
  my $line = shift(@_);

  if ($chunk !~ /(B|I|O)/) {
      print "Error in _chunk_ label, line \"$line\"\n";
      return 0;
  }

  if ($chunk =~ /O/) {
      return 1;
  }

  if ($type !~ /(LOC|ORG|PER|MISC|OTH|Skill|Knowledge)/) {
      print "Error in _type_ label, line \"$line\"\n";
      return 0;
  }

  if ($specialType) {
    if ($specialType !~ /(deriv|part)/) {
      print "Error in _special type_ label, line \"$line\"\n";
      return 0;
    }
  }

  return 1;
}

