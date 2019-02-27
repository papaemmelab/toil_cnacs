#! /usr/loca/bin/perl -w
use strict;

my $region = $ARGV[0];
open ARM, '<', $ARGV[1] || die "cannot open $!";

my %chr2length;
my %chr2short;
my %chr2long;
while (<ARM>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $chr = $curRow[0];
	my $centromere = $curRow[1];
	my $total = $curRow[1] + $curRow[2];
	
	$chr2length{$chr} = '0-' . $total;
	$chr2short{$chr} = '0-' . $centromere;
	$chr2long{$chr} = $centromere . '-' . $total;
}
close(ARM);

my $chr_num;
my $pos;
my $flag = 0;
if ( $region =~ /^chr/ ) {
	if ( $region =~ /^chr([\d]+)\:([\d]+)\-([\d]+)$/ ) {
		
		$chr_num = $1;
		if ( ( $chr_num == 0 ) || ( $chr_num > 22 ) ) {
			$flag = 1;
		}
		my $start = $2;
		my $end = $3;
		$flag = 1 if ( $start >= $end );
		$pos = $start . '-' . $end;
		
	} elsif ( $region =~ /^chr([\d]+)$/  ) {
		
		$chr_num = $1;
		if ( ( $chr_num == 0 ) || ( $chr_num > 22 ) ) {
			$flag = 1;
		}
		my $chr = 'chr' . $chr_num;
		$pos = $chr2length{$chr};
		
	} else {
		$flag = 1;
	}
} else {
	if ( $region =~ /([\d]+)([pq])/ ) {
		
		$chr_num = $1;
		if ( ( $chr_num == 0 ) || ( $chr_num > 22 ) ) {
			$flag = 1;
		} else {
			my $chr = 'chr' . $chr_num;
			my $arm = $2;
			if ( $arm eq 'p' ) {
				$pos = $chr2short{$chr};
			} else {
				$pos = $chr2long{$chr};
			}
		}
		
	} else {
		$flag = 1;
	}
}

if ( $flag == 1 ) {
	print "Error: inappropriate form of a region name\n";
	exit 1;
}

print 'chr' . $chr_num . ':' . $pos;
