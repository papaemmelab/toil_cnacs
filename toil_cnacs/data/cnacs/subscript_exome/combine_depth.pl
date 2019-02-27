#! /usr/local/perl -w
use strict;

open RAW, '<', $ARGV[0] || "die cannot open $!";
open REF, '<', $ARGV[1] || "die cannot open $!";

my @depths;
while (<RAW>) {
	s/[\r\n]//g;
	my @curRow = split(/,/, $_);
	foreach my $depth ( @curRow ) {
		push(@depths, $depth);
	}
}
close(RAW);

my $num = 0;
while (<REF>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $probe = join("\t", @curRow[ 0 .. 2 ]);
	my $gene = $curRow[-1];
	print $probe . "\t" . $depths[$num] . "\t" . $gene . "\n";
	$num++;
}
close(REF);
