#! /usr/local/perl -w
use strict;

open IN, '<', $ARGV[0] || die "cannot open $!";
my $extension = $ARGV[1];

my @chr_lengths = (249250621,243199373,198022430,191154276,180915260,171115067,159138663,146364022,141213431,135534747,135006516,133851895,115169878,107349540,102531392,90354753,81195210,78077248,59128983,63025520,48129895,51304566,155270560,59373566);

while (<IN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $chr_num = $curRow[0];
	$chr_num =~ s/^chr//;
	$chr_num = 23 if ( $chr_num eq 'X' );
	$chr_num = 24 if ( $chr_num eq 'Y' );
	$chr_num += -1;
	my $chr_leng = $chr_lengths[$chr_num];
	
	my $start = $curRow[1] - $extension;
	my $end;
	if ( $start < 0 ) {
		$start = 0;
		$end = $extension;
	} else {
		$end = $curRow[1] + $extension;
		if ( $end > $chr_leng ) {
			$start = $chr_leng - $extension;
			$end = $chr_leng;
		}
	}
	
	print $curRow[0] . "\t" . $start . "\t" . $end . "\t" . join(";", @curRow[ 0 .. 2 ]) . "\n";
}
close(IN);
