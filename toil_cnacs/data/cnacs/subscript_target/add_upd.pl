#! /usr/local/bin/perl -w
use strict;

open BAF_ALL, '<', $ARGV[0] || die "cannot open $!";
open SIGNAL,  '<', $ARGV[1] || die "cannot open $!";
open RES_TMP, '<', $ARGV[2] || die "cannot open $!";
my $id = $ARGV[3];
open GENE_INFO, '<', $ARGV[4] || die "cannot open $!";


# load informaion on already called CNAs
my %pos2info;
my %pos2info_undef;
my %start2end;
my %start2end_undef;

while (<RES_TMP>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $pos = 'chr' . join("\t", @curRow[ 1 .. 2 ]);
	$pos2info{$pos} = $_;
	$start2end{$pos} = $curRow[3];
	if ( $curRow[6] eq 'NA' ) {
		$pos2info_undef{$pos} = $_;
		$start2end_undef{$pos} = $curRow[3];
	}
}
close(RES_TMP);


# define regions with CNAs
my %cna_region;
my $cur_end;
my $processing = 0;
while (<SIGNAL>) {
	my @curRow = split(/\t/, $_);
	my $chr = $curRow[0];
	my $pos = $curRow[1];
	my $key = $chr . "\t" . $pos;
	
	if ( $processing == 1 ) {
		$cna_region{$key} = 1;
		if ( $pos == $cur_end ) {
			$cur_end = '';
			$processing = 0;
		}
	} else {
		if ( defined $pos2info{$key} ) {
			$cna_region{$key} = 1;
			$cur_end = $start2end{$key};
			$processing = 1;
		}
	}
}
close(SIGNAL);


# define regions with unidentified UPDs
my %upd_region;
my %region2baf_all;
my $cur_chr = 'chr0';
my $cur_start;
my @cur_bafs;
my $homo_num = 0;
my $short_flag;
my $pre_pos;
while (<BAF_ALL>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $chr = $curRow[0];
	my $pos = $curRow[1];
	my $baf = $curRow[2];
	my $key = $chr . "\t" . $pos;
	
	if ( $chr ne $cur_chr ) {
		if ( $homo_num >= 40 ) {
			$upd_region{$cur_start} = $pre_pos;
			$region2baf_all{$cur_start} = join(",", @cur_bafs);
		}
		$cur_chr = $chr;
		@cur_bafs = ();
		$homo_num = 0;
		$short_flag= 1;
	}
	
	next if ( $baf eq 'NA' );
	if ( ( $baf < 0.2 ) && ( ! defined $cna_region{$key} ) ) {
		$cur_start = $chr . "\t" . $pos if ( $homo_num == 0 );
		push(@cur_bafs, $baf);
		$homo_num++;
		$pre_pos = $pos;
	} else {
		if ( $short_flag == 1 ) {
			if ( ( $homo_num >= 40 ) && ( $chr ne 'chr13' ) && ( $chr ne 'chr14' ) && ( $chr ne 'chr15' ) && ( $chr ne 'chr21' ) && ( $chr ne 'chr22' ) ) {
				$upd_region{$cur_start} = $pre_pos;
				$region2baf_all{$cur_start} = join(",", @cur_bafs);
			}
			$short_flag = 0;
		}
		@cur_bafs = ();
		$homo_num = 0;
	}
}
close(BAF_ALL);


my %region2baf;
foreach my $tmp_region ( keys %upd_region ) {
	my @baf_array = split(/,/, $region2baf_all{$tmp_region});
	my $median = &percentile(50, @baf_array);
	
	my $baf_sum = 0;
	my $baf_num = 0;
	foreach my $baf ( @baf_array ) {
		$baf_sum += $baf if ( $baf >= $median );
		$baf_num++ if ( $baf >= $median );
	}
	$region2baf{$tmp_region} = $baf_sum / $baf_num;
}


# obtain BAFs for regions with undefined BAFs
my %undef_region;
my %region2baf_undef;
my $cur_region = '';
@cur_bafs = ();
$processing = 0;

open BAF_ALL, '<', $ARGV[0] || die "cannot open $!";
while (<BAF_ALL>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $chr = $curRow[0];
	my $pos = $curRow[1];
	my $baf = $curRow[2];
	
	if ( $processing == 1 ) {
		if ( $pos >= $cur_end ) {
			if ( $#cur_bafs >= 39 ) {
				$undef_region{$cur_region} = 1;
				$region2baf_undef{$cur_region} = join(",", @cur_bafs);
			}
			$cur_region = '';
			$cur_end = '';
			$processing = 0;
		} else {
			push(@cur_bafs, $baf) if ( $baf ne 'NA' );
		}
	}
	
	next if ( $baf eq 'NA' );
	foreach my $tmp_region ( keys %pos2info_undef ) {
		my @items = split(/\t/, $tmp_region);
		my $tmp_end = $start2end_undef{$tmp_region};
		
		next if ( $chr ne $items[0] );
		if ( ( $pos >= $items[1] ) && ( $pos <= $tmp_end ) ) {
			$cur_region = $tmp_region;
			push(@cur_bafs, $baf);
			$cur_end = $tmp_end;
			$processing = 1;
			last;
		}
	}
}
close(BAF_ALL);

my %undef2baf;
foreach my $tmp_region ( keys %undef_region ) {
	my @baf_array = split(/,/, $region2baf_undef{$tmp_region});
	my $median = &percentile(50, @baf_array);
	
	my $baf_sum = 0;
	my $baf_num = 0;
	foreach my $baf ( @baf_array ) {
		$baf_sum += $baf if ( $baf >= $median );
		$baf_num++ if ( $baf >= $median );
	}
	$undef2baf{$tmp_region} = $baf_sum / $baf_num;
}


# define genic regions
my %gene2chr;
my %gene2start;
my %gene2end;
my $cur_gene = '';
while (<GENE_INFO>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $gene = $curRow[0];
	$gene2chr{$gene} = $curRow[1];
	$gene2start{$gene} = $curRow[2];
	$gene2end{$gene} = $curRow[3];
}
close(GENE_INFO);


# obtain depths for UPD regions
my %region2sum;
my %region2num;
my %region2num_all;
my %region2ave;
$cur_start = '';
$cur_end = '';
$processing = 0;

open SIGNAL,  '<', $ARGV[1] || die "cannot open $!";
while (<SIGNAL>) {
	my @curRow = split(/\t/, $_);
	my $chr = $curRow[0];
	my $pos = $curRow[1];
	my $key = $chr . "\t" . $pos;
	my $depth = $curRow[2];
	
	if ( $processing == 1 ) {
		$region2num_all{$cur_start}++;
		if ( $depth ne 'NA' ) {
			if ( defined $region2sum{$cur_start} ) {
				$region2sum{$cur_start} += $depth;
				$region2num{$cur_start}++;
			} else {
				$region2sum{$cur_start} = $depth;
				$region2num{$cur_start} = 1;
			}
			$region2ave{$cur_start} = $region2sum{$cur_start} / $region2num{$cur_start};
		}
		
		if ( $pos >= $cur_end ) {
			$processing = 0;
			$cur_start = '';
			$cur_end = '';
		}
	} else {
		foreach my $tmp_key ( keys %upd_region ) {
			my @F = split(/\t/, $tmp_key);
			next unless ( $chr eq $F[0] );
			if ( ( $pos >= $F[1] ) && ( $pos <= $upd_region{$tmp_key} ) ) {
				$processing = 1;
				$cur_start = $tmp_key;
				$cur_end = $upd_region{$tmp_key};
				
				$region2num_all{$cur_start} = 1;
				$region2ave{$cur_start} = 'NA';
				
				if ( $depth ne 'NA' ) {
					$region2sum{$cur_start} = $depth;
					$region2num{$cur_start} = 1;
					$region2ave{$cur_start} = $depth;
				}
				
				last;
			}
		}
	}
}
close(SIGNAL);


# newly-defined UPDs
foreach my $tmp_region ( keys %upd_region ) {
	my @info = split(/\t/, $tmp_region);
	my $chr = $info[0];
	my $start = $info[1];
	my $end = $upd_region{$tmp_region};
	
	my $overlap = 0;
	foreach my $cna_region ( keys %pos2info ) {
		my @info_cna = split(/\t/, $cna_region);
		my $chr_cna = $info_cna[0];
		my $start_cna = $info_cna[1];
		my $end_cna = $pos2info{$cna_region};
		
		next if ( $chr_cna ne $chr );
		next if ( ( $start_cna > $end ) || ( $end_cna < $start ) );
		$overlap = 1;
		last;
	}
	next if ( $overlap == 1 );
	
	my $region = $tmp_region;
	$region =~ s/^chr//;
	$region =~ s/^X/23/;
	$region =~ s/^Y/24/;
	
	my @gene_list;   # genes encoded in UPD regions
	foreach my $cur_gene ( sort keys %gene2chr ) {
		next if ( $gene2chr{$cur_gene} ne $chr );
		next if ( $gene2end{$cur_gene} < $start );
		next if ( $gene2start{$cur_gene} > $end );
		push(@gene_list, $cur_gene);
	}
	
	$pos2info{$region} = '"' . $id . '"' . "\t" . $region . "\t" . $end . "\t" . $region2num_all{$tmp_region} . "\t" . $region2ave{$tmp_region} . "\t" . $region2baf{$tmp_region} . "\t" . join(",", @gene_list);
}


# output
foreach my $tmp_pos ( sort chrpos keys %pos2info ) {
	my @info = split(/\t/, $pos2info{$tmp_pos});
	my $baf = $info[6];
	if ( defined $undef2baf{$tmp_pos} ) {
		$baf = $undef2baf{$tmp_pos};
	}
	
	if ( defined $info[7] )  {
		print join("\t", @info[ 0 .. 5 ]) . "\t" . $baf . "\t" . $info[7] . "\n";
	} else {
		print join("\t", @info[ 0 .. 5 ]) . "\t" . $baf . "\t" . '' . "\n";
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


# obtain percentiles
sub percentile {
	my $percent = $_[0];
	my @sorted = sort { $a <=> $b } @_[ 1 .. $#_ ];
	my $idx = int( @sorted * $percent / 100 );
	my $down_dif = @sorted * $percent / 100 - $idx;
	my $up_dif = 1 - $down_dif;
	my $value = $sorted[ $idx - 1 ] * $up_dif + $sorted[ $idx ] * $down_dif;
	return $value;
}
