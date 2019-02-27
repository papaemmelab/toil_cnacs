#! /usr/loca/bin/perl -w
use strict;

open IN, '<', $ARGV[0] || die "cannot open $!";
my $autosome = $ARGV[1];

my %chrom;
my $num = 0;
while ( $num < $autosome ) {
	$num++;
	my $cur_chr = 'chr' . $num;
	$chrom{$cur_chr} = 1;
}
$chrom{'chrX'} = 1;
$chrom{'chrY'} = 1;

my $line = 0;
while (<IN>) {
	$line++;
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	if ( @curRow < 3 ) {
		print "Error: malformed BED entry at line ${line}.\n";
		print "It looks as though you have less than 3 columns. Are you sure your files are tab-delimited?\n";
		exit 1;
		last;
	}

	if ( $curRow[1] =~ /\D/ ) {
		print "Error: malformed BED entry at line ${line}.\n";
		print "Perhaps you have non-integer starts or ends.\n";
		exit 1;
		last;
	}

	if ( $curRow[2] =~ /\D/ ) {
		print "Error: malformed BED entry at line ${line}.\n";
		print "Perhaps you have non-integer starts or ends.\n";
		exit 1;
		last;
	}

	if ( $curRow[1] < 0 ) {
		print "Error: malformed BED entry at line ${line}.\n";
		print "Perhaps you have non-integer starts or ends.\n";
		exit 1;
		last;
	}

	if ( $curRow[2] < 0 ) {
		print "Error: malformed BED entry at line ${line}.\n";
		print "Perhaps you have non-integer starts or ends.\n";
		exit 1;
		last;
	}

	if ( $curRow[1] >= $curRow[2] ) {
		print "Error: malformed BED entry at line ${line}.\n";
		print "Start was greater than end.\n";
		exit 1;
		last;
	}

	if ( ! defined $chrom{$curRow[0]} ) {
		print "Error: malformed BED entry at line ${line}.\n";
		print "$curRow[0] should not be included in your BED file.\n";
		exit 1;
		last;
	}
}
close(IN);
