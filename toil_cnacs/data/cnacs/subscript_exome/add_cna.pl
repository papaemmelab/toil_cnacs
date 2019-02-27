#! /usr/local/bin/perl -w
use strict;

open SEG_TMP, '<', $ARGV[0] || die "cannot open $!";
open CNA_POS, '<', $ARGV[1] || die "cannot open $!";
open SIGNAL,  '<', $ARGV[2] || die "cannot open $!";
my $id = $ARGV[3];

# load regions affected by CNAs
my %cna_region;
while (<CNA_POS>) {
	s/[\r\n]//g;
	$cna_region{$_} = 1;
}
close(CNA_POS);

# load informaion on already called CNAs
my %pos2info;
my %start2end;
while (<SEG_TMP>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $pos = join("\t", @curRow[ 1 .. 2 ]);
	$pos2info{$pos} = $_;
	
	if ( $curRow[1] == 23 ) {
		$pos = 'chrX' . "\t" . $curRow[2];
	} elsif ( $curRow[1] == 24 ) {
		$pos = 'chrY' . "\t" . $curRow[2];
	} else {
		$pos = 'chr' . $pos;
	}
	$start2end{$pos} = $curRow[3];
}
close(SEG_TMP);

# process signals
my $cna_start;
my $cna_end;
my $calling = 0;
my $depth_sum = 0;
my $as_sum = 0;
my $depth_ave;
my $as_ave;
my $called = 0;
my $cur_end;
while (<SIGNAL>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $pos = join("\t", @curRow[ 0 .. 1 ]);
	
	if ( $called == 1 ) {
		if ( $curRow[1] == $cur_end ) {
			$called = 0;
			$cur_end = '';
		}
		next;
	}
	
	if ( defined $start2end{$pos} ) {
		$called = 1;
		$cur_end = $start2end{$pos};
		
		if ( $calling > 0 ) {
			my $depth_output = 2 * 2 ** $depth_ave;
			my $as_output = 2 ** $as_ave;
			$pos2info{$cna_start} = '"' . $id . '"' . "\t" . $cna_start . "\t" . $cna_end . "\t" . $calling . "\t" . $depth_output . "\t" . $as_output;
			$calling = 0;
			$depth_sum = 0;
			$as_sum = 0;
			$depth_ave = 0;
			$as_ave = 0;
		}
		
		next;
	}
	
	if ( ! defined $cna_region{$pos} ) {
		if ( $calling > 0 ) {
			my $depth_output = 2 * 2 ** $depth_ave;
			my $as_output = 2 ** $as_ave;
			$pos2info{$cna_start} = '"' . $id . '"' . "\t" . $cna_start . "\t" . $cna_end . "\t" . $calling . "\t" . $depth_output . "\t" . $as_output;
			$calling = 0;
			$depth_sum = 0;
			$as_sum = 0;
			$depth_ave = 0;
			$as_ave = 0;
		}
		next;
	}
	
	my $chr = $curRow[0];
	$chr =~ s/^chr//;
	$chr = 23 if ( $chr eq 'X' );
	$chr = 24 if ( $chr eq 'Y' );
	
	$cna_start = $chr . "\t" . $curRow[1] if ( $calling == 0 );
	$cna_end = $curRow[1];
	$calling++;
	$depth_sum += $curRow[2];
	$as_sum += $curRow[3];
	$depth_ave = $depth_sum / $calling;
	$as_ave = $as_sum / $calling;
}
close(SIGNAL);

# output
foreach my $tmp_pos ( sort chrpos keys %pos2info ) {
	print $pos2info{$tmp_pos} . "\n";
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


# obtain percentiles
sub percentile {
	my $percent = $_[0];
	my @sorted = sort { $a <=> $b } @_[ 1 .. $#_ ];
	my $idx = int( @sorted * $percent / 100 );
	my $down_dif = @sorted * $percent / 100 - $idx;
	my $up_dif = 1 - $down_dif;
	my $value = $sorted[ $idx - 1 ] * $up_dif + $sorted[ $idx ] * $down_dif;
	return $value;
}
