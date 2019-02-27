#! /usr/local/perl -w
use strict;

open PREDICTED, '<', $ARGV[0] || "die cannot open $!";
open ACTUAL,    '<', $ARGV[1] || "die cannot open $!";
open GENE_BED,  '<', $ARGV[2] || "die cannot open $!";


# load information on genes
my %probe2gene;
while (<GENE_BED>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $probe = join("\t", @curRow[ 0 .. 2 ]);
	$probe2gene{$probe} = $curRow[3];
}
close(GENE_BED);


# load predicted depth for each probe
my %gene2start;
my %gene2end;
my %gene2pred;
while (<PREDICTED>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $start = join("\t", @curRow[ 0 .. 1 ]);
	my $probe = join("\t", @curRow[ 0 .. 2 ]);
	my $length = $curRow[2] - $curRow[1];
	my $depth = $curRow[3];
	
	next if ( ! defined $probe2gene{$probe} );
	my @genes = split(/,/, $probe2gene{$probe});
	
	foreach my $gene ( @genes ) {
		if ( ! defined $gene2pred{$gene} ) {
			$gene2start{$gene} = $start;
			$gene2end{$gene} = $curRow[2];
			$gene2pred{$gene} = $curRow[3] * $length;
		} else {
			$gene2end{$gene} = $curRow[2];
			$gene2pred{$gene} += $curRow[3] * $length;
		}
	}
}
close(PREDICTED);

my %gene2actual;
while (<ACTUAL>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $probe = join("\t", @curRow[ 0 .. 2 ]);
	my $length = $curRow[2] - $curRow[1];
	my $depth = $curRow[3];
	
	next if ( ! defined $probe2gene{$probe} );
	my @genes = $probe2gene{$probe};
	
	foreach my $gene ( @genes ) {
		if ( ! defined $gene2actual{$gene} ) {
			$gene2actual{$gene} = $curRow[3] * $length;
		} else {
			$gene2actual{$gene} += $curRow[3] * $length;
		}
	}
}
close(ACTUAL);

my %start2info;
foreach my $gene ( keys %gene2start ) {
	my $start = $gene2start{$gene};
	
	my $actual = 0;
	$actual = $gene2actual{$gene} if ( defined $gene2actual{$gene} );
	
	next if ( ! defined $gene2pred{$gene} );
	my $pred = $gene2pred{$gene};
	my $rate = 0;
	$rate =$actual / $pred if ( $pred > 0 );
	
	$start2info{$start} = $start . "\t" . $gene2end{$gene} . "\t" . $rate . "\t" . $gene;
}

foreach my $start ( sort chrpos keys %start2info ) {
	print $start2info{$start} . "\n";
}


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
