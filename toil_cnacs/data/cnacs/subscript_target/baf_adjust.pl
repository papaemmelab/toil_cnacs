#! /usr/local/bin/perl -w
use strict;

open IN, '<', $ARGV[0] || die "cannot open $!";
open SCALE, '<', $ARGV[1] || die "cannot open $!";

my %scale;
my $header = <SCALE>;
while (<SCALE>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $key = join("\t", @curRow[ 0 .. 1 ]);
	$scale{$key} = $curRow[2];
}
close(SCALE);

while (<IN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $key = join("\t", @curRow[ 0 .. 1 ]);
	next unless ( defined $scale{$key} );
	my $a_depth = $curRow[5];
	my $b_depth = $curRow[6];
	my $adj_b_depth = $curRow[6] * $scale{$key};
	my $adj_depth = $a_depth + $adj_b_depth;
	my $adj_baf;
	if ( $adj_depth == 0 ) {
		$adj_baf = 0;
	} else {
		$adj_baf = $adj_b_depth / $adj_depth;
	}
	
	if ( $adj_baf > 0.5 ) {
		$adj_baf = 1 - $adj_baf;
	}
	
	print $key . "\t" . $adj_baf . "\n";
}
close(IN);
