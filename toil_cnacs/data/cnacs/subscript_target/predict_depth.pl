#! /usr/local/perl -w
use strict;
use List::Util qw(max);
use List::Util qw(min);

open GC2RATE, '<', $ARGV[0] || "die cannot open $!";
open POS2GC, '<', $ARGV[1] || die "cannot open $!";
my $length = $ARGV[2];


# load %GC at each position
my %pos2gc;
while (<POS2GC>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $pos = $curRow[0];
	$pos =~ s/\"//g;
	$pos2gc{$pos} = $curRow[1];
}
close(POS2GC);


# load rate of fragments mapped to each %GC bin
my %gc2rate;
while (<GC2RATE>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	$gc2rate{$curRow[0]} = $curRow[3];
}
close(GC2RATE);


# predict depth for each probe
my %probe2depth;
while (<STDIN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my @info = split(/;/, $curRow[3]);
	my $chr = $info[0];
	next if ( $chr =~ /^chr[YM]/ );
	my $bait_start = $info[1] + 1;
	my $bait_end = $info[2];
	my $bait_length = $bait_end - $bait_start + 1;
	
	my $read_sum = 0;
	
	my $loop_start = $curRow[1] + 1;
	my $loop_end = $bait_end;
	foreach my $pos ( $loop_start .. $loop_end ) {
		my $key = $chr . ':' . $pos;
		next if ( ! defined $pos2gc{$key} );
		my $gc = $pos2gc{$key};
		my $rate = $gc2rate{$gc};
		
		my $frag_start = $pos;
		my $frag_end = $pos + $length - 1;
		my $max = min ($bait_end, $frag_end);
		my $min = max ($bait_start, $frag_start);
		my $overlap = $max - $min + 1;
		
		$read_sum += 2 * $rate * $overlap;
	}
	my $depth = $read_sum / $bait_length;
	
	my $bed_start = $bait_start - 1;
	print $chr . "\t" . $bed_start . "\t" . $bait_end . "\t" . $depth . "\n";
}
