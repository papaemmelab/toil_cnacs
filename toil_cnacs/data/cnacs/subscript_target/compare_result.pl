#! /usr/local/perl -w
use strict;

open PRE, '<', $ARGV[0] || die "cannot open $!";
open NOW, '<', $ARGV[1] || die "cannot open $!";

my $line = 0;
my %line2region;
my %line2total;
my %line2as;
while (<PRE>) {
	$line++;
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $region = join("\t", @curRow[ 1 .. 3 ]);
	my $total = $curRow[5];
	my $as = $curRow[6];
	$line2region{$line} = $region;
	$line2total{$line} = $total;
	$line2as{$line} = $as;
}
close(PRE);


$line = 0;
while (<NOW>) {
	$line++;
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $region = join("\t", @curRow[ 1 .. 3 ]);
	my $total = $curRow[5];
	my $as = $curRow[6];
	
	last if ( ! defined $line2region{$line} );
	
	if ( $region ne $line2region{$line} ) {
		print $_ . "\n";
	} else {
		next if ( ( $total eq 'NA' ) || ( $line2total{$line} eq 'NA' ) );
		my $total_diff = ( $total - $line2total{$line} ) / $line2total{$line};
		print $_ . "\n" if ( abs( $total_diff ) > 0.01 );
	}
}
close(NOW);
