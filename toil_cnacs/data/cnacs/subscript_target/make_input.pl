#! /usr/local/bin/perl -w
use strict;

open DEPTH, '<', $ARGV[0] || die "cannot open $!";
open BAF, '<', $ARGV[1] || die "cannot open $!";
open BAF_INFO, '<', $ARGV[2] || die "cannot open $!";
open BAF_FACTOR, '<', $ARGV[3] || die "cannot open $!";
open BAF_FACTOR_ALL, '<', $ARGV[4] || die "cannot open $!";
open ALL_DEPTH, '<', $ARGV[5] || die "cannot open $!";
open DEPTH_OUT, '>', $ARGV[6] || die "cannot open $!";
open BAF_OUT, '>', $ARGV[7] || die "cannot open $!";
open BAF_ALL, '>', $ARGV[8] || die "cannot open $!";

# list all the SNPs to be used
my %snp_list;
my $header = <BAF_INFO>;
while (<BAF_INFO>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $snp = join("\t", @curRow[ 0 .. 1 ]);
	$snp_list{$snp} = 1;
}
close(BAF_INFO);

# make a list of representative SNPs of each probe
my %filtered_probe;
my %snp2pos;
while (<BAF_FACTOR>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $snp = $curRow[3] . "\t" . $curRow[5];
	my $pos = $curRow[0] . "\t" . $curRow[1];
	
	if ( defined $snp_list{$snp} ) {
		$snp2pos{$snp} = $pos;
	} else {
		$filtered_probe{$pos} = 1;
	}
}
close(BAF_FACTOR);

while (<BAF_FACTOR_ALL>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $snp = $curRow[3] . "\t" . $curRow[5];
	my $pos = $curRow[0] . "\t" . $curRow[1];
	
	if ( defined $snp_list{$snp} ) {
		if ( defined $filtered_probe{$pos} ) {
			$snp2pos{$snp} = $pos;
			delete($filtered_probe{$pos});
		}
	}
}
close(BAF_FACTOR_ALL);

# load adjusted BAF of each probe
my %pos2baf;
my %pos2baf_org;
while (<BAF>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $baf = $curRow[2];
	next if ( $baf eq 'NA' );
	
	my $log_baf;
	my $homo = 0;
	if ( $baf < 0.05 ) {
		$homo = 1;
	} else {
		$log_baf = log( $baf * 2 ) / log(2);
	}
	
	my $snp = join("\t", @curRow[ 0 .. 1 ]);
	if ( defined $snp2pos{$snp} ) {
		$pos2baf{$snp2pos{$snp}} = $log_baf if ( $homo == 0 );
		$pos2baf_org{$snp2pos{$snp}} = $baf;
	} else {
		$pos2baf{$snp} = $log_baf if ( $homo == 0 );
		$pos2baf_org{$snp} = $baf;
	}
}
close(BAF);

# output (BAF)
foreach my $pos ( sort chrpos keys %pos2baf ) {
	my @items = split(/\t/, $pos);
	print BAF_OUT join(",", @items) . ',' . $pos2baf{$pos} . "\n";
}
close(BAF_OUT);

foreach my $pos ( sort chrpos keys %pos2baf_org ) {
	print BAF_ALL $pos . "\t" . $pos2baf_org{$pos} . "\n";
}
close(BAF_ALL);


# load depth of each probe
my %pos2depth;
while (<DEPTH>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $pos = join("\t", @curRow[ 0 .. 1 ]);
	$pos2depth{$pos} = $curRow[3];
}
close(DEPTH);

# output (depth)
my %pos2output;
$header = <ALL_DEPTH>;
while (<ALL_DEPTH>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my @info = split(/[:-]/, $curRow[0]);
	my $pos = join("\t", @info[ 0 .. 1 ]);
	if ( defined $pos2depth{$pos} ) {
		print DEPTH_OUT $pos . "\t" . $pos2depth{$pos} . "\n";
	} else {
		die "Something is wrong.$!";
	}
}
close(ALL_DEPTH);


# sort accoding to chromosome and position
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
