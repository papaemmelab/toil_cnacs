#! /usr/local/bin/perl -w
use strict;

open IN, '<', $ARGV[0] || die "cannot open $!";
open SEGMENT, '<', $ARGV[1] || die "cannot open $!";
open ALL_POS, '<', $ARGV[2] || die "cannot open $!";


# define regions with copy number alterations
my %start2end;
my %start2ploidy;
while (<SEGMENT>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $ploidy = $curRow[5];
	next if ( $ploidy eq 'NA' );
	next if ( ( $ploidy < 2.2 ) && ( $ploidy > 1.818181818 ) ); # equivalent to 10%
	
	my $chr_num = $curRow[1];
	next if ( $chr_num > 22 );
	
	my $chr = 'chr' . $chr_num;
	my $start = $curRow[2];
	my $end = $curRow[3];
	my $key = $chr . "\t" . $start;
	
	$start2end{$key} = $end;
	$start2ploidy{$key} = $ploidy;
}
close(SEGMENT);


# adjust depth signals based on copy number alterations
my %pos2ploidy;
my $cur_ploidy = 2;
my $cur_end;

while (<ALL_POS>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $chr = $curRow[0];
	my $pos = $curRow[1];
	my $key = $chr . "\t" . $pos;
	
	if ( ( $chr eq 'chrX' ) || ( $chr eq 'chrY' ) ) {
		$pos2ploidy{$key} = 2;
		next;
	}
	
	if ( $cur_ploidy == 2 ) {
		if ( defined $start2end{$key} ) {
			$cur_end = $start2end{$key};
			$cur_ploidy = $start2ploidy{$key};
			$pos2ploidy{$key} = $cur_ploidy;
		} else {
			$pos2ploidy{$key} = 2;
		}
	} else {
		if ( $pos == $cur_end ) {
			$pos2ploidy{$key} = $cur_ploidy;
			$cur_ploidy = 2;
			$cur_end = "";
		} else {
			$pos2ploidy{$key} = $cur_ploidy;
		}
	}
}
close(ALL_POS);

my $pre_ploidy = 2;
while (<IN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $key = join("\t", @curRow[ 0 .. 1 ]);
	my $depth;
	if ( defined $pos2ploidy{$key} ) {
		$depth = $curRow[2] * 2 / $pos2ploidy{$key};
		$pre_ploidy = $pos2ploidy{$key};
	} else {
		$depth = $curRow[2] * 2 / $pre_ploidy;
	}
	
	print $key . "\t" . $depth . "\n";
}
close(IN);
