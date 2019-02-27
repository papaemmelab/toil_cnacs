#! /usr/local/bin/perl -w
use strict;

open IN, '<', $ARGV[0] || die "cannot open $!";

my $header = <IN>;
while (<IN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my @label = split(/;/, $curRow[0]);
	
	print join(",", @label) . ',' . $curRow[1] . "\n";
}
close(IN);
