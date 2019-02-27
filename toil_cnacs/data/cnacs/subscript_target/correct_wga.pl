#! /usr/local/bin/perl -w
use strict;

open DEPTH, '<', $ARGV[0] || die "cannot open $!";
open GC, '<', $ARGV[1] || die "cannot open $!";
open OUT, '>', $ARGV[2] || die "cannot open $!";
open GC2RATE, '>', $ARGV[3] || die "cannot open $!";


# load GC content of each probe
my %pos2gc;
my %gc2num;
foreach my $num ( 0 .. 100 ) {
	$gc2num{$num} = 0;
}

while (<GC>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $pos = join("\t", @curRow[ 0 .. 2 ]);
	$pos2gc{$pos} = int( $curRow[3] );
	$gc2num{int( $curRow[3] )}++;
}
close(GC);


# load depth of each probe
my %pos2depth;
my %gc2sum;
foreach my $num ( 0 .. 100 ) {
	$gc2sum{$num} = 0;
}

while (<DEPTH>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $pos = join("\t", @curRow[ 0 .. 2 ]);
	$pos2depth{$pos} = $curRow[3];
	$gc2sum{$pos2gc{$pos}} += $curRow[3];
}
close(DEPTH);


# calculate depth for each %GC
my %gc2rate;
foreach my $gc ( 0 .. 100 ) {
	my $num = $gc2num{$gc};
	my $sum = $gc2sum{$gc};
	if ( $num > 0 ) {
		$gc2rate{$gc} = $sum / $num;
	} else {
		$gc2rate{$gc} = 'NA';
	}
	print GC2RATE $gc . "\t" . $num . "\t" . $sum . "\t" . $gc2rate{$gc} . "\n";
}


# calculate corrected depth
my %pos2corrected;
my @corrected_depth;
foreach my $pos ( keys %pos2gc ) {
	my $depth = 0;
	if ( defined $pos2depth{$pos} ) {
		$depth = $pos2depth{$pos};
	}
	my $rate = $gc2rate{$pos2gc{$pos}};
	my $corrected = 0;
	if ( $rate > 0 ) {
		$corrected = $depth / $rate;
	}
	
	$pos2corrected{$pos} = $corrected;
	push(@corrected_depth, $corrected);
}

my @stats = &stat( @corrected_depth );
my $mean = $stats[0];


# output
foreach my $pos ( sort chrpos keys %pos2corrected ) {
	my $depth = $pos2corrected{$pos} / $mean;
	print OUT $pos . "\t" . $depth . "\n";
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

sub stat {
	my $number = @_;
	if ( $number == 0 ) {
		return('NA', 'NA');
	} else {
		my $sum = 0;
		foreach my $item ( @_ ) {
			next if ( $item eq 'NA' );
			$sum += $item;
		}
		my $mean = $sum / $number;
		
		my $square_sum = 0;
		foreach my $item ( @_ ) {
			if ( $item eq 'NA' ) {
				$square_sum += ( $mean )**2;
				next;
			}
			$square_sum += ( $item - $mean )**2;
		}
		my $sd = ( $square_sum / $number )**(1/2);
		my $coefVar;
		if ( $mean == 0 ) {
			$coefVar = 'NA';
		} else {
			$coefVar = $sd / $mean;
		}
		
		return($mean, $coefVar);
	}
}
