#! /usr/local/perl -w
use strict;

while (<STDIN>) {
	s/[\r\n]//g;
	my @F = split(/\t/, $_);
	print $_ . "\n" if ( ( $F[1] < $F[2] ) && ( $F[5] ne 'nan' ) );
}
