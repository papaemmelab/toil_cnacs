open IN1, '<', $ARGV[0];
open IN2, '<', $ARGV[1];

my %target;
while (<IN1>) {
	s/[\r\n]//g;
	$target{$_} = 1;
}

my %done;
while (<IN2>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	print $curRow[3] . "\t" . $curRow[5] . "\n" if ( defined $target{$curRow[3]} );
	$done{$curRow[3]} = 1 if ( defined $target{$curRow[3]} );
}

foreach my $gene ( keys %target ) {
	print $gene . "\t" . 'NA' . "\n" if ( ! defined $done{$gene} );
}
