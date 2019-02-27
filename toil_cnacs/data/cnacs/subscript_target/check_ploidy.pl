#! /usr/loca/bin/perl -w
use strict;

my $ploidy = $ARGV[0];

if ( $ploidy =~ /\D/ ) {
	print "Error: ploidy should be a number.\n";
	exit 1;
} elsif ( ( $ploidy != 1 ) && ( $ploidy != 2 ) && ( $ploidy != 3 ) ) {
	print "Error: ploidy should be either 1, 2 or 3.\n";
	exit 1;
}
