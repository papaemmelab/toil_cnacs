#! /usr/local/bin/perl -w
use strict;

my $probe = shift(@ARGV);
my @files = @ARGV;
my %baf_hash;

open PROBE, '<', $probe || die "cannot open $!";
while (<PROBE>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $key = $curRow[0] . "\t" . $curRow[2];
	$baf_hash{$key} = $curRow[-1];
}
close(PROBE);

foreach my $file ( @files ) {
	open IN, '<', $file || die "cannot open $!";
	my %cur_baf = ();
	while (<IN>) {
		s/[\r\n]//g;
		my @curRow = split(/\t/, $_);
		my $key = join("\t", @curRow[ 0 .. 1 ]);
		$cur_baf{$key} = $curRow[-1];
	}
	close(IN);
	
	foreach my $key ( sort keys %baf_hash ) {
		if ( defined $cur_baf{$key} ) {
			$baf_hash{$key} = $baf_hash{$key} . "\t" . $cur_baf{$key};
		} else {
			$baf_hash{$key} = $baf_hash{$key} . "\t" . 'NA';
		}
	}
}

foreach my $key ( sort keys %baf_hash ) {
	print $key . "\t" . $baf_hash{$key} . "\n";
}
