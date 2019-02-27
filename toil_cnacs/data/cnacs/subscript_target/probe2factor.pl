#! /usr/local/bin/perl -w
use strict;

my %pos2info;
my %pos2factor;
while (<STDIN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $pos = $curRow[0] . "\t" . $curRow[1];
	my $factor = $curRow[6];
	
	if ( defined $pos2factor{$pos} ) {
		if ( $factor > $pos2factor{$pos} ) {
			$pos2factor{$pos} = $factor;
			$pos2info{$pos} = $_;
		}
	} else {
		$pos2factor{$pos} = $factor;
		$pos2info{$pos} = $_;
	}
}

foreach my $pos ( sort chrpos keys %pos2info ) {
	print $pos2info{$pos} . "\n";
}


# sort accoding to chromosome and position
sub chrpos {
	my @posa = split("\t", $a);
	my @posb = split("\t", $b);
	
	$posa[0] =~ s/chr//g;
	$posb[0] =~ s/chr//g;
	
	$posa[0] =~ s/X/23/g;
	$posb[0] =~ s/X/23/g;
	
	$posa[0] =~ s/Y/24/g;
	$posb[0] =~ s/Y/24/g;
	
	$posa[0] =~ s/M/25/g;
	$posb[0] =~ s/M/25/g;
	
	if ($posa[0] > $posb[0]) {
		return 1;
	} elsif ($posa[0] < $posb[0]) {
		return -1;
	} else {
		if ($posa[1] > $posb[1]) {
			return 1;
		} else {
			return -1;
		}
	}
}
