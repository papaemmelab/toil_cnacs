#! /usr/local/bin/perl -w
use strict;

open DIPLOID, '<', $ARGV[0] || die "cannot open $!";
open SEG_TMP, '<', $ARGV[1] || die "cannot open $!";
open SIGNAL,  '<', $ARGV[2] || die "cannot open $!";
open REGION,  '<', $ARGV[3] || die "cannot open $!";
open PAR_BED, '<', $ARGV[4] || die "cannot open $!";
open SEGMENT, '>', $ARGV[5] || die "cannot open $!";
open OUT,     '>', $ARGV[6] || die "cannot open $!";
open SUMMARY, '>', $ARGV[7] || die "cannot open $!";


# load diploid regions
my %diploid;
my $dip_num = 0;
while (<DIPLOID>) {
	s/[\r\n]//g;
	$diploid{$_} = 1;
	$dip_num++;
}
close(DIPLOID);

# calculate mean signals in diploid regions
# calculate coefficient of variation in diploid regions
my $sum = 0;
my @diploid_signals;
while (<SIGNAL>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	
	my $chr = $curRow[0];
	next if ( ( $chr eq 'chrX' ) || ( $chr eq 'chrY' ) );
	my $pos = $curRow[1];
	my $key = $chr . "\t" . $pos;
	next unless ( defined $diploid{$key} );
	
	push(@diploid_signals, $curRow[2]);
}
close(SIGNAL);

my @stat = &stat( @diploid_signals );
my $compensation = $stat[0];
print SUMMARY 'Number_of_diploid_points' . "\t" . $dip_num . "\n";
print SUMMARY 'CoefVar' . "\t" . $stat[1] . "\n";


# load called CNAs
my %start2end;
my %start2depth;
my %start2as;
while (<SEG_TMP>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $chr_num = $curRow[1];
	my $chr = 'chr' . $chr_num;
	if ( $chr_num == 23 ) {
		$chr = 'chrX';
	} elsif ( $chr_num == 24 ) {
		$chr = 'chrY';
	}
	
	my $start = $chr . "\t" . $curRow[2];
	my $end = $curRow[3];
	$start2end{$start}   = $end;
	$start2depth{$start} = $curRow[5];
	$start2as{$start}    = $curRow[6];
}
close(SEG_TMP);


# define genic regions
my %gene2chr;
my %gene2start;
my %gene2end;
my $cur_gene = '';
while (<REGION>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $gene = $curRow[0];
	$gene2chr{$gene} = $curRow[1];
	$gene2start{$gene} = $curRow[2];
	$gene2end{$gene} = $curRow[3];
}
close(REGION);


# define pseudo-autosomal regions
my @par_start;
my @par_end;
while (<PAR_BED>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	push(@par_start, $curRow[1]);
	push(@par_end, $curRow[2]);
}
close(PAR_BED);


# output signals
# load signals in regions with called CNAs
open SIGNAL, '<', $ARGV[2] || die "cannot open $!";
my %start2base;
my %start2depth_sig;
my %start2as_sig;
my %start2depth_med;
my %start2as_med;
my @bases;
my @signal_dep_all;
my @signal_baf_all;
my @signal_dep;
my @signal_baf;
my $processing = 0;
my $cur_start;
my $cur_end;
while (<SIGNAL>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $chr = $curRow[0];
	my $pos = $curRow[1];
	my $key = $chr . "\t" . $pos;
	
	if ( $processing == 1 ) {
		push(@bases, $curRow[1]);
		push(@signal_dep_all, $curRow[2]);
		push(@signal_baf_all, $curRow[3]);
		push(@signal_dep, $curRow[2]) if ( $curRow[2] ne 'NA' );
		push(@signal_baf, $curRow[3]) if ( $curRow[3] ne 'NA' );
		if ( $pos == $cur_end ) {
			$start2base{$cur_start}      = join("\t", @bases);
			$start2depth_sig{$cur_start} = join("\t", @signal_dep_all);
			$start2as_sig{$cur_start}    = join("\t", @signal_baf_all);
			
			if ( @signal_dep > 0 ) {
				$start2depth_med{$cur_start} = &median(@signal_dep);
			} else {
				$start2depth_med{$cur_start} = 'NA';
			}
			if ( @signal_baf > 0 ) {
				$start2as_med{$cur_start} = &median(@signal_baf);
			} else {
				$start2as_med{$cur_start} = 'NA';
			}
			@bases = ();
			@signal_dep_all = ();
			@signal_baf_all = ();
			@signal_dep = ();
			@signal_baf = ();
			$processing = 0;
		}
	}
	
	if ( defined $start2end{$key} ) {
		$cur_start = $key;
		$processing = 1;
		$cur_end = $start2end{$key};
		push(@bases, $curRow[1]);
		push(@signal_dep_all, $curRow[2]);
		push(@signal_baf_all, $curRow[3]);
		push(@signal_dep, $curRow[2]) if ( $curRow[2] ne 'NA' );
		push(@signal_baf, $curRow[3]) if ( $curRow[3] ne 'NA' );
	}
	
	my $ploidy = 'NA';
	$ploidy = 2 * 2 ** ( $curRow[2] - $compensation ) if ( $curRow[2] ne 'NA' );
	
	my $as = 'NA';
	$as = 2 ** $curRow[3] if ( $curRow[3] ne 'NA' );
	
	print OUT $chr . "\t" . $pos . "\t" . $ploidy . "\t" . $as . "\n";
}
close(SIGNAL);


# make an output file for CNA/UPD regions
open SEG_TMP, '<', $ARGV[1] || die "cannot open $!";
while (<SEG_TMP>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $ploidy =  2 * 2 ** ( $curRow[5] - $compensation );
	my $as = 'NA';
	if ( $curRow[6] ne 'NA' ) {
		$as = 2 ** $curRow[6];
	}
	next if ( ( ( $ploidy < 2.2 ) && ( $ploidy > 1.8 ) ) && ( ( $as eq 'NA' ) || ( $as > 0.9 ) ) );
	
	my $chr_num = $curRow[1];
	my $chr = 'chr' . $chr_num;
	if ( $chr_num == 23 ) {
		$chr = 'chrX';
	} elsif ( $chr_num == 24 ) {
		$chr = 'chrY';
	}
	
	my $start = $curRow[2];
	my $end = $curRow[3];
	
	if ( $chr_num == 23 ) {
		next if ( ( $ploidy > 1.8 ) && ( $ploidy < 2.2 ) );
		
		my $par_flag = 0;
		foreach my $idx ( 0 .. $#par_start ) {
			$par_flag = 1 if ( ( $start > $par_start[$idx] ) && ( $end <= $par_end[$idx] ) );
		}
		next if ( ( $par_flag == 0 ) && ( $ploidy > 0.8 ) && ( $ploidy < 1.2 ) );
	}
	
	if ( $chr_num == 24 ) {
		next if ( ( $ploidy > 0.8 ) && ( $ploidy < 1.2 ) );
		next if ( ( $ploidy > 1.8 ) && ( $ploidy < 2.2 ) );
	}
	
	my @gene_list;
	foreach my $cur_gene ( sort keys %gene2chr ) {
		next if ( $gene2chr{$cur_gene} ne $chr );
		next if ( $gene2end{$cur_gene} < $start );
		next if ( $gene2start{$cur_gene} > $end );
		push(@gene_list, $cur_gene);
	}
	
	my $pos = $chr . "\t" . $start;
	my $depth_med = $start2depth_med{$pos};
	my $as_med = $start2as_med{$pos};
	
	if ( ( $ploidy eq 'NA' ) || ( ( $ploidy < 2.2 ) && ( $ploidy > 1.8 ) ) ) {
		next if ( $as_med eq 'NA' );
		next if ( $as_med > -0.152003093 );
	}
	
	if ( ( $ploidy ne 'NA' ) && ( ( $ploidy > 2.2 ) || ( $ploidy < 1.8 ) ) ) {
		my $ploidy_med = 2 * 2 ** ( $depth_med - $compensation );
		if ( ( $ploidy_med < 2.15 ) && ( $ploidy_med > 1.85 ) ) {
			my @bases = split(/\t/, $start2base{$pos});
			my @sig_dep = split(/\t/, $start2depth_sig{$pos});
			my @sig_baf = split(/\t/, $start2as_sig{$pos});
			my $base_num = 0;
			my $baf_num = 0;
			my $dep_sum = 0;
			my $baf_sum = 0;
			my $pre_pos;
			
			my @start_array;
			my @end_array;
			my @nums;
			my @ploidies;
			my @bafs;
			
			foreach my $num ( 0 .. $#bases ) {
				my $cur_ploidy = 'NA';
				my $cur_baf = 'NA';
				$cur_ploidy = 2 * 2 ** ( $sig_dep[$num] - $compensation ) if ( $sig_dep[$num] ne 'NA' );
				$cur_baf = 2 ** $sig_baf[$num] if ( $sig_baf[$num] ne 'NA' );
				
				if ( $ploidy < 1.8 ) {
					if ( $base_num == 0 ) {
						next if ( ( $cur_ploidy eq 'NA' ) || ( $cur_ploidy > $ploidy ) );
						push(@start_array, $bases[$num]);
						$base_num++;
						$baf_num++ if ( $cur_baf ne 'NA' );
						$dep_sum += $sig_dep[$num];
						$baf_sum += $sig_baf[$num] if ( $cur_baf ne 'NA' );
						$pre_pos = $bases[$num];
						
						if ( $num == $#bases ) {
							push(@nums, $base_num);
							push(@end_array, $pre_pos);
							
							my $mean_ploidy = 2 * 2 ** ( ( $dep_sum / $base_num ) - $compensation );
							my $mean_baf = 'NA';
							$mean_baf = 2 ** ( $baf_sum / $baf_num ) if ( $baf_num > 0 );
							push(@ploidies, $mean_ploidy);
							push(@bafs, $mean_baf);
						}
					} else {
						if ( ( $cur_ploidy eq 'NA' ) || ( $cur_ploidy > $ploidy ) ) {
							push(@nums, $base_num);
							push(@end_array, $pre_pos);
							
							my $mean_ploidy = 2 * 2 ** ( ( $dep_sum / $base_num ) - $compensation );
							my $mean_baf = 'NA';
							$mean_baf = 2 ** ( $baf_sum / $baf_num ) if ( $baf_num > 0 );
							push(@ploidies, $mean_ploidy);
							push(@bafs, $mean_baf);
							
							# initialize
							$base_num = 0;
							$baf_num = 0;
							$dep_sum = 0;
							$baf_sum = 0;
							$pre_pos = '';
						} else {
							$base_num++;
							$baf_num++ if ( $cur_baf ne 'NA' );
							$dep_sum += $sig_dep[$num];
							$baf_sum += $sig_baf[$num]  if ( $cur_baf ne 'NA' );
							$pre_pos = $bases[$num];
							
							if ( $num == $#bases ) {
								push(@nums, $base_num);
								push(@end_array, $pre_pos);
								
								my $mean_ploidy = 2 * 2 ** ( ( $dep_sum / $base_num ) - $compensation );
								my $mean_baf = 'NA';
								$mean_baf = 2 ** ( $baf_sum / $baf_num ) if ( $baf_num > 0 );
								push(@ploidies, $mean_ploidy);
								push(@bafs, $mean_baf);
							}
						}
					}
				} elsif ( $ploidy > 2.2 ) {
					if ( $base_num == 0 ) {
						next if ( ( $cur_ploidy eq 'NA' ) || ( $cur_ploidy < $ploidy ) );
						push(@start_array, $bases[$num]);
						$base_num++;
						$baf_num++ if ( $cur_baf ne 'NA' );
						$dep_sum += $sig_dep[$num];
						$baf_sum += $sig_baf[$num]  if ( $cur_baf ne 'NA' );
						$pre_pos = $bases[$num];
						
						if ( $num == $#bases ) {
							push(@nums, $base_num);
							push(@end_array, $pre_pos);
							
							my $mean_ploidy = 2 * 2 ** ( ( $dep_sum / $base_num ) - $compensation );
							my $mean_baf = 'NA';
							$mean_baf = 2 ** ( $baf_sum / $baf_num ) if ( $baf_num > 0 );
							push(@ploidies, $mean_ploidy);
							push(@bafs, $mean_baf);
						}
					} else {
						if ( ( $cur_ploidy eq 'NA' ) || ( $cur_ploidy < $ploidy ) ) {
							push(@nums, $base_num);
							push(@end_array, $pre_pos);
							
							my $mean_ploidy = 2 * 2 ** ( ( $dep_sum / $base_num ) - $compensation );
							my $mean_baf = 'NA';
							$mean_baf = 2 ** ( $baf_sum / $baf_num ) if ( $baf_num > 0 );
							push(@ploidies, $mean_ploidy);
							push(@bafs, $mean_baf);
							
							# initialize
							$base_num = 0;
							$baf_num = 0;
							$dep_sum = 0;
							$baf_sum = 0;
							$pre_pos = '';
						} else {
							$base_num++;
							$baf_num++ if ( $cur_baf ne 'NA' );
							$dep_sum += $sig_dep[$num];
							$baf_sum += $sig_baf[$num]  if ( $cur_baf ne 'NA' );
							$pre_pos = $bases[$num];
							
							if ( $num == $#bases ) {
								push(@nums, $base_num);
								push(@end_array, $pre_pos);
								
								my $mean_ploidy = 2 * 2 ** ( ( $dep_sum / $base_num ) - $compensation );
								my $mean_baf = 'NA';
								$mean_baf = 2 ** ( $baf_sum / $baf_num ) if ( $baf_num > 0 );
								push(@ploidies, $mean_ploidy);
								push(@bafs, $mean_baf);
							}
						}
					}
				}
			}
			
			my @new_gene_list;
			foreach my $tmp_idx ( 0 .. $#start_array ) {
				my @tmp_list;
				foreach my $cur_gene ( sort keys %gene2chr ) {
					next if ( $gene2chr{$cur_gene} ne $chr );
					next if ( $gene2end{$cur_gene} < $start_array[$tmp_idx] );
					next if ( $gene2start{$cur_gene} > $end_array[$tmp_idx] );
					push(@tmp_list, $cur_gene);
				}
				my $genes = join(",", @tmp_list);
				push(@new_gene_list, $genes);
			}

			foreach my $tmp_idx ( 0 .. $#start_array ) {
				print SEGMENT join("\t", @curRow[ 0 .. 1 ]) . "\t" . $start_array[$tmp_idx] . "\t" . $end_array[$tmp_idx] . "\t" . $nums[$tmp_idx] . "\t" . $ploidies[$tmp_idx] . "\t" . $bafs[$tmp_idx] . "\t" . $new_gene_list[$tmp_idx] . "\n";
			}
			next;
		}
	}
	
	print SEGMENT join("\t", @curRow[ 0 .. 4 ]). "\t" . $ploidy . "\t" . $as . "\t" . join(",", @gene_list) . "\n";
}
close(SEG_TMP);
close(SEGMENT);


sub stat {
	my $number = @_;
	if ( $number == 0 ) {
		return('NA', 'NA');
	} else {
		my $sum = 0;
		foreach my $item ( @_ ) {
			next if ( $item eq 'NA' );
			$sum += $item;
		}
		my $mean = $sum / $number;
		
		my $square_sum = 0;
		foreach my $item ( @_ ) {
			if ( $item eq 'NA' ) {
				$square_sum += ( $mean )**2;
				next;
			}
			$square_sum += ( $item - $mean )**2;
		}
		my $sd = 0;
		if ( $number > 1 ) {
			$sd = ( $square_sum / ( $number - 1 ) )**(1/2);
		}
		
		return($mean, $sd);
	}
}

sub median {
	my @list = sort {$a<=>$b} @_;
	my $n = @_;
	my $median;
	if ( $n%2 == 0 ) {
		my $idx = $n / 2;
		$median = ( $list[$idx - 1] + $list[$idx] ) * 0.5;
		return $median;
	} else {
		my $idx = $n / 2;
		$median = $list[$idx];
		return $median;
	}
}
