#! /usr/local/bin/perl -w
use strict;

open ALL, '<', $ARGV[0] || die "cannot open $!";
open SNP, '<', $ARGV[1] || die "cannot open $!";

my %cum_length;
$cum_length{'chr1'} = 0;
$cum_length{'chr2'} = 249250621;
$cum_length{'chr3'} = 492449994;
$cum_length{'chr4'} = 690472424;
$cum_length{'chr5'} = 881626700;
$cum_length{'chr6'} = 1062541960;
$cum_length{'chr7'} = 1233657027;
$cum_length{'chr8'} = 1392795690;
$cum_length{'chr9'} = 1539159712;
$cum_length{'chr10'} = 1680373143;
$cum_length{'chr11'} = 1815907890;
$cum_length{'chr12'} = 1950914406;
$cum_length{'chr13'} = 2084766301;
$cum_length{'chr14'} = 2199936179;
$cum_length{'chr15'} = 2307285719;
$cum_length{'chr16'} = 2409817111;
$cum_length{'chr17'} = 2500171864;
$cum_length{'chr18'} = 2581367074;
$cum_length{'chr19'} = 2659444322;
$cum_length{'chr20'} = 2718573305;
$cum_length{'chr21'} = 2781598825;
$cum_length{'chr22'} = 2829728720;
$cum_length{'chrX'} = 2881033286;
$cum_length{'chrY'} = 3036303846;

my $header = <ALL>;
$header = <SNP>;

my %pos2all;
my %pos2depth;
while (<ALL>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my @info = split(/[:-]/, $curRow[0]);
	my $chr = $info[0];
	my $pos = $info[1];
	
	if ( defined $cum_length{$chr} ) {
		$pos += $cum_length{$chr};
	} else {
		next;
	}
	
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
	my $pos = $curRow[1];
	
	if ( defined $cum_length{$chr} ) {
		$pos += $cum_length{$chr};
	} else {
		next;
	}
	
	$pos = $pos / 1000000;
	$pos2all{$pos} = 1;
	$pos2snp{$pos} = 1;
}
close(SNP);

foreach my $pos ( sort chrpos keys %pos2all ) {
	my $depth = 0;
	my $snp = 0;
	
	$depth = 1 if ( defined $pos2depth{$pos} );
	$snp = 1 if ( defined $pos2snp{$pos} );
	print $pos . ',' . $depth . ',' . $snp . "\n";
}

sub chrpos {
	my @posa = split("\t", $a);
	my @posb = split("\t", $b);
	
	$posa[0] =~ s/chr//g;
	$posb[0] =~ s/chr//g;
	
	$posa[0] =~ s/X/23/g;
	$posb[0] =~ s/X/23/g;
	
	$posa[0] =~ s/Y/24/g;
	$posb[0] =~ s/Y/24/g;
	
	$posa[0] =~ s/M/25/g;
	$posb[0] =~ s/M/25/g;
	
	if ($posa[0] > $posb[0]) {
		return 1;
	} elsif ($posa[0] < $posb[0]) {
		return -1;
	} else {
		if ($posa[1] > $posb[1]) {
			return 1;
		} else {
			return -1;
		}
	}
}
