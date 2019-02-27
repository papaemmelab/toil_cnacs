#! /usr/local/perl -w
use strict;

open IN, '<', $ARGV[0] || die "cannot open $!";

while (<IN>) {
	$_ =~ s/[\r\n]//g;
	$_ =~ s/^\>//;
	my @info = split(/;/, $_);
	
	my $seq = <IN>;
	$seq =~ s/[\r\n]//g;
	my $seq2 = $seq;
	
	my $gc = ( $seq =~ s/[GC]//ig );
	my $total = ( $seq2 =~ s/[ACGT]//ig );
	my $gc_percent = 'NA';
	if ( $total > 0 ) {
		$gc_percent = 100 * $gc / $total;
	}
	
	print join("\t", @info) . "\t" . $gc_percent . "\n";
}
close(IN);
