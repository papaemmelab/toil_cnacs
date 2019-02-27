#! /usr/local/perl -w
use strict;

open SIGNAL, '<', $ARGV[0] || die "cannot open $!";

# define regions with their starts
# define junctions in each region
my %start2chr;
my %start2end;
my %start2juncs_tmp;
my %junc2side;

while (<STDIN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $chr = $curRow[0];
	$chr = 'chrX' if ( $chr eq 'chr23' );
	$chr = 'chrY' if ( $chr eq 'chr24' );
	
	my $start = $chr . "\t" . $curRow[1];
	$start2chr{$start} = $chr;
	$start2end{$start} = $curRow[2];
	
	$start2juncs_tmp{$start} = $curRow[1] if ( ! defined $start2juncs_tmp{$start} );
	$junc2side{$start} = 'left';
	
	if ( $curRow[4] != $curRow[1] ) {
		$start2juncs_tmp{$start} .= "\t" . $curRow[4];
		my $junc = $curRow[0] . "\t" . $curRow[4];
		$junc2side{$junc} = 'left';
	}
	if ( $curRow[5] != $curRow[2] ) {
		$start2juncs_tmp{$start} .= "\t" . $curRow[5];
		my $junc = $curRow[0] . "\t" . $curRow[5];
		$junc2side{$junc} = 'right';
	}
}

# remove duplicate junctions
my %start2juncs;
foreach my $start ( keys %start2juncs_tmp ) {
	my @juncs = split(/\t/, $start2juncs_tmp{$start});
	my %unique_hash;
	foreach my $junc ( @juncs ) {
		next if ( defined $unique_hash{$junc} );
		$unique_hash{$junc} = 1;
	}
	
	my @unique_array;
	foreach my $unique ( keys %unique_hash ) {
		push(@unique_array, $unique);
	}
	$start2juncs{$start} = join("\t", @unique_array);
}


### process signals ###
# hashes for ouput
my %left2right;
my %left2pos_num;
my %left2depth_num;
my %left2depth;
my %left2baf_num;
my %left2baf;

# values and hashes for processing
my $status = 0;
my $next_to_end = 0;
my $cur_end = 0;
my %cur_lefts;
my $cur_left;
my $pre_pos = 0;
my $pos_num = 0;
my $depth_num = 0;
my $depth_sum = 0;
my $baf_num = 0;
my $baf_sum = 0;

while (<SIGNAL>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $pos = join("\t", @curRow[ 0 .. 1 ]);
	
	if ( ( $status == 0 ) && ( defined $start2chr{$pos} ) ) {   # start of a region
		$status = 1;
		$pre_pos = $curRow[1];
		$cur_end = $start2end{$pos};
		my @tmp_lefts = split(/\t/, $start2juncs{$pos});
		foreach my $tmp_left ( @tmp_lefts ) {
			my $key = $curRow[0] . "\t" . $tmp_left;
			$cur_lefts{$tmp_left} = $junc2side{$key};
		}
		
		$cur_left = $pos;
		$pos_num = 1;
		if ( $curRow[2] ne 'NA' ) {
			$depth_num = 1;
			$depth_sum = $curRow[2];
		}
		if ( $curRow[3] ne 'NA' ) {
			$baf_num = 1;
			$baf_sum = $curRow[3];
		}
	} else {   # when processing a region
		if ( $next_to_end == 1 ) {
			$cur_left = $pos;
			$next_to_end = 0;
		}
		
		if ( $curRow[1] == $cur_end ) {   # end of a region
			# finalize the segment
			$left2right{$cur_left} = $curRow[1];
			
			$pos_num++;
			if ( $curRow[2] ne 'NA' ) {
				$depth_num++;
				$depth_sum += $curRow[2];
			}
			if ( $curRow[3] ne 'NA' ) {
				$baf_num++;
				$baf_sum += $curRow[3];
			}
			
			$left2pos_num{$cur_left} = $pos_num;
			$left2depth_num{$cur_left} = $depth_num;
			$left2baf_num{$cur_left} = $baf_num;
			$left2depth{$cur_left} = 'NA';
			if ( $depth_num != 0 ) {
				$left2depth{$cur_left} = $depth_sum / $depth_num;
			}
			$left2baf{$cur_left} = 'NA';
			if ( $baf_num != 0 ) {
				$left2baf{$cur_left} = $baf_sum / $baf_num;
			}
			
			# initialize values and hashes for processing regions
			$status = 0;
			$cur_end = 0;
			%cur_lefts = ();
			$cur_left = '';
			$pre_pos = 0;
			$pos_num = 0;
			$depth_num = 0;
			$depth_sum = 0;
			$baf_num = 0;
			$baf_sum = 0;
		} elsif ( defined $cur_lefts{$curRow[1]} ) {
			if ( $cur_lefts{$curRow[1]} eq 'left' ) {
				if ( $pos_num == 0 ) {
					$cur_left = $pos;
					$pre_pos = $curRow[1];
					$pos_num = 1;
					if ( $curRow[2] ne 'NA' ) {
						$depth_num = 1;
						$depth_sum = $curRow[2];
					}
					if ( $curRow[3] ne 'NA' ) {
						$baf_num = 1;
						$baf_sum = $curRow[3];
					}
					next;
				}
				
				# finalize the segment
				$left2right{$cur_left} = $pre_pos;
				$left2pos_num{$cur_left} = $pos_num;
				$left2depth_num{$cur_left} = $depth_num;
				$left2baf_num{$cur_left} = $baf_num;
				$left2depth{$cur_left} = 'NA';
				if ( $depth_num != 0 ) {
					$left2depth{$cur_left} = $depth_sum / $depth_num;
				}
				$left2baf{$cur_left} = 'NA';
				if ( $baf_num != 0 ) {
					$left2baf{$cur_left} = $baf_sum / $baf_num;
				}
				
				$cur_left = $pos;
				$pre_pos = $curRow[1];
				$pos_num = 1;
				if ( $curRow[2] ne 'NA' ) {
					$depth_num = 1;
					$depth_sum = $curRow[2];
				}
				if ( $curRow[3] ne 'NA' ) {
					$baf_num = 1;
					$baf_sum = $curRow[3];
				}
			} elsif ( $cur_lefts{$curRow[1]} eq 'right' ) {
				$pos_num++;
				if ( $curRow[2] ne 'NA' ) {
					$depth_num++;
					$depth_sum += $curRow[2];
				}
				if ( $curRow[3] ne 'NA' ) {
					$baf_num++;
					$baf_sum += $curRow[3];
				}
				
				# finalize the segment
				$left2right{$cur_left} = $curRow[1];
				$left2pos_num{$cur_left} = $pos_num;
				$left2depth_num{$cur_left} = $depth_num;
				$left2baf_num{$cur_left} = $baf_num;
				$left2depth{$cur_left} = 'NA';
				if ( $depth_num != 0 ) {
					$left2depth{$cur_left} = $depth_sum / $depth_num;
				}
				$left2baf{$cur_left} = 'NA';
				if ( $baf_num != 0 ) {
					$left2baf{$cur_left} = $baf_sum / $baf_num;
				}
				
				$pre_pos = $curRow[1];
				$next_to_end = 1;
				# initialize
				$cur_left = '';
				$pos_num = 0;
				$depth_num = 0;
				$depth_sum = 0;
				$baf_num = 0;
				$baf_sum = 0;
			}
		} else {
			$pre_pos = $curRow[1];
			
			$pos_num++;
			if ( $curRow[2] ne 'NA' ) {
				$depth_num++;
				$depth_sum += $curRow[2];
			}
			if ( $curRow[3] ne 'NA' ) {
				$baf_num++;
				$baf_sum += $curRow[3];
			}
		}
	}
	
}
close(SIGNAL);


# output
foreach my $start ( sort chrpos keys %start2end ) {
	my $chr = $start2chr{$start};
	my $end = $start2end{$start};
	my @lefts = split(/\t/, $start2juncs{$start});
	foreach my $left ( sort { $a <=> $b } @lefts ) {
		my $left_key = $chr . "\t" . $left;
		next if ( ! defined $left2right{$left_key} );
		my $right = $left2right{$left_key};
		my $depth = $left2depth{$left_key};
		my $baf = $left2baf{$left_key};
		my $pos_num = $left2pos_num{$left_key};
		my $depth_num = $left2depth_num{$left_key};
		my $baf_num = $left2baf_num{$left_key};
		
		print $start . "\t" . $end . "\t" . $left_key . "\t" . $right . "\t" . $pos_num . "\t" . $depth . "\t" . $depth_num . "\t" . $baf . "\t" . $baf_num . "\n";
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
