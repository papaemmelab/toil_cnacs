#! /usr/local/bin/perl -w
use strict;

while (<STDIN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $info = join("\t", @curRow[ 0 .. 3 ]);
	my @array = @curRow[ 4 .. $#curRow ];
	my @stat = &stat( @array );
	next if ( $stat[1] eq 'nan' );
	
	print $info . "\t" . $stat[0] . "\t" . $stat[1] . "\t" . join("\t", @array) . "\n";
}


sub stat {
	my $number = @_;
	if ( $number == 0 ) {
		return('NA', 'NA');
	} else {
		my $sum = 0;
		foreach my $item ( @_ ) {
			next if ( $item eq 'NA' );
			$sum += $item;
		}
		my $mean = $sum / $number;
		
		my $square_sum = 0;
		foreach my $item ( @_ ) {
			if ( $item eq 'NA' ) {
				$square_sum += ( $mean )**2;
				next;
			}
			$square_sum += ( $item - $mean )**2;
		}
		my $sd = ( $square_sum / $number )**(1/2);
		my $coefVar;
		if ( $mean == 0 ) {
			$coefVar = 'NA';
		} else {
			$coefVar = $sd / $mean;
		}
		
		return($mean, $coefVar);
	}
}
