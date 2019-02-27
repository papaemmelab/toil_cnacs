#! /usr/local/bin/perl -w
use strict;

open BAIT, '<', $ARGV[0] || die "cannot open $!";
my $max = $ARGV[1];

my $sum = 0;
while (<BAIT>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	$sum += $curRow[2] - $curRow[1];
	last if ( $sum > $max * 1000 );
}
close(BAIT);

$sum = int( $sum / 1000 );
print $sum;
