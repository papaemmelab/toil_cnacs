#! /usr/local/bin/perl -w
use strict;
open FACTOR, '<', $ARGV[0] || die "cannot open $!";
open RAW, '<', $ARGV[1] || die "cannot open $!";

my %snp2probe;
my %snp2factor;
while (<FACTOR>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $snp = $curRow[3] . "\t" . $curRow[5];
	my $factor = $curRow[6];
	$snp2probe{$snp} = join("\t", @curRow[ 0 .. 2 ]);
	$snp2factor{$snp} = $factor;
}
close(FACTOR);


while (<RAW>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $snp = $curRow[0] . "\t" . $curRow[1];
	next if ( ! defined $snp2factor{$snp} );
	my $baf = 0;
	$baf = $curRow[-1] if ( $curRow[-1] ne 'NA' );
	my $scale = ( 1 - $baf ) + $baf * $snp2factor{$snp};
	print $snp2probe{$snp} . "\t" . $scale . "\n";
}
close(RAW);
