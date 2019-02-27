#! /usr/local/perl -w
use strict;

open SIGNAL, '<', $ARGV[0] || die "cannot open $!";
open IN, '<', $ARGV[1] || die "cannot open $!";

# define SNPs nearest to chromosomal ends
my %short2pos;
my %long2pos;
my $cur_chr = 'chr0';
my $pre_pos = 0;
while (<SIGNAL>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	next if ( $curRow[3] eq 'NA' );
	my $chr = $curRow[0];
	
	if ( $cur_chr eq 'chr0' ) {
		$cur_chr = $chr;
		$short2pos{$chr} = $curRow[1];
	} elsif ( $cur_chr ne $chr ) {
		$long2pos{$cur_chr} = $pre_pos;
		$cur_chr = $chr;
		$short2pos{$chr} = $curRow[1];
	}
	$pre_pos = $curRow[1];
}
close(SIGNAL);

# acrocentric chromosomes
delete($short2pos{'chr13'});
delete($short2pos{'chr14'});
delete($short2pos{'chr15'});
delete($short2pos{'chr21'});
delete($short2pos{'chr22'});

# filter called CNAs
while (<IN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $chr_num = $curRow[1];
	my $ploidy = $curRow[5];
	my $as = $curRow[6];
	
	if ( ( $chr_num <= 22 ) && ( $ploidy >= 1.9 ) && ( $ploidy <= 2.1 ) ) {
		my $chr = 'chr' . $chr_num;
		my $start = $curRow[2];
		my $end = $curRow[3];
		
		my $flag = 0;
		if ( defined $short2pos{$chr} ) {
			$flag = 1 if ( $start <= $short2pos{$chr} );
		}
		if ( defined $long2pos{$chr} ) {
			$flag = 1 if ( $end >= $long2pos{$chr} );
		}
		next if ( $flag == 0 );
	}
	
	print $_ . "\n";
}
close(IN)
