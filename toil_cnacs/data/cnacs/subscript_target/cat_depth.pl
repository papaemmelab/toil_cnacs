#! /usr/local/bin/perl -w
use strict;

my $probe = shift(@ARGV);
my @files = @ARGV;
my %depth_hash;

open PROBE, '<', $probe || die "cannot open $!";
while (<PROBE>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $chr = $curRow[0];
	next unless ( ( $chr =~ /^chr[\d]+$/ ) || ( $chr eq 'chrX' ) );
	my $key = join("\t", @curRow[ 0 .. 1 ]);
	$depth_hash{$key} = $curRow[2];
}
close(PROBE);

foreach my $file ( @files ) {
	open IN, '<', $file || die "cannot open $!";
	my %cur_depth = ();
	while (<IN>) {
		s/[\r\n]//g;
		my @curRow = split(/\t/, $_);
		my $key = join("\t", @curRow[ 0 .. 1 ]);
		$cur_depth{$key} = $curRow[-1];
	}
	close(IN);
	
	foreach my $key ( sort keys %depth_hash ) {
		if ( defined $cur_depth{$key} ) {
			$depth_hash{$key} = $depth_hash{$key} . "\t" . $cur_depth{$key};
		} else {
			$depth_hash{$key} = $depth_hash{$key} . "\t" . 'NA';
		}
	}
}

foreach my $key ( sort keys %depth_hash ) {
	print $key . "\t" . $depth_hash{$key} . "\n";
}
