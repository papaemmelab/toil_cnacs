#! /usr/local/perl -w
use strict;

open PREDICTED, '<', $ARGV[0] || "die cannot open $!";
open ACTUAL, '<', $ARGV[1] || "die cannot open $!";


# load predicted depth for each probe
my %probe2predicted;
while (<PREDICTED>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $probe = join("\t", @curRow[ 0 .. 2 ]);
	$probe2predicted{$probe} = $curRow[3];
}
close(PREDICTED);

while (<ACTUAL>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $probe = join("\t", @curRow[ 0 .. 2 ]);
	next if ( ! defined $probe2predicted{$probe} );
	
	my $ratio = 0;
	if ( $probe2predicted{$probe} > 0 ) {
		$ratio = $curRow[3] / $probe2predicted{$probe};
	}
	print $probe . "\t" . $ratio . "\n";
}
close(ACTUAL);
