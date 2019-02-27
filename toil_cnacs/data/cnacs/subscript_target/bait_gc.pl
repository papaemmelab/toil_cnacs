#! /usr/local/perl -w
use strict;

open IN, '<', $ARGV[0] || die "cannot open $!";
my $max_length = $ARGV[1];
my $length = $ARGV[2];
open POS2GC, '>', $ARGV[3] || die "cannot open $!";
open GC2NUM, '>', $ARGV[4] || die "cannot open $!";

my %gc2count;

while (<IN>) {
	$_ =~ s/[\r\n]//g;
	my @info = split(/;/, $_);
	my $chr = $info[0];
	$chr =~ s/^\>//;
	last if ( $chr =~ /^chr[YM]/ );
	my $bait_start = $info[1] + 1;
	my $bait_length = $info[2] - $info[1];
	
	my $seq = <IN>;
	$seq =~ s/[\r\n]//g;
	
	my $start = $bait_start - $max_length + 1;
	my $pos1 = $max_length - $length;
	my $pos2 = $pos1 + 1;
	my $pos3 = $max_length + $bait_length - 1;
	
	foreach my $num1 ( 1 .. $pos1 ) {
		my $pos = $start + $num1 - 1;
		my $offset = $num1 + 1;  # skip first 2 bases
		my $tmp_seq = substr($seq, $offset, $length - 4);  # skip last 2 bases
		my $tmp_seq2 = $tmp_seq;
		my $gc = ( $tmp_seq =~ s/[GC]//ig );
		my $total = ( $tmp_seq2 =~ s/[ACGT]//ig );
		next if ( $total == 0 );
		my $gc_percent = int( 100 * $gc / $total );
		
		print POS2GC $chr . ':' . $pos . "\t" . $gc_percent . "\n";
	}
	
	foreach my $num2 ( $pos2 .. $pos3 ) {
		my $pos = $start + $num2 - 1;
		my $offset = $num2 + 1;  # skip fist 2 bases
		my $tmp_seq = substr($seq, $offset, $length - 4);  # skip last 2 bases
		my $tmp_seq2 = $tmp_seq;
		my $gc = ( $tmp_seq =~ s/[GC]//ig );
		my $total = ( $tmp_seq2 =~ s/[ACGT]//ig );
		next if ( $total == 0 );
		my $gc_percent = int( 100 * $gc / $total );
		
		print POS2GC '"' . $chr . ':' . $pos . '"' . "\t" . $gc_percent . "\n";
		next if ( $chr =~ /chr[XYM]/ );
		if ( ! defined $gc2count{$gc_percent} ) {
			$gc2count{$gc_percent} = 2;
		} else {
			$gc2count{$gc_percent} += 2;
		}
	}
}
close(IN);

my @gc_count;
foreach my $percent ( 0 .. 100 ) {
	if ( defined $gc2count{$percent} ) {
		push(@gc_count, $gc2count{$percent});
	} else {
		push(@gc_count, "0" );
	}
}
print GC2NUM join(",", @gc_count) . "\n";
