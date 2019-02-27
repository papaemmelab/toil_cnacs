#! /usr/local/bin/perl -w
use strict;

open IN, '<', $ARGV[0] || die "cannot open $!";
my $indir = $ARGV[1];

# define genic regions
my $gene_info = $ARGV[2];
my $gene_flag = 0;
my %gene2chr;
my %gene2start;
my %gene2end;

if ( -s $gene_info ) {
	$gene_flag = 1;
	open GENE, '<', $gene_info || die "cannot open $!";
	my $cur_gene = '';
	while (<GENE>) {
		s/[\r\n]//g;
		my @curRow = split(/\t/, $_);
		my $gene = $curRow[0];
		$gene2chr{$gene} = $curRow[1];
		$gene2start{$gene} = $curRow[2];
		$gene2end{$gene} = $curRow[3];
	}
	close(GENE);
}


# load a final list of CNAs
my %id2pos;
while (<IN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $id = $curRow[0];
	$id =~ s/\"//g;
	
	my $chr_num = $curRow[1];
	my $chr = 'chr' . $chr_num;
	$chr = 'chrX' if ( $chr eq 'chr23' );
	$chr = 'chrY' if ( $chr eq 'chr24' );
	my $start = $curRow[2];
	my $end = $curRow[3];
	
	if ( ! defined $id2pos{$id} ) {
		$id2pos{$id} = $chr . ':' . $start . '-' . $end;
	} else {
		$id2pos{$id} .= "\t". $chr . ':' . $start . '-' . $end;
	}
}
close(IN);


# re-calculate signals when needed
foreach my $id ( sort keys %id2pos ) {
	# load automatically called candidates of CNAs
	my %called;
	my $res_file = $indir . '/' . $id . '/' . $id . '_result.txt';
	open RES, '<', $res_file || die "cannot open $!";
	while (<RES>) {
		s/[\r\n]//g;
		my @curRow = split(/\t/, $_);
		my $chr = 'chr' . $curRow[1];
		$chr = 'chrX' if ( $chr eq 'chr23' );
		$chr = 'chrY' if ( $chr eq 'chr24' );
		my $pos = $chr . ':' . join("-", @curRow[ 2 .. 3 ]);
		$called{$pos}= $_;
	}
	close(RES);
	
	# process fixed CNAs
	my @cnas = split(/\t/, $id2pos{$id});
	my %fixed;
	my %start2end;
	foreach my $cna ( @cnas ) {
		my @info = split(/[:-]/, $cna);
		my $start = $info[0] . "\t" . $info[1];
		
		if ( defined $called{$cna} ) {
			$fixed{$start} = $called{$cna};
		} else {
			$start2end{$start} = $info[2];
		}
	}
	
	my $pos_num = 0;
	my $depth_num = 0;
	my $baf_num = 0;
	my $depth_sum = 0;
	my $baf_sum = 0;
	my $cur_chr;
	my $cur_chrnum;
	my $cur_start;
	my $cur_end;
	my $processing = 0;
	
	my $sig_file = $indir . '/' . $id . '/' . $id . '_signal.txt';
	open SIG, '<', $sig_file || die "cannot open $!";
	while (<SIG>) {
		$_ =~ s/[\r\n]//g;
		my @F = split(/\t/, $_);
		my $pos = join("\t", @F[ 0 .. 1 ]);
		
		if ( $processing == 0 ) {
			next if ( ! defined $start2end{$pos} );
			$pos_num++;
			if ( $F[2] ne 'NA' ) {
				$depth_num++;
				$depth_sum += $F[2];
			}
			if ( $F[3] ne 'NA' ) {
				$baf_num++;
				$baf_sum += $F[3];
			}
			
			$cur_chr = $F[0];
			$cur_chrnum = $cur_chr;
			$cur_chrnum =~ s/^chr//;
			$cur_chrnum = 23 if ( $cur_chrnum eq 'X' );
			$cur_chrnum = 24 if ( $cur_chrnum eq 'Y' );
			$cur_start = $F[1];
			$cur_end = $start2end{$pos};
			$processing = 1;
			
			if ( $F[1] == $cur_end ) {
				my $depth_ave = 'NA';
				my $baf_ave = 'NA';
				$depth_ave = $depth_sum / $depth_num if ( $depth_num > 0 );
				$baf_ave = $baf_sum / $baf_num if ( $baf_num > 0 );
				
				my $key = $cur_chr . "\t" . $cur_start;
				my $output = '"' . $id . '"' . "\t" . $cur_chrnum . "\t" . $cur_start . "\t" . $cur_end . "\t" . $pos_num . "\t" . $depth_ave . "\t" . $baf_ave;
				
				if ( $gene_flag == 1 ) {
					my @gene_list;
					foreach my $cur_gene ( sort keys %gene2chr ) {
						next if ( $gene2chr{$cur_gene} ne $cur_chr );
						next if ( $gene2end{$cur_gene} < $cur_start );
						next if ( $gene2start{$cur_gene} > $cur_end );
						push(@gene_list, $cur_gene);
					}
					$output .= "\t" . join(",", @gene_list);
				}
				$fixed{$key} = $output;
				
				# %initialize
				$pos_num = 0;
				$depth_num = 0;
				$baf_num = 0;
				$depth_sum = 0;
				$baf_sum = 0;
				$cur_chr = '';
				$cur_chrnum = '';
				$cur_start = '';
				$cur_end = '';
				$processing = 0;
			}
		} else {
			$pos_num++;
			if ( $F[2] ne 'NA' ) {
				$depth_num++;
				$depth_sum += $F[2];
			}
			if ( $F[3] ne 'NA' ) {
				$baf_num++;
				$baf_sum += $F[3];
			}
			
			if ( $F[1] == $cur_end ) {
				my $depth_ave = 'NA';
				my $baf_ave = 'NA';
				$depth_ave = $depth_sum / $depth_num if ( $depth_num > 0 );
				$baf_ave = $baf_sum / $baf_num if ( $baf_num > 0 );
				
				my $key = $cur_chr . "\t" . $cur_start;
				my $output = '"' . $id . '"' . "\t" . $cur_chrnum . "\t" . $cur_start . "\t" . $cur_end . "\t" . $pos_num . "\t" . $depth_ave . "\t" . $baf_ave;
				
				if ( $gene_flag == 1 ) {
					my @gene_list;
					foreach my $cur_gene ( sort keys %gene2chr ) {
						next if ( $gene2chr{$cur_gene} ne $cur_chr );
						next if ( $gene2end{$cur_gene} < $cur_start );
						next if ( $gene2start{$cur_gene} > $cur_end );
						push(@gene_list, $cur_gene);
					}
					$output .= "\t" . join(",", @gene_list);
				}
				$fixed{$key} = $output;
				
				# %initialize
				$pos_num = 0;
				$depth_num = 0;
				$baf_num = 0;
				$depth_sum = 0;
				$baf_sum = 0;
				$cur_chr = '';
				$cur_chrnum = '';
				$cur_start = '';
				$cur_end = '';
				$processing = 0;
			}
		}
	}
	close(SIG);
	
	foreach my $pos_key ( sort chrpos keys %fixed ) {
		print $fixed{$pos_key} . "\n";
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
