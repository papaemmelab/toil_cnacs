#! /usr/local/bin/perl -w
use strict;
open IN, '<', $ARGV[0] || die "cannot open $!";
open BAIT, '<', $ARGV[1] || die "cannot open $!";
my $total = $ARGV[2];

my %cum_length;
$cum_length{'chr1'} = 0;
$cum_length{'chr2'} = 249250621;
$cum_length{'chr3'} = 492449994;
$cum_length{'chr4'} = 690472424;
$cum_length{'chr5'} = 881626700;
$cum_length{'chr6'} = 1062541960;
$cum_length{'chr7'} = 1233657027;
$cum_length{'chr8'} = 1392795690;
$cum_length{'chr9'} = 1539159712;
$cum_length{'chr10'} = 1680373143;
$cum_length{'chr11'} = 1815907890;
$cum_length{'chr12'} = 1950914406;
$cum_length{'chr13'} = 2084766301;
$cum_length{'chr14'} = 2199936179;
$cum_length{'chr15'} = 2307285719;
$cum_length{'chr16'} = 2409817111;
$cum_length{'chr17'} = 2500171864;
$cum_length{'chr18'} = 2581367074;
$cum_length{'chr19'} = 2659444322;
$cum_length{'chr20'} = 2718573305;
$cum_length{'chr21'} = 2781598825;
$cum_length{'chr22'} = 2829728720;
$cum_length{'chrX'} = 2881033286;
$cum_length{'chrY'} = 3036303846;

my %pos2id;
my $id = 0;
while (<BAIT>) {
	$id++;
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $pos = join("\t", @curRow[ 0 .. 1 ]);
	$pos2id{$pos} = $id;
}
close(BAIT);

# Initialize
my %id2gain;
my %id2loss;

foreach my $num ( 1 .. $id ) {
	$id2gain{$num} = 0;
	$id2loss{$num} = 0;
}

while (<IN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $total = $curRow[5];
	my $allelic_ratio = $curRow[6];
	next if ( $total eq 'NA' );
	
	my $chr_num = $curRow[1];
	my $chr = 'chr' . $chr_num;
	if ( $chr_num == 23 ) {
		$chr = 'chrX';
	}
	my $pos1 = $chr . "\t" . $curRow[2];
	my $pos2 = $chr . "\t" . $curRow[3];
	
	my $id1;
	if ( defined $pos2id{$pos1} ) {
		$id1 = $pos2id{$pos1};
	} else {
		my $diff = 1000000000000;
		my $tmp_base;
		foreach my $pos ( sort chrpos keys %pos2id ) {
			my @info = split(/\t/, $pos);
			next if ( $info[0] ne $chr );
			my $tmp_diff = $info[1] - $curRow[3];
			if ( $tmp_diff < $diff ) {
				$diff = $tmp_diff;
				$tmp_base = $info[1];
			}
		}
		
		my $tmp_pos = $chr . "\t" . $tmp_base;
		$id1 = $pos2id{$tmp_pos};
	}
	
	my $id2;
	if ( defined $pos2id{$pos2} ) {
		$id2 = $pos2id{$pos2};
	} else {
		my $diff = 1000000000000;
		my $tmp_base;
		foreach my $pos ( sort chrpos keys %pos2id ) {
			my @info = split(/\t/, $pos);
			next if ( $info[0] ne $chr );
			my $tmp_diff = $info[1] - $curRow[3];
			if ( $tmp_diff < $diff ) {
				$diff = $tmp_diff;
				$tmp_base = $info[1];
			}
		}
		
		my $tmp_pos = $chr . "\t" . $tmp_base;
		$id2 = $pos2id{$tmp_pos};
	}
	
	if ( $total > 2 ) {
		if ( $allelic_ratio ne 'NA' ) {
			next if ( ( $total < 2.2 ) && ( $allelic_ratio < 3 - $total  ) );  # considered to be UPD
		}
		foreach my $id ( $id1 .. $id2 ) {
			$id2gain{$id}++;
		}
	} else {
		if ( $allelic_ratio ne 'NA' ) {
			next if ( ( $total > 1.8 ) && ( $allelic_ratio < 1.5 * $total - 2  ) );  # considered to be UPD
		}
		foreach my $id ( $id1 .. $id2 ) {
			$id2loss{$id}++;
		}
	}
}
close(IN);


# Output
foreach my $pos ( sort chrpos keys %pos2id ) {
	my $id = $pos2id{$pos};
	
	my @info = split(/\t/, $pos);
	my $chr = $info[0];
	my $base = $info[1];
	if ( defined $cum_length{$chr} ) {
		$base += $cum_length{$chr};
	} else {
		die "Unidentified chromosomes are included.";
	}
	$base = $base / 1000000;
	
	my $gain_freq = $id2gain{$id} * 100 / $total;
	my $loss_freq = $id2loss{$id} * 100 / $total;
	
	print $base . "\t" . $gain_freq . "\t" . $loss_freq . "\n";
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
