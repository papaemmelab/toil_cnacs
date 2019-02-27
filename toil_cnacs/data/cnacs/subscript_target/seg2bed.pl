#! /usr/local/perl -w
use strict;

open IN, '<', $ARGV[0] || "die cannot open $!";

while (<IN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	print 'chr' . join("\t", @curRow[ 1 .. 3 ]) . "\n";
}
close(IN);
