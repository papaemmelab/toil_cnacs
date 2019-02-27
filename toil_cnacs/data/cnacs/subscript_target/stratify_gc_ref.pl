#! /usr/local/perl -w
use strict;

open IN, '<', $ARGV[0] || die "cannot open $!";
open POS2GC, '<', $ARGV[1] || die "cannot open $!";
open GC2NUM, '<', $ARGV[2] || die "cannot open $!";

my %pos2gc;
while (<POS2GC>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $pos = $curRow[0];
	$pos =~ s/\"//g;
	$pos2gc{$pos} = $curRow[1];
}
close(POS2GC);

my @gc2num;
while (<GC2NUM>) {
	s/[\r\n]//g;
	@gc2num = split(/,/, $_);
}
close(GC2NUM);

# calculate total number of fragments of each %GC bin
my %gc2count;
while (<IN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $chr = $curRow[0];
	my $start = $curRow[1] + 1;
	my $end = $curRow[2];
	
	my $key = $chr . ':' . $start;
	next if ( ! defined $pos2gc{$key} );
	my $gc = $pos2gc{$key};
	
	if ( ! defined $gc2count{$gc} ) {
		$gc2count{$gc} = 1;
	} else {
		$gc2count{$gc}++;
	}
}
close(IN);

# load total number of positions of each %GC bin
# calculate rate of fragments mapped to each %GC bin
my %gc2rate;
foreach my $tmp_gc ( 0 .. 100 ) {
	my $pos_num = $gc2num[$tmp_gc];
	if ( $pos_num == 0 ) {
		if ( ! defined $gc2count{$tmp_gc} ) {
			print $tmp_gc . "\t" . '0' . "\t" . '0' . "\t" . 'NA' . "\n";
		} else {
			print $tmp_gc . "\t" . $gc2count{$tmp_gc} . "\t" . '0' . "\t" . 'NA' . "\n";
		}
	} else {
		if ( ! defined $gc2count{$tmp_gc} ) {
			print $tmp_gc . "\t" . '0' . "\t" . $pos_num . "\t" . '0' . "\n";
		} else {
			$gc2rate{$tmp_gc} = $gc2count{$tmp_gc} / $pos_num;
			print $tmp_gc . "\t" . $gc2count{$tmp_gc} . "\t" . $pos_num . "\t" . $gc2rate{$tmp_gc} . "\n";
		}
	}
}
