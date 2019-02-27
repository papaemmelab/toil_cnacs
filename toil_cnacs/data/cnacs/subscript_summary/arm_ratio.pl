#! /usr/local/bin/perl -w
use strict;

open IN, '<', $ARGV[0] || die "cannot open $!";
open LENGTH, '<', $ARGV[1] || die "cannot open $!";

my %chr2short;
my %chr2long;

while (<LENGTH>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $chr = $curRow[0];
	$chr =~ s/^chr//;
	
	$chr2short{$chr} = $curRow[1];
	$chr2long{$chr} = $curRow[2];
}
close(LENGTH);

while (<IN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $chr = $curRow[1];
	next if ( $chr > 22 );
	
	my $start = $curRow[2];
	my $end = $curRow[3];
	my $length = $end - $start + 1;
	
	my $total = $curRow[5];
	
	my $short = $chr2short{$chr};
	my $long = $chr2long{$chr};
	
	my $ratio;
	if ( ( $start < $short ) && ( $end < $short ) ) {
		$ratio = $length / $short;
	} elsif ( ( $start > $short ) && ( $end > $short ) ) {
		$ratio = $length / $long;
	} else {
		$ratio = ( $short - $start ) / $short + ( $end - $short ) / $long;
	}
	print $ratio . "\n";
}
close(IN);
