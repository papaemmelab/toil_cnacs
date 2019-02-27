#! /usr/local/perl -w
use strict;

open IN, '<', $ARGV[0] || die "cannot open $!";
my $extension = $ARGV[1];
$extension += -1;

while (<IN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $start = $curRow[1] - $extension;
	next if ( $start < 0 );
	my $end = $curRow[2] + $extension;
	
	print $curRow[0] . "\t" . $start . "\t" . $end . "\t" . join(";", @curRow) . "\n";
}
close(IN);
