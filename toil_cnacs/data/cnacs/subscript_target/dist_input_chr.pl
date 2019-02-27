#! /usr/local/bin/perl -w
use strict;

open ALL, '<', $ARGV[0] || die "cannot open $!";
open SNP, '<', $ARGV[1] || die "cannot open $!";
my $chr_num = $ARGV[2];

my $header = <ALL>;
$header = <SNP>;

my %pos2all;
my %pos2depth;

while (<ALL>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my @info = split(/[:-]/, $curRow[0]);
	
	my $chr = $info[0];
	$chr =~ s/^chr//;
	if ( $chr eq 'X' ) {
		$chr = 23;
	} elsif ( $chr eq 'Y' ) {
		$chr = 24;
	} elsif ( $chr =~ /[\D]/ ) {
		next;
	}
	next if ( $chr != $chr_num );
	
	my $pos = $info[1];
	$pos = $pos / 1000000;
	$pos2all{$pos} = 1;
	$pos2depth{$pos} = 1;
}
close(ALL);

my %pos2snp;
while (<SNP>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $chr = $curRow[0];
	$chr =~ s/^chr//;
	if ( $chr eq 'X' ) {
		$chr = 23;
	} elsif ( $chr eq 'Y' ) {
		$chr = 24;
	} elsif ( $chr =~ /[\D]/ ) {
		next;
	}
	next if ( $chr != $chr_num );
	
	my $pos = $curRow[1];
	$pos = $pos / 1000000;
	$pos2all{$pos} = 1;
	$pos2snp{$pos} = 1;
}
close(SNP);

foreach my $pos ( sort { $a <=> $b } keys %pos2all ) {
	my $depth = 0;
	my $snp = 0;
	
	$depth = 1 if ( defined $pos2depth{$pos} );
	$snp = 1 if ( defined $pos2snp{$pos} );
	print $chr_num . ',' . $pos . ',' . $depth . ',' . $snp . "\n";
}
