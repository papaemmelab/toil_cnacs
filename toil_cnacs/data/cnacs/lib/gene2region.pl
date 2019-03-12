open IN, '<', $ARGV[0];

my %start2gene;
my %gene2end;

while (<IN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	
	my $start = $curRow[0] . "\t" . $curRow[1];
	my @items = split(/;/, $curRow[3]);
	my @genes;
	foreach my $item ( @items ) {
		my @info = split(/\(/, $item);
		if ( ! defined $gene2end{$info[0]} ) {
			if ( ! defined $start2gene{$start} ) {
				$start2gene{$start} = $info[0];
			} else {
				$start2gene{$start} .= ',' . $info[0];
			}
		}
		$gene2end{$info[0]} = $curRow[2];
	}
	
}

foreach my $pos ( sort chrpos keys %start2gene ) {
	my @genes = split(/,/, $start2gene{$pos});
	my %done;
	foreach my $gene ( @genes ) {
		my $end = $gene2end{$gene};
		next if ( defined $done{$end} );
		print $pos . "\t" . $end . "\t" . $gene . "\n";
		$done{$end} = 1;
	}
}

# sort accoding to chromosome and position
sub chrpos {
	my @posa = split("\t", $a);
	my @posb = split("\t", $b);
	
	$posa[0] =~ s/chr//g;
	$posb[0] =~ s/chr//g;
	
	$posa[0] =~ s/X/23/g;
	$posb[0] =~ s/X/23/g;
	
	$posa[0] =~ s/Y/24/g;
	$posb[0] =~ s/Y/24/g;
	
	$posa[0] =~ s/M/25/g;
	$posb[0] =~ s/M/25/g;
	
	if ($posa[0] > $posb[0]) {
		return 1;
	} elsif ($posa[0] < $posb[0]) {
		return -1;
	} else {
		if ($posa[1] > $posb[1]) {
			return 1;
		} else {
			return -1;
		}
	}
}
