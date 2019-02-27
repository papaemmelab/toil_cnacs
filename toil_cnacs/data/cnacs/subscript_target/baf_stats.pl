#! /usr/local/bin/perl -w
use strict;

open IN, '<', $ARGV[0] || die "cannot open $!";
open OUT, '>', $ARGV[1] || die "cannot open $!";
open BED, '>', $ARGV[2] || die "cannot open $!";

print OUT "CHR\tPOS\tFACTOR\tSD\tMEAN\tCOEFVAR\n";

while (<IN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $mean = $curRow[2];
	my $coefVar = $curRow[3];
	
	if ( ( $mean eq 'NA' ) || ( $coefVar eq 'NA' ) ) {
		print OUT join("\t", @curRow[ 0 .. 1 ]) . "\t" . '1' . "\t" . 'NA' . "\t" . '0' . "\t" . 'NA' . "\n";
		next;
	}
	
	my $factor = 0.5 / $mean;
	my $sd = $mean * $coefVar;
	
	print OUT join("\t", @curRow[ 0 .. 1 ]) . "\t" . $factor . "\t" . $sd . "\t" . $mean . "\t" . $coefVar . "\n";
	
	my $hetero_num = @curRow - 4;
	next if ( ( $hetero_num == 1 ) && ( ( $factor > 1.4 ) || ( $factor < 0.7 ) ) );
	my $bed_start = $curRow[1] - 1;
	print BED $curRow[0] . "\t" . $bed_start . "\t" . $curRow[1] . "\t" . $factor . "\n";
}
close(IN);
