#! /usr/local/bin/perl -w
use strict;

open TARGETED, '<', $ARGV[0] || die "cannot open $!";
open NON_TARGETED, '<', $ARGV[1] || die "cannot open $!";
open ALL_DEPTH, '>>', $ARGV[2] || die "cannot open $!";
my $depth_mean_lower = $ARGV[3];
my $depth_mean_upper = $ARGV[4];
my $depth_coefvar_upper = $ARGV[5];
my %all_output;

while (<TARGETED>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $mean = $curRow[4];
	my $coefvar = $curRow[5];
	
	my $pos = $curRow[0] . "\t" . $curRow[1];
	$all_output{$pos} = $curRow[0] . ':' . $curRow[1] . '-' . $curRow[2] . "\t" . join("\t", @curRow[ 6 .. $#curRow ]);
}
close(TARGETED);

while (<NON_TARGETED>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $pos = $curRow[0] . "\t" . $curRow[1];
	my $mean = $curRow[4];
	my $coefvar = $curRow[5];
	next if ( $coefvar eq 'NA' );
	next if ( ( $mean < $depth_mean_lower ) || ( $mean > $depth_mean_upper ) || ( $coefvar > $depth_coefvar_upper ) );
	
	$all_output{$pos} = $curRow[0] . ':' . $curRow[1] . '-' . $curRow[2] . "\t" . join("\t", @curRow[ 6 .. $#curRow ]);
}
close(NON_TARGETED);

foreach my $pos ( sort chrpos keys %all_output ) {
	print ALL_DEPTH $all_output{$pos} . "\n";
}
close(ALL_DEPTH);


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
