#! /usr/local/bin/perl -w
use strict;

open DEPTH, '<', $ARGV[0] || die "cannot open $!";
open BAF, '<', $ARGV[1] || die "cannot open $!";

my %all_pos;

# load depth of each probe
my %pos2depth;
while (<DEPTH>) {
	s/[\r\n]//g;
	my @curRow = split(/,/, $_);
	my $pos = join("\t", @curRow[ 0 .. 1 ]);
	$all_pos{$pos} = 1;
	$pos2depth{$pos} = $curRow[2];
}
close(DEPTH);


# load adjusted BAF of each probe
my %pos2baf;
while (<BAF>) {
	s/[\r\n]//g;
	my @curRow = split(/,/, $_);
	my $pos = join("\t", @curRow[ 0 .. 1 ]);
	$all_pos{$pos} = 1;
	$pos2baf{$pos} = $curRow[2];
}
close(BAF);

# output
foreach my $pos ( sort chrpos keys %all_pos ) {
	my $depth = 'NA';
	my $baf = 'NA';
	if ( defined $pos2depth{$pos} ) {
		$depth = $pos2depth{$pos};
	}
	if ( defined $pos2baf{$pos} ) {
		$baf = $pos2baf{$pos};
	}
	next if ( ( $depth eq 'NA' ) && ( $baf eq 'NA' ) );
	
	print $pos . "\t" . $depth . "\t" . $baf . "\n";
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
