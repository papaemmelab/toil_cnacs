#! /usr/local/perl -w
use strict;

open IN, '<', $ARGV[0] || die "cannot open $!";
my $leng1 = $ARGV[1];
my $leng2 = $ARGV[2];
my $leng3 = $ARGV[3];
open OUT1, '>', $ARGV[4] || die "cannot open $!";
open OUT2, '>', $ARGV[5] || die "cannot open $!";
open OUT3, '>', $ARGV[6] || die "cannot open $!";
open OUT4, '>', $ARGV[7] || die "cannot open $!";

while (<IN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $length = $curRow[2] - $curRow[1];
	
	if ( $length < $leng1 ) {
		print OUT1 $_ . "\n";
	} elsif ( $length < $leng2 ) {
		print OUT2 $_ . "\n";
	} elsif ( $length < $leng3 ) {
		print OUT3 $_ . "\n";
	} else {
		print OUT4 $_ . "\n";
	}
}
close(IN);
