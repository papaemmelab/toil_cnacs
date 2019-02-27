#! /usr/local/bin/perl -w
use strict;

open IN, '<', $ARGV[0] || die "cannot open $!";
open LENGTH, '<', $ARGV[1] || die "cannot open $!";
open FOCAL, '>', $ARGV[2] || die "cannot open $!";
open ARM, '>', $ARGV[3] || die "cannot open $!";
my $thres = $ARGV[4];

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
	my $id = $curRow[0];
	$id =~ s/\"//g;
	my $chr = $curRow[1];
	my $start = $curRow[2];
	my $end = $curRow[3];
	my $length = $end - $start + 1;
	
	my $short = $chr2short{$chr};
	my $short_thres = $short * $thres;
	my $long = $chr2long{$chr};
	my $long_thres = $long * $thres;
	
	if ( ( $start < $short ) && ( $end < $short ) && ( $length < $short_thres ) ) {
		print FOCAL $_ . "\n";
	} elsif ( ( $start > $short ) && ( $end > $short ) && ( $length < $long_thres ) ) {
		print FOCAL $_ . "\n";
	} else {
		print ARM $_ . "\n";
	}
}
close(IN);
