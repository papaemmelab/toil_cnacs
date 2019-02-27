#! /usr/local/perl -w
use strict;

open SIGNAL, '<', $ARGV[0] || "die cannot open $!";
open TIME, '<', $ARGV[1] || "die cannot open $!";

# load replication timing
my %reptime;
while (<TIME>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $pos = $curRow[0] . "\t" . $curRow[1];
	$reptime{$pos} = $curRow[3];
}
close(TIME);

my $header = <SIGNAL>;
while (<SIGNAL>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my @info = split(/;/, $curRow[0]);
	my $pos = $info[0] . "\t" . $info[1];
	my $sig = $curRow[1];
	my $time = 'NA';
	$time = $reptime{$pos} if ( defined $reptime{$pos} );
	
	if ( $sig =~ /Inf/ ) {
		$sig=~ s/Inf/12/;
		print $curRow[0] . "\t" . $sig . "\t" . $time . "\n";
	} else {
		print $_ . "\t" . $time . "\n";
	}
}
close(SIGNAL);
