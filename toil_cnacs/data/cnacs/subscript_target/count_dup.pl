#! /usr/local/perl -w
use strict;

my $first_quartile = $ARGV[0];
my $median = $ARGV[1];
my $third_quartile = $ARGV[2];

my $bin1_all = 0;
my $bin2_all = 0;
my $bin3_all = 0;
my $bin4_all = 0;
my $bin1_dup = 0;
my $bin2_dup = 0;
my $bin3_dup = 0;
my $bin4_dup = 0;

while (<STDIN>) {
	s/[\r\n]//g;
	next if ( $_ =~ /^@/ );
	
	my @curRow = split(/\t/, $_);
	my $flag = $curRow[1];
	my @flags = reverse split(//, sprintf("%011b", $flag));
	my $length = abs ($curRow[8]);
	
	next unless ( $flags[6] == 1 );
	if ( $length < $first_quartile ) {
		$bin1_all++;
		$bin1_dup++ if ( $flags[10] == 1 );
	} elsif ( $length < $median ) {
		$bin2_all++;
		$bin2_dup++ if ( $flags[10] == 1 );
	} elsif ( $length < $third_quartile ) {
		$bin3_all++;
		$bin3_dup++ if ( $flags[10] == 1 );
	} else {
		$bin4_all++;
		$bin4_dup++ if ( $flags[10] == 1 );
	}
}

my $bin1_dup_rate = $bin1_dup / $bin1_all;
my $bin2_dup_rate = $bin2_dup / $bin2_all;
my $bin3_dup_rate = $bin3_dup / $bin3_all;
my $bin4_dup_rate = $bin4_dup / $bin4_all;

print $bin1_dup_rate . "\n";
print $bin2_dup_rate . "\n";
print $bin3_dup_rate . "\n";
print $bin4_dup_rate . "\n";
