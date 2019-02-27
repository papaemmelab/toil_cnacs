#! /usr/local/bin/perl -w
use strict;

# Output regions coding target genes
open PROBE_BED, '<', $ARGV[0] || die "cannot open $!";
open GENE_REGION, '>', $ARGV[5] || die "cannot open $!";

my $col_num;
my %gene2chr;
my %gene2start;
my %gene2end;
while (<PROBE_BED>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	
	$col_num = @curRow;
	if ( $col_num > 3 ) {
		my @items = split(/[,;:]/, $curRow[3]);
		next if ( $items[0] =~ /^rs[\d]+$/ );
		next if ( $items[0] =~ /^chr[0-9XYM]/ );
		if ( defined $gene2chr{$curRow[3]} ) {
			$gene2start{$curRow[3]} = $curRow[1] if ( $curRow[1] < $gene2start{$curRow[3]} );
			$gene2end{$curRow[3]} = $curRow[2] if ( $curRow[2] > $gene2end{$curRow[3]} );
		} else {
			$gene2chr{$curRow[3]} = $curRow[0];
			$gene2start{$curRow[3]} = $curRow[1];
			$gene2end{$curRow[3]} = $curRow[2];
		}
	}
}
close(PROBE_BED);

foreach my $tmp_gene ( sort keys %gene2chr ) {
	print GENE_REGION $tmp_gene . "\t" . $gene2chr{$tmp_gene} . "\t" . $gene2start{$tmp_gene} . "\t" . $gene2end{$tmp_gene} . "\n";
}
close(GENE_REGION);


# Filtering based on BAF
open BAF_INFO, '<', $ARGV[1] || die "cannot open $!";
open BAF_INFO_FILT, '>', $ARGV[3] || die "cannot open $!";
my $baf_mean_lower = $ARGV[6];
my $baf_mean_upper = $ARGV[7];
my $baf_coefvar_upper = $ARGV[8];

my $header = <BAF_INFO>;
print BAF_INFO_FILT $header;
while (<BAF_INFO>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $mean = $curRow[4];
	my $coefvar = $curRow[5];
	
	print BAF_INFO_FILT $_ . "\n" unless ( ( $mean < $baf_mean_lower ) || ( $mean > $baf_mean_upper ) || ( $coefvar > $baf_coefvar_upper ) || ( $coefvar == 0 ) );
}
close(BAF_INFO);
close(BAF_INFO_FILT);


# Filtering based on depth
open DEPTH_INFO, '<', $ARGV[2] || die "cannot open $!";
open ALL_DEPTH, '>>', $ARGV[4] || die "cannot open $!";
my $depth_mean_lower = $ARGV[9];
my $depth_mean_upper = $ARGV[10];
my $depth_coefvar_upper = $ARGV[11];
my %all_output;

while (<DEPTH_INFO>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $mean = $curRow[3];
	my $coefvar = $curRow[4];
	next if ( $coefvar eq 'NA' );
	next if ( ( $mean < $depth_mean_lower ) || ( $mean > $depth_mean_upper ) || ( $coefvar > $depth_coefvar_upper ) );
	
	my $pos = $curRow[0] . "\t" . $curRow[1];
	$all_output{$pos} = $curRow[0] . ':' . $curRow[1] . '-' . $curRow[2] . "\t" . join("\t", @curRow[ 5 .. $#curRow ]);
}
close(DEPTH_INFO);

foreach my $pos ( sort chrpos keys %all_output ) {
	print ALL_DEPTH $all_output{$pos} . "\n";
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
