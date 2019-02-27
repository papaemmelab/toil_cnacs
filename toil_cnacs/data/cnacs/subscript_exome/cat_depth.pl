#! /usr/local/bin/perl -w
use strict;

my @files = @ARGV;
my %start2end;
my %start2gene;
my %start2sig;
my $file_num = -1;

foreach my $file ( @files ) {
	open IN, '<', $file || die "cannot open $!";
	my %cur_sig;
	while (<IN>) {
		s/[\r\n]//g;
		my @curRow = split(/\t/, $_);
		my $start = join("\t", @curRow[ 0 .. 1 ]);
		if ( ! defined $start2end{$start} ) {
			$start2end{$start}  = $curRow[2];
			$start2gene{$start} = $curRow[-1];
		}
		
		$cur_sig{$start} = $curRow[-2];
	}
	$file_num++;
	close(IN);
	
	foreach my $pos ( keys %start2sig ) {
		if ( defined $cur_sig{$pos} ) {
			$start2sig{$pos} .= "\t" . $cur_sig{$pos};
		} else {
			$start2sig{$pos} .= "\t" . 'NA';
		}
	}
	
	foreach my $pos ( keys %cur_sig ) {
		next if ( defined $start2sig{$pos} );
		if ( $file_num == 0 ) {
			$start2sig{$pos} = $cur_sig{$pos};
		} else {
			$start2sig{$pos} = 'NA' x $file_num . "\t" . $cur_sig{$pos};
		}
	}
}

foreach my $pos ( sort chrpos keys %start2sig ) {
	print $pos . "\t" . $start2end{$pos} . "\t" . $start2gene{$pos} . "\t" . $start2sig{$pos} . "\n";
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
