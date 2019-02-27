#! /usr/loca/bin/perl -w
use strict;

my $tier_num = $ARGV[0];

while (<STDIN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	print join("\t", @curRow[ 0 .. 2 ]) . "\t" . $curRow[-1] . "\t" . 'tier' . $tier_num;
	
	my $gene = $curRow[3];
	if ( ( $gene =~ /^chr[\d]+$/ ) || ( $gene =~ /^chr[XY]$/ ) ) {
		print "\n";
	} else {
		print "\t" . $gene . "\n";
	}
}
