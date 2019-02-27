#! /usr/local/perl -w
use strict;

open IN, '<', $ARGV[0] || die "cannot open $!";
my $sample = $ARGV[1];

my $flag = 0;
while (<IN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $name = $curRow[0];
	$name =~ s/\"//g;
	if ( $name eq $sample ) {
		unless ( $curRow[1] =~ /^[FM]$/ ) {
			print "Error: sex should be 'F' or 'M' in the sample \"$sample\".";
		} else {
			print "Done";
		}
		$flag = 1;
		last;
	}
}
close(IN);

if ( $flag == 0 ) {
	print "Error: sex of the sample \"$sample\" is not correctly specified.";
}
