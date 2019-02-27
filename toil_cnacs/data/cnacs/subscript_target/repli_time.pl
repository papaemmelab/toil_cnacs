#! /usr/local/perl -w
use strict;

open IN, '<', $ARGV[0] || "die cannot open $!";

# load probe information
my %pos2probe;
my %pos2end;
while (<IN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $pos = $curRow[0] . "\t" . $curRow[1];
	$pos2probe{$pos} = $_;
	$pos2end{$pos} = $curRow[2];
}
close(IN);

my %pos2repli;
while (<STDIN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $pos = $curRow[0] . "\t" . $curRow[1];
	next if ( defined $pos2repli{$pos} );
	
	my $start= $curRow[1] + 1;
	my $end  = $curRow[2];
	
	my $pos1 = $curRow[-4] + 1;
	my $pos2 = $curRow[-3];
	my $sd1  = $curRow[-2];
	my $sd2  = $curRow[-1];
	next if ( ( $sd1 eq 'NaN' ) || ( $sd2 eq 'NaN' ) );
	
	if ( ( $start <= $pos1 ) && ( $end >= $pos1 ) ) {
		$pos2repli{$pos} = $sd1;
	} elsif ( ( $start <= $pos2 ) && ( $end >= $pos2 ) ) {
		$pos2repli{$pos} = $sd2;
	} else {
		my $diff1 = abs($start - $pos1);
		my $diff2 = abs($pos2 - $start);
		$pos2repli{$pos} = ( $diff2 * $sd1 + $diff1 * $sd2 ) / ( $diff1 + $diff2 );
	}
}

foreach my $pos ( sort chrpos keys %pos2probe ) {
	if ( defined $pos2repli{$pos} ) {
		print $pos . "\t" . $pos2end{$pos} . "\t" . $pos2repli{$pos} . "\n";
	} else {
		print $pos . "\t" . $pos2end{$pos} . "\t" . 'NA' . "\n";
	}
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
