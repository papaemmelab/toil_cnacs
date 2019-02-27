#! /usr/local/bin/perl -w
use strict;

open IN, '<', $ARGV[0] || die "cannot open $!";
my $id = $ARGV[1];

while (<IN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $tmp_id = $curRow[0];
	$tmp_id =~ s/\"//g;
	
	next if ( $tmp_id ne $id );
	print $_ . "\n";
}
close(IN);
