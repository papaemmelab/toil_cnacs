#! /usr/local/perl -w
use strict;

open IN, '<', $ARGV[0] || die "cannot open $!";
my $id = $ARGV[1];

### separate segments by their belonging regions ###
my %region2segs;
my $pre_region = 'NA';

while (<IN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $region = join("\t", @curRow[ 0 .. 2 ]);
	
	if ( $region eq $pre_region ) {
		$region2segs{$region} .= "\n" . join("\t", @curRow[ 3 .. $#curRow ]);
	} else {
		$region2segs{$region} = join("\t", @curRow[ 3 .. $#curRow ]);
		$pre_region = $region;
	}
}
close(IN);


foreach my $region ( sort chrpos keys %region2segs ) {
	my @segs = split(/\n/, $region2segs{$region});
	
	if ( $#segs == 0 ) {
		my @curRow = split(/\t/, $segs[0]);
		my $chr = $curRow[0];
		$chr =~ s/^chr//;
		$chr = 23 if ( $chr eq 'X' );
		
		print '"' . $id . '"' . "\t" . $chr . "\t" . join("\t", @curRow[ 1 .. 4 ]) . "\t" . $curRow[6] . "\n";
	} elsif ( $#segs == 1 ) {
		my $merged = &merge_segs_type0($segs[0], $segs[1], $id);
		print $merged;
	} elsif ( $#segs == 2 ) {
		my $merged1 = &merge_segs_type1_2($segs[0], $segs[1], $id);
		$merged1 =~ s/[\r\n]$//;
		my @merged1_line = split(/\n/, $merged1);
		
		my $new_seg;
		if ( $#merged1_line == 1 ) {
			my @curRow1 = split(/\t/, $segs[0]);
			my $chr = $curRow1[0];
			$chr =~ s/^chr//;
			$chr = 23 if ( $chr eq 'X' );
			print '"' . $id . '"' . "\t" . $chr . "\t" . join("\t", @curRow1[ 1 .. 4 ]) . "\t" . $curRow1[6] . "\n";
			
			$new_seg = $segs[1];
		} else {
			$new_seg = $merged1_line[0];
		}
		
		my $merged2 = &merge_segs_type2($new_seg, $segs[2], $id);
		print $merged2;
	} else {
		my $merged1 = &merge_segs_type1($segs[0], $segs[1], $id);
		print $merged1;
		
		if ( $#segs >= 4 ) {
			foreach my $seg ( @segs[ 2 .. $#segs - 2 ] ) {
				my @curRow = split(/\t/, $seg);
				my $chr = $curRow[0];
				$chr =~ s/^chr//;
				$chr = 23 if ( $chr eq 'X' );
				
				print '"' . $id . '"' . "\t" . $chr . "\t" . join("\t", @curRow[ 1 .. 4 ]) . "\t" . $curRow[6] . "\n";
			}
		}
		
		my $merged2 = &merge_segs_type2($segs[$#segs - 1], $segs[$#segs], $id);
		print $merged2;
	}
}


# merge two segments
sub merge_segs_type0 {
	my @args = @_;
	my $id = $args[2];
	
	my @curRow1 = split(/\t/, $args[0]);
	my $chr = $curRow1[0];
	$chr =~ s/^chr//;
	$chr = 23 if ( $chr eq 'X' );
	my $start1 = $curRow1[1];
	my $end1 = $curRow1[2];
	my $pos_num1 = $curRow1[3];
	my $depth1 = $curRow1[4];
	my $depth_num1 = $curRow1[5];
	my $baf1 = $curRow1[6];
	my $baf_num1 = $curRow1[7];
	
	my @curRow2 = split(/\t/, $args[1]);
	my $start2 = $curRow2[1];
	my $end2 = $curRow2[2];
	my $pos_num2 = $curRow2[3];
	my $depth2 = $curRow2[4];
	my $depth_num2 = $curRow2[5];
	my $baf2 = $curRow2[6];
	my $baf_num2 = $curRow2[7];
	
	my $output;
	
	if ( $depth1 eq 'NA' ) {
		if ( $depth2 eq 'NA' ) {
			$output = '"' . $id . '"' . "\t" . $chr . "\t" . join("\t", @curRow1[ 1 .. 4 ]) . "\t" . $curRow1[6] . "\n";
			$output .= '"' . $id . '"' . "\t" . $chr . "\t" . join("\t", @curRow2[ 1 .. 4 ]) . "\t" . $curRow2[6] . "\n";
		} else {
			my $pos_num = $pos_num1 + $pos_num2;
			my $baf = $baf1;
			if ( $baf1 eq 'NA' ) {
				$baf = $baf2;
			} else {
				if ( $baf2 ne 'NA' ) {
					$baf = ( $baf1 * $baf_num1 + $baf2 * $baf_num2 ) / ( $baf_num1 + $baf_num2 );
				}
			}
			
			$output = '"' . $id . '"' . "\t" . $chr . "\t" . $start1 . "\t" . $end2 . "\t" . $pos_num . "\t" . $depth2 . "\t" . $baf . "\n";
		}
	} elsif ( $depth2 eq 'NA' ) {
		my $pos_num = $pos_num1 + $pos_num2;
		my $baf = $baf1;
		if ( $baf1 eq 'NA' ) {
			$baf = $baf2;
		} else {
			if ( $baf2 ne 'NA' ) {
				$baf = ( $baf1 * $baf_num1 + $baf2 * $baf_num2 ) / ( $baf_num1 + $baf_num2 );
			}
		}
		
		$output = '"' . $id . '"' . "\t" . $chr . "\t" . $start1 . "\t" . $end2 . "\t" . $pos_num . "\t" . $depth2 . "\t" . $baf . "\n";
	} elsif ( $baf1 eq 'NA' ) {
		if ( $baf2 eq 'NA' ) {
			$output = '"' . $id . '"' . "\t" . $chr . "\t" . join("\t", @curRow1[ 1 .. 4 ]) . "\t" . $curRow1[6] . "\n";
			$output .= '"' . $id . '"' . "\t" . $chr . "\t" . join("\t", @curRow2[ 1 .. 4 ]) . "\t" . $curRow2[6] . "\n";
		} else {
			my $pos_num = $pos_num1 + $pos_num2;
			my $depth = ( $depth1 * $depth_num1 + $depth2 * $depth_num2 ) / ( $depth_num1 + $depth_num2 );
			$output = '"' . $id . '"' . "\t" . $chr . "\t" . $start1 . "\t" . $end2 . "\t" . $pos_num . "\t" . $depth . "\t" . $baf2 . "\n";
		}
	} elsif ( $baf2 eq 'NA' ) {
		my $pos_num = $pos_num1 + $pos_num2;
		my $depth = ( $depth1 * $depth_num1 + $depth2 * $depth_num2 ) / ( $depth_num1 + $depth_num2 );
		$output = '"' . $id . '"' . "\t" . $chr . "\t" . $start1 . "\t" . $end2 . "\t" . $pos_num . "\t" . $depth . "\t" . $baf1 . "\n";
	} else {
		$output = '"' . $id . '"' . "\t" . $chr . "\t" . join("\t", @curRow1[ 1 .. 4 ]) . "\t" . $curRow1[6] . "\n";
		$output .= '"' . $id . '"' . "\t" . $chr . "\t" . join("\t", @curRow2[ 1 .. 4 ]) . "\t" . $curRow2[6] . "\n";
	}
	
	return $output;
}

sub merge_segs_type1 {
	my @args = @_;
	my $id = $args[2];
	
	my @curRow1 = split(/\t/, $args[0]);
	my $chr = $curRow1[0];
	$chr =~ s/^chr//;
	$chr = 23 if ( $chr eq 'X' );
	my $start1 = $curRow1[1];
	my $end1 = $curRow1[2];
	my $pos_num1 = $curRow1[3];
	my $depth1 = $curRow1[4];
	my $depth_num1 = $curRow1[5];
	my $baf1 = $curRow1[6];
	my $baf_num1 = $curRow1[7];
	
	my @curRow2 = split(/\t/, $args[1]);
	my $start2 = $curRow2[1];
	my $end2 = $curRow2[2];
	my $pos_num2 = $curRow2[3];
	my $depth2 = $curRow2[4];
	my $depth_num2 = $curRow2[5];
	my $baf2 = $curRow2[6];
	my $baf_num2 = $curRow2[7];
	
	my $output;
	
	if ( $depth1 eq 'NA' ) {
		if ( $depth2 eq 'NA' ) {
			$output = '"' . $id . '"' . "\t" . $chr . "\t" . join("\t", @curRow1[ 1 .. 4 ]) . "\t" . $curRow1[6] . "\n";
			$output .= '"' . $id . '"' . "\t" . $chr . "\t" . join("\t", @curRow2[ 1 .. 4 ]) . "\t" . $curRow2[6] . "\n";
		} else {
			my $pos_num = $pos_num1 + $pos_num2;
			my $baf = $baf1;
			if ( $baf1 eq 'NA' ) {
				$baf = $baf2;
			} else {
				if ( $baf2 ne 'NA' ) {
					$baf = ( $baf1 * $baf_num1 + $baf2 * $baf_num2 ) / ( $baf_num1 + $baf_num2 );
				}
			}
			
			$output = '"' . $id . '"' . "\t" . $chr . "\t" . $start1 . "\t" . $end2 . "\t" . $pos_num . "\t" . $depth2 . "\t" . $baf . "\n";
		}
	} elsif ( $baf1 eq 'NA' ) {
		if ( $baf2 eq 'NA' ) {
			$output = '"' . $id . '"' . "\t" . $chr . "\t" . join("\t", @curRow1[ 1 .. 4 ]) . "\t" . $curRow1[6] . "\n";
			$output .= '"' . $id . '"' . "\t" . $chr . "\t" . join("\t", @curRow2[ 1 .. 4 ]) . "\t" . $curRow2[6] . "\n";
		} else {
			my $pos_num = $pos_num1 + $pos_num2;
			my $depth = $depth1;
			if ( $depth2 ne 'NA' ) {
				$depth = ( $depth1 * $depth_num1 + $depth2 * $depth_num2 ) / ( $depth_num1 + $depth_num2 );
			}
			$output = '"' . $id . '"' . "\t" . $chr . "\t" . $start1 . "\t" . $end2 . "\t" . $pos_num . "\t" . $depth . "\t" . $baf2 . "\n";
		}
	} else {
		$output = '"' . $id . '"' . "\t" . $chr . "\t" . join("\t", @curRow1[ 1 .. 4 ]) . "\t" . $curRow1[6] . "\n";
		$output .= '"' . $id . '"' . "\t" . $chr . "\t" . join("\t", @curRow2[ 1 .. 4 ]) . "\t" . $curRow2[6] . "\n";
	}
	
	return $output;
}

sub merge_segs_type1_2 {
	my @args = @_;
	my $id = $args[2];
	
	my @curRow1 = split(/\t/, $args[0]);
	my $chr = $curRow1[0];
	my $start1 = $curRow1[1];
	my $end1 = $curRow1[2];
	my $pos_num1 = $curRow1[3];
	my $depth1 = $curRow1[4];
	my $depth_num1 = $curRow1[5];
	my $baf1 = $curRow1[6];
	my $baf_num1 = $curRow1[7];
	
	my @curRow2 = split(/\t/, $args[1]);
	my $start2 = $curRow2[1];
	my $end2 = $curRow2[2];
	my $pos_num2 = $curRow2[3];
	my $depth2 = $curRow2[4];
	my $depth_num2 = $curRow2[5];
	my $baf2 = $curRow2[6];
	my $baf_num2 = $curRow2[7];
	
	my $output;
	
	if ( $depth1 eq 'NA' ) {
		if ( $depth2 eq 'NA' ) {
			$output = $args[0] . "\n";
			$output .= $args[1] . "\n";
		} else {
			my $pos_num = $pos_num1 + $pos_num2;
			my $baf = $baf1;
			my $baf_num;
			if ( $baf1 eq 'NA' ) {
				$baf = $baf2;
				$baf_num = $baf_num2 if ( $baf2 eq 'NA' );
				$baf_num = $baf_num1 + $baf_num2 if ( $baf2 ne 'NA' );
			} else {
				if ( $baf2 ne 'NA' ) {
					$baf = ( $baf1 * $baf_num1 + $baf2 * $baf_num2 ) / ( $baf_num1 + $baf_num2 );
					$baf_num = $baf_num1 + $baf_num2;
				}
			}
			
			$output = $chr . "\t" . $start1 . "\t" . $end2 . "\t" . $pos_num . "\t" . $depth2 . "\t" . $depth_num2 . "\t" . $baf . "\t" . $baf_num . "\n";
		}
	} elsif ( $baf1 eq 'NA' ) {
		if ( $baf2 eq 'NA' ) {
			$output = $args[0] . "\n";
			$output .= $args[1] . "\n";
		} else {
			my $pos_num = $pos_num1 + $pos_num2;
			my $depth = $depth1;
			my $depth_num = $depth_num1;
			if ( $depth2 ne 'NA' ) {
				$depth = ( $depth1 * $depth_num1 + $depth2 * $depth_num2 ) / ( $depth_num1 + $depth_num2 );
				$depth_num += $depth_num2;
			}
			$output = $chr . "\t" . $start1 . "\t" . $end2 . "\t" . $pos_num . "\t" . $depth . "\t" . $depth_num . "\t" . $baf2 . "\t" . $baf_num2 . "\n";
		}
	} else {
		$output = $args[0] . "\n";
		$output .= $args[1] . "\n";
	}
	
	return $output;
}

sub merge_segs_type2 {
	my @args = @_;
	my $id = $args[2];
	
	my @curRow1 = split(/\t/, $args[0]);
	my $chr = $curRow1[0];
	$chr =~ s/^chr//;
	$chr = 23 if ( $chr eq 'X' );
	my $start1 = $curRow1[1];
	my $end1 = $curRow1[2];
	my $pos_num1 = $curRow1[3];
	my $depth1 = $curRow1[4];
	my $depth_num1 = $curRow1[5];
	my $baf1 = $curRow1[6];
	my $baf_num1 = $curRow1[7];
	
	my @curRow2 = split(/\t/, $args[1]);
	my $start2 = $curRow2[1];
	my $end2 = $curRow2[2];
	my $pos_num2 = $curRow2[3];
	my $depth2 = $curRow2[4];
	my $depth_num2 = $curRow2[5];
	my $baf2 = $curRow2[6];
	my $baf_num2 = $curRow2[7];
	
	my $output;
	
	if ( $depth2 eq 'NA' ) {
		if ( $depth1 eq 'NA' ) {
			$output = '"' . $id . '"' . "\t" . $chr . "\t" . join("\t", @curRow1[ 1 .. 4 ]) . "\t" . $curRow1[6] . "\n";
			$output .= '"' . $id . '"' . "\t" . $chr . "\t" . join("\t", @curRow2[ 1 .. 4 ]) . "\t" . $curRow2[6] . "\n";
		} else {
			my $pos_num = $pos_num1 + $pos_num2;
			my $baf = $baf2;
			if ( $baf2 eq 'NA' ) {
				$baf = $baf1;
			} else {
				if ( $baf1 ne 'NA' ) {
					$baf = ( $baf1 * $baf_num1 + $baf2 * $baf_num2 ) / ( $baf_num1 + $baf_num2 );
				}
			}
			
			$output = '"' . $id . '"' . "\t" . $chr . "\t" . $start1 . "\t" . $end2 . "\t" . $pos_num . "\t" . $depth2 . "\t" . $baf . "\n";
		}
	} elsif ( $baf2 eq 'NA' ) {
		if ( $baf1 eq 'NA' ) {
			$output = '"' . $id . '"' . "\t" . $chr . "\t" . join("\t", @curRow1[ 1 .. 4 ]) . "\t" . $curRow1[6] . "\n";
			$output .= '"' . $id . '"' . "\t" . $chr . "\t" . join("\t", @curRow2[ 1 .. 4 ]) . "\t" . $curRow2[6] . "\n";
		} else {
			my $pos_num = $pos_num1 + $pos_num2;
			my $depth = $depth2;
			if ( $depth1 ne 'NA' ) {
				$depth = ( $depth1 * $depth_num1 + $depth2 * $depth_num2 ) / ( $depth_num1 + $depth_num2 );
			}
			$output = '"' . $id . '"' . "\t" . $chr . "\t" . $start1 . "\t" . $end2 . "\t" . $pos_num . "\t" . $depth . "\t" . $baf1 . "\n";
		}
	} else {
		$output = '"' . $id . '"' . "\t" . $chr . "\t" . join("\t", @curRow1[ 1 .. 4 ]) . "\t" . $curRow1[6] . "\n";
		$output .= '"' . $id . '"' . "\t" . $chr . "\t" . join("\t", @curRow2[ 1 .. 4 ]) . "\t" . $curRow2[6] . "\n";
	}
	
	return $output;
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
