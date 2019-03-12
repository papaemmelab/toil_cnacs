#! /usr/local/perl -w
use strict;

open IN,  '<', $ARGV[0] || "die cannot open $!";

my $tmp_gene = '';
my $tmp_chr = 'chr0';
my $tmp_start = '';
my $tmp_end = '';

while (<IN>) {
	s/[\r\n]//g;
	my @F = split(/\t/, $_);
	
	# define a gene name
	my $gene = '';
	if ( $F[-1] =~ /\((.+)\)/ ) {
		$gene = $1;
	}
	# end of gene name definition
	
	# initialize ( only in the first line )
	if ( $tmp_chr eq 'chr0' ) {
		$tmp_chr = $F[0];
		$tmp_start = $F[1];
		$tmp_end = $F[2];
		$tmp_gene = $gene;
		next;
	}
	# end of initialization
	
	if ( $gene ne $tmp_gene ) {
		# output
		print $tmp_chr . "\t" . $tmp_start . "\t" . $tmp_end . "\t" . $tmp_gene . "\n";
		$tmp_chr = $F[0];
		$tmp_start = $F[1];
		$tmp_end = $F[2];
		$tmp_gene = $gene;
	} else {
		# up date the last coordinate
		$tmp_end = $F[2];
	}
}
close(IN);

# output of the information on the last gene
print $tmp_chr . "\t" . $tmp_start . "\t" . $tmp_end . "\t" . $tmp_gene . "\n";
