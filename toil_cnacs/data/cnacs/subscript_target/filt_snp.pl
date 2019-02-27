#! /usr/local/bin/perl -w
use strict;

while (<STDIN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $info = join("\t", @curRow[ 0 .. 2 ]);
	my @hetero_baf = ();
	
	my $id = 0;
	foreach my $baf ( @curRow[ 3 .. $#curRow ] ) {
		next if ( $baf eq 'NA' );
		if ( ( $baf >= 0.1 ) && ( $baf <= 0.9 ) ) {
			push( @hetero_baf, $baf );
		} else {
			next;
		}
	}
	
	print $info . "\t" . join("\t", @hetero_baf) . "\n";
}
