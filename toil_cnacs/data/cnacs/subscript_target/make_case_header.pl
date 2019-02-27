#! /usr/local/bin/perl -w
use strict;

my @files = @ARGV;
my @ids;

foreach my $file ( @files ) {
	$file =~ s/[\r\n]//g;
	my @items = split(/\//, $file);
	my $id = $items[-3];
	push(@ids, $id);
}

print join("\t", @ids) . "\n";
