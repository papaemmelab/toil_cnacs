#! /usr/local/bin/perl -w
use strict;

open IN, '<', $ARGV[0] || die "cannot open $!";
my $col_num = $ARGV[1];

while (<IN>) {
	s/[\r\n]//g;
	my @F = split(/\//, $_);
	my $tag = $F[$col_num];
	
	my $idx = $_;
	$idx =~ s/bam/bai/;
	if ( ! -e $idx ) {
		$idx =~ s/bai/bam.bai/;
	}
	if ( ! -e $idx ) {
		print "The index file could not be found for $tag.\n";
		next;
	}
	
	my $cmd1 = "mkdir $tag";
	my $cmd2 = "ln -s $_ " . './' . $tag . '/' . $tag . ".bam";
	my $cmd3 = "ln -s $idx " . './' . $tag . '/' . $tag . ".bai";
	
	system $cmd1;
	system $cmd2;
	system $cmd3;
}
close(IN);
