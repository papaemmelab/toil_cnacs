#! /usr/local/bin/perl -w
use strict;

open IN, '<', $ARGV[0] || die "cannot open $!";

my $sum = 0;
my $num = 0;
while (<IN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $chr = $curRow[0];
	next unless ( $chr =~ /^chr[\d]+$/ );
	
	my $depth = $curRow[3];
	$sum += $depth;
	$num++;
}
close(IN);
my $factor = $sum / $num;

open IN, '<', $ARGV[0] || die "cannot open $!";
while (<IN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $depth = $curRow[3];
	my $norm_depth = $depth / $factor;
	print join("\t", @curRow[ 0 .. 2 ]) . "\t" . $norm_depth . "\n";
}
close(IN);
