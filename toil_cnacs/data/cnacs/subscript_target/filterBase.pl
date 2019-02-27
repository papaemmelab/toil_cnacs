#! /usr/local/bin/perl -w
use strict;

open IN, '<', $ARGV[0] || die "cannot open $!";
my $error_thres = $ARGV[1];

my %base2ind = ();
$base2ind{"A"} = 0;
$base2ind{"C"} = 1;
$base2ind{"G"} = 2;
$base2ind{"T"} = 3;

while (<IN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $ref = $curRow[2];
	
	# the numbers of each bases
	my $A = $curRow[4];
	my $C = $curRow[5];
	my $G = $curRow[6];
	my $T = $curRow[7];
	
	my $depth = $A + $C + $G + $T;
	
	# determine which base is the most frequent mismatch
	my @Nums = ($A, $C, $G, $T);
	my $refNum = $Nums[$base2ind{$ref}];
	$Nums[$base2ind{$ref}] = 0;
	my $mis = 'N';
	my $misNum = 0;
	foreach my $base ( keys %base2ind ) {
		if ( $Nums[$base2ind{$base}] > $misNum ) {
			$misNum = $Nums[$base2ind{$base}];
			$mis = $base;
		}
	}
	
	next if ( $depth == 0 );
	my $baf = ( $misNum / $depth );
	
	# determine which base is the second most frequent mismatch
	unless ( $mis eq 'N' ) {
		$Nums[$base2ind{$mis}] = 0;
	}
	my $error = 'N';
	my $errorNum = 0;
	foreach my $base ( keys %base2ind ) {
		if ( $Nums[$base2ind{$base}] > $errorNum ) {
			$errorNum = $Nums[$base2ind{$base}];
			$error = $base;
		}
	}
	
	my $errorRate = ( $errorNum / $depth );
	if ( $errorRate > $error_thres ) {
		$baf = 'NA';
	}
	
	print $curRow[0] . "\t" . $curRow[1] . "\t" . $curRow[2]. "\t" . $mis . "\t" . $depth . "\t" . $refNum . "\t" . $misNum . "\t" . $baf . "\n";
}
close(IN);
