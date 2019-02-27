#! /usr/local/bin/perl -w
use strict;

# check wheter input quality threshoold is appropriate or not.
my $thres = $ARGV[0];
open PROBE, '<', $ARGV[1] || die "cannot open $!";

if ( $thres < 0 || $thres > 40) {
	die "input quality threshould is not appropriate.$!";
}

# prepare quality strings to be removed
my $filterQuals = "";
for ( my $i = 33; $i < 33 + $thres; $i++ ) {
	$filterQuals .= chr($i);
}

my %snp;
while (<PROBE>) {
	s/[\r\n]//g;
	my @curRow = split("\t", $_);
	my $key = $curRow[0] . "\t" . $curRow[2];
	
	$snp{$key} = join("\t", @curRow[ $#curRow - 2 .. $#curRow ]);
}
close(PROBE);

while (<STDIN>) {
	s/[\r\n]//g;
	my @curRow = split("\t", $_);
	my $chr = $curRow[0];
	my $pos = $curRow[1];
	my $key = $chr . "\t" . $pos;
	next if ( ! defined $snp{$key} );
	my $bait_info = $snp{$key};
	
	my $ref = $curRow[2];
	my $depth = $curRow[3];
	my $seq = $curRow[4];
	
	if ( $depth > 0 ) {
		# remove insertion and deletion
		while ( $seq =~ m/\+([0-9]+)/g ) {
			my $num = $1;
			my $site = pos $seq;
			substr($seq, $site - length($num) - 1, $num + length($num) + 1, "");
		}
		
		while ( $seq =~ m/\-([0-9]+)/g ) {
			my $num = $1;
			my $site = pos($seq);
			substr($seq, $site - length($num) - 1, $num + length($num) + 1, "");
		}
		
		# remove start marks
		$seq =~ s/\^.//g;
		
		# remove end marks
		$seq =~ s/\$//g;
		
		# for debugging
		if ( length($seq) != length($curRow[5]) ) {
			print "something is wrong!!!\n";
			print length($seq) . "\t" . length($curRow[5]) . "\n";
		}
		
		$seq =~ s/\./$ref/g;
		$seq =~ s/,/$ref/g;
		$seq = uc $seq;
		
		my %base2qual;
		$base2qual{"A"} = "";
		$base2qual{"C"} = "";
		$base2qual{"G"} = "";
		$base2qual{"T"} = "";
		$base2qual{"N"} = "";
		
		my @bases = split("", $seq);
		my @quals = split("", $curRow[5]);
		for ( my $ii = 0; $ii <= $#bases; $ii++ ) {
			$base2qual{$bases[$ii]} .= $quals[$ii];
		}
		
		foreach my $base ( keys %base2qual ) {
			$base2qual{$base} =~ s/[$filterQuals]//g;
		}
		
		$depth += -1 * length($base2qual{"N"});
		print $chr . "\t". $pos . "\t". $ref. "\t". $depth . "\t";
		print length($base2qual{"A"}) . "\t" . length($base2qual{"C"}) . "\t" . length($base2qual{"G"}) . "\t" . length($base2qual{"T"}) . "\t" . $bait_info . "\n";
		
	} else {
		print $chr . "\t" . $pos . "\t" . $ref . "\t" . "0\t0\t0\t0\t0" . "\t" . $bait_info . "\n";
	}
}
