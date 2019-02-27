#! /usr/local/perl -w
use strict;

open PROBE, '<', $ARGV[0] || "die cannot open $!";
open OVERLAP, '<', $ARGV[1] || "die cannot open $!";
open NONOVERLAP, '<', $ARGV[2] || "die cannot open $!";

my %probe2depth;
while (<OVERLAP>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $probe = join("\t", @curRow[ 0 .. 2 ]);
	$probe2depth{$probe} = $curRow[3];
}
close(OVERLAP);

while (<NONOVERLAP>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $probe = join("\t", @curRow[ 0 .. 2 ]);
	if ( ! defined $probe2depth{$probe} ) {
		$probe2depth{$probe} = $curRow[3];
	} else {
		$probe2depth{$probe} += $curRow[3];
	}
}
close(NONOVERLAP);

while (<PROBE>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $probe = join("\t", @curRow[ 0 .. 2 ]);
	if ( defined $probe2depth{$probe} ) {
		print $probe . "\t" . $probe2depth{$probe} . "\n";
	} else {
		print $probe . "\t" . '0' . "\n";
	}
}
close(PROBE);
