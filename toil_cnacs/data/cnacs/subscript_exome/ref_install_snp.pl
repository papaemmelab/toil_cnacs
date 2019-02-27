#! /usr/local/bin/perl -w
use strict;

# Filtering based on BAF
open BAF_INFO, '<', $ARGV[0] || die "cannot open $!";
open BAF_INFO_FILT, '>', $ARGV[1] || die "cannot open $!";
my $baf_mean_lower = $ARGV[2];
my $baf_mean_upper = $ARGV[3];
my $baf_coefvar_upper = $ARGV[4];

my $header = <BAF_INFO>;
print BAF_INFO_FILT $header;
while (<BAF_INFO>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $mean = $curRow[4];
	my $coefvar = $curRow[5];
	next if ( $coefvar eq 'NA' );
	
	print BAF_INFO_FILT $_ . "\n" unless ( ( $mean < $baf_mean_lower ) || ( $mean > $baf_mean_upper ) || ( $coefvar > $baf_coefvar_upper ) || ( $coefvar == 0 ) );
}
close(BAF_INFO);
close(BAF_INFO_FILT);
