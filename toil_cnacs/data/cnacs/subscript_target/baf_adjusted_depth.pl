#! /usr/local/perl -w
use strict;

open SCALE, '<', $ARGV[0] || die "cannot open $!";

my %probe2scale;
while (<SCALE>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $probe = join("\t", @curRow[ 0 .. 2 ]);
	$probe2scale{$probe} = $curRow[3];
}
close(SCALE);

my %probe2base;
while (<STDIN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $probe = join("\t", @curRow[ 3 .. 5 ]);
	my $scale = 1;
	if ( defined $probe2scale{$probe} ) {
		$scale = $probe2scale{$probe};
	}
	
	my $overlap = $curRow[-1];
	if ( ! defined $probe2base{$probe} ) {
		$probe2base{$probe} = $overlap * $scale;
	} else {
		$probe2base{$probe} += $overlap * $scale;
	}
}

foreach my $tmp_probe ( sort chrpos keys %probe2base ) {
	my @probe_info = split(/\t/, $tmp_probe);
	my $probe_length = $probe_info[2] - $probe_info[1];
	my $depth = $probe2base{$tmp_probe} / $probe_length;
	print $tmp_probe . "\t" . $depth . "\n";
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
