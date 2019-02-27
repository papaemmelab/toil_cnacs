#! /usr/loca/bin/perl -w
use strict;

my $tag = $ARGV[0];

if ( $tag =~ /[^\w:-]/ ) {
	print "TAG : " . $tag . "\n";
	print "Please use only letters(a-z A-Z), numbers(0-9), underbar(_), hyphen(-) or colon(:) on TAG's parameter." . "\n";
	exit 1;
}
