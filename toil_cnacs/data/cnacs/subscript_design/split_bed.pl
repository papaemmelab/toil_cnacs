#! /usr/loca/bin/perl -w
use strict;

open IN, '<', $ARGV[0] || die "cannot open $!";
my $bin = $ARGV[1];

while (<IN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $length = $curRow[2] - $curRow[1];
	my $last = $#curRow;
	
	my $cur_pos = $curRow[1];
	if ( $last > 2 ) {
		while () {
			my $end = $cur_pos + $bin;
			if ( $end < $curRow[2] ) {
				print $curRow[0] . "\t" . $cur_pos . "\t" . $end . "\t" . $curRow[3] . "\n";
				$cur_pos = $end;
			} else {
				print $curRow[0] . "\t" . $cur_pos . "\t" . $curRow[2] . "\t" . $curRow[3] . "\n";
				last;
			}
		}
	} else {
		while () {
			my $end = $cur_pos + $bin;
			if ( $end < $curRow[2] ) {
				print $curRow[0] . "\t" . $cur_pos . "\t" . $end . "\n";
				$cur_pos = $end;
			} else {
				print $curRow[0] . "\t" . $cur_pos . "\t" . $curRow[2] . "\n";
				last;
			}
		}
	}
}
close(IN);
